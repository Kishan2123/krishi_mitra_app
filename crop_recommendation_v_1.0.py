"""
KrishiMitra.AI - Physical & Chemical Crop Recommendation (GPU)
==============================================================
- Train ONLY to predict crop label (multi-class).
- Use ONLY physical/chemical/environment features.
- No economic/recommendation categorical features in training.
- Derive categorical descriptors at inference via thresholds.

Model:
- CatBoostClassifier (GPU) for tabular multi-class.
- Stratified K-Fold CV, fold-wise metrics & overfit checks.
- Optional Optuna tuning with pruning + safe GPU/CPU fallback.
"""

import os, json, yaml, logging, hashlib, warnings, time
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Tuple, Optional, Union

import numpy as np
import pandas as pd

from sklearn.model_selection import StratifiedKFold, train_test_split
from sklearn.metrics import (
    accuracy_score, f1_score, balanced_accuracy_score,
    classification_report, confusion_matrix, top_k_accuracy_score
)
from sklearn.preprocessing import LabelEncoder

from catboost import CatBoostClassifier, Pool

warnings.filterwarnings("ignore")

# =============================================================================
# LOGGING
# =============================================================================
def setup_logging(log_file: str = "krishimitra.log") -> logging.Logger:
    from logging.handlers import RotatingFileHandler
    import sys

    logger = logging.getLogger("KrishiMitra")
    logger.setLevel(logging.DEBUG)
    logger.handlers.clear()

    fh = RotatingFileHandler(
        log_file, maxBytes=10 * 1024 * 1024, backupCount=5, encoding="utf-8"
    )
    fh.setLevel(logging.DEBUG)

    ch = logging.StreamHandler(sys.stdout)
    ch.setLevel(logging.INFO)

    formatter = logging.Formatter(
        "%(asctime)s - %(name)s - %(levelname)s - %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )
    fh.setFormatter(formatter)
    ch.setFormatter(formatter)

    logger.addHandler(fh)
    logger.addHandler(ch)
    return logger

logger = setup_logging()

# =============================================================================
# CONFIG
# =============================================================================
class Config:
    def __init__(self, config_file: str = "config.yaml"):
        self.config_file = Path(config_file)
        self.set_defaults()
        self.load_config()

    def set_defaults(self):
        self.data_path = "expanded_synthetic_crop_dataset_300k.csv"
        self.model_dir = "models"
        self.logs_dir = "logs"

        self.random_seed = 42
        self.test_size = 0.15
        self.n_folds = 5

        self.optimize_hyperparams = True
        self.optuna_trials = 50
        self.optuna_timeout_sec = 1800

        self.use_gpu = True
        self.gpu_devices = "0"

        self.catboost_iterations = 2500
        self.catboost_learning_rate = 0.03
        self.catboost_depth = 9
        self.catboost_l2_leaf_reg = 8.0
        self.catboost_random_strength = 2.0
        self.catboost_rsm = 0.85
        self.catboost_min_data_in_leaf = 30
        self.catboost_border_count = 254
        self.catboost_bootstrap_type = "Bayesian"
        self.catboost_bagging_temperature = 0.6
        self.catboost_subsample = 0.85

        self.catboost_early_stopping_rounds = 150
        self.catboost_eval_metric = "Accuracy"
        self.catboost_log_period = 50

        self.top_n_recommendations = 3
        self.min_confidence_threshold = 0.10

        self.create_ratio_features = True
        self.log_transform_micronutrients = True
        self.create_climate_anomalies = True

        self.max_ph = 14.0
        self.min_ph = 0.0
        self.max_rainfall_mm = 5000
        self.max_temperature_c = 60
        self.min_temperature_c = -10

        self.boost_weak_classes = True
        self.weak_class_names = ["tomato", "maize", "sunflower", "onion"]
        self.weak_class_boost_factor = 1.5

        Path(self.model_dir).mkdir(exist_ok=True)
        Path(self.logs_dir).mkdir(exist_ok=True)

    def load_config(self):
        if self.config_file.exists():
            with open(self.config_file, "r") as f:
                cfg = yaml.safe_load(f) or {}
            for k, v in cfg.items():
                setattr(self, k, v)
            logger.info(f"Configuration loaded from {self.config_file}")
        else:
            logger.info("Config file not found. Creating with defaults.")
            self.save_config()

    def save_config(self):
        cfg_dict = {
            k: v for k, v in self.__dict__.items()
            if not k.startswith("_") and k != "config_file"
        }
        with open(self.config_file, "w") as f:
            yaml.dump(cfg_dict, f, sort_keys=False)
        logger.info(f"Configuration saved to {self.config_file}")

    def __repr__(self):
        cfg_dict = {
            k: v for k, v in self.__dict__.items()
            if not k.startswith("_") and k != "config_file"
        }
        return json.dumps(cfg_dict, indent=2, default=str)

CONFIG = Config()

# =============================================================================
# FEATURES & LEAKAGE
# =============================================================================
NUMERIC_FEATURE_CANDIDATES = [
    "Temperature", "Humidity", "Rainfall",
    "Temperature_Anomaly", "Rainfall_Anomaly",
    "pH", "OrganicCarbon", "Nitrogen", "Phosphorus", "Potassium",
    "Sulphur", "Zinc", "Copper", "Boron", "Iron", "Manganese",
    "EC (Electrical Conductivity)", "SoilSalinityIndex",
    "SoilMoisture", "SoilPorosity", "BulkDensity", "CEC",
    "WaterHoldingCapacity", "NDVI", "EVI",
    "SoilFertilityIndex", "ErosionRisk",
    # alternate schema
    "Temperature_C", "Humidity_pct", "Rainfall_mm",
    "Organic_Carbon_pct", "Nitrogen_kg_ha", "Phosphorus_kg_ha",
    "Potassium_kg_ha", "Zinc_mg_kg", "Boron_mg_kg", "Iron_mg_kg",
    "Manganese_mg_kg", "Soil_Moisture_pct", "Bulk_Density",
    "CEC_meq_100g", "Water_Holding_Capacity_pct",
    "NDVI_Index", "EVI_Index",
]

CATEGORICAL_FEATURE_CANDIDATES = [
    "SoilTexture", "SoilDepthCategory",
    "Soil_Texture", "Soil_Depth",
]

LEAKAGE_COLUMNS = [
    "Recommended_Crop","Crop","Suitable","Suitability_Score","Suitability_Flag",
    "Yield","Expected_Yield_q_per_ha","Cost_of_Cultivation",
    "Expected_Selling_Price","Expected_Price","Expected_Price_per_quintal_INR",
    "Expected_Profit","Fertilizer_Recommendation","Fertilizer_Note",
    "Mandi_Suggestion","Risk_Index","Recommended_Crop_Group",
    "Recommended_Crop_Primary_Season","MarketAccessIndex","IrrigationAccessIndex",
    "FertilizerAffordabilityIndex","CWR_mm","GDD","Rainfall_Class","pH_Class",
    "FarmSizeClass",
]

# =============================================================================
# UTIL
# =============================================================================
def _dedupe_preserve_order(cols: List[str]) -> List[str]:
    seen, out = set(), []
    for c in cols:
        if c not in seen:
            seen.add(c); out.append(c)
    return out

# =============================================================================
# DATA LOADING / CLEANING
# =============================================================================
def load_and_clean_data(path: str) -> pd.DataFrame:
    logger.info(f"Loading dataset from {path}...")
    if not os.path.exists(path):
        raise FileNotFoundError(path)

    df = pd.read_csv(path)
    logger.info(f"Loaded {len(df):,} rows and {len(df.columns)} columns")

    cols_to_drop = [
        c for c in LEAKAGE_COLUMNS
        if c in df.columns and c not in ("Crop", "Recommended_Crop")
    ]
    if cols_to_drop:
        logger.info(f"Dropping leakage/helper columns: {cols_to_drop}")
        df = df.drop(columns=cols_to_drop)

    dupes = df.duplicated().sum()
    if dupes:
        logger.info(f"Dropping {dupes:,} duplicate rows")
        df = df.drop_duplicates()

    # coarse missing fill
    for col in df.columns:
        if df[col].isna().sum() == 0:
            continue
        if df[col].dtype == "object":
            mode_vals = df[col].mode()
            df[col] = df[col].fillna(mode_vals[0] if len(mode_vals) else "Unknown")
        else:
            df[col] = df[col].fillna(df[col].median())

    return df

def validate_data(df: pd.DataFrame) -> Tuple[bool, List[str]]:
    logger.info("Starting data validation...")
    issues = []

    target_col = "Recommended_Crop" if "Recommended_Crop" in df.columns else \
                 "Crop" if "Crop" in df.columns else None
    if target_col is None:
        return False, ["No target column found ('Recommended_Crop' or 'Crop')."]

    if df[target_col].isna().sum() > 0:
        issues.append(f"Target column {target_col} has missing values.")

    if "pH" in df.columns:
        bad_ph = ((df["pH"] < CONFIG.min_ph) | (df["pH"] > CONFIG.max_ph)).sum()
        if bad_ph > 0:
            issues.append(f"{bad_ph} pH values outside bounds.")

    for tcol in ["Temperature", "Temperature_C"]:
        if tcol in df.columns:
            bad = ((df[tcol] < CONFIG.min_temperature_c) |
                   (df[tcol] > CONFIG.max_temperature_c)).sum()
            if bad > 0:
                issues.append(f"{bad} {tcol} values outside bounds.")

    for rcol in ["Rainfall", "Rainfall_mm"]:
        if rcol in df.columns:
            bad = (df[rcol] > CONFIG.max_rainfall_mm).sum()
            if bad > 0:
                issues.append(f"{bad} {rcol} values above max_rainfall_mm.")

    class_counts = df[target_col].value_counts()
    tiny = class_counts[class_counts < 10]
    if not tiny.empty:
        issues.append(f"Tiny classes: {tiny.to_dict()}")

    if issues:
        for x in issues:
            logger.warning(f"  - {x}")
        return False, issues

    logger.info("[OK] Data validation passed")
    return True, []

def generate_data_quality_report(df: pd.DataFrame) -> Dict:
    report = {
        "total_rows": len(df),
        "total_columns": len(df.columns),
        "missing_values": {c:int(v) for c,v in df.isna().sum().items() if v>0},
        "duplicates": int(df.duplicated().sum())
    }
    out = Path(CONFIG.logs_dir) / f"data_quality_{datetime.now():%Y%m%d_%H%M%S}.json"
    with open(out, "w") as f:
        json.dump(report, f, indent=2)
    logger.info(f"[OK] Data quality report saved to {out}")
    return report

# =============================================================================
# FEATURE ENGINEERING
# =============================================================================
def feature_engineering(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()

    def has(*cols):
        return all(c in df.columns for c in cols)

    if CONFIG.create_ratio_features and has("Nitrogen", "Phosphorus", "Potassium"):
        eps = 1e-6
        df["N_to_P"] = df["Nitrogen"] / (df["Phosphorus"] + eps)
        df["P_to_K"] = df["Phosphorus"] / (df["Potassium"] + eps)
        df["NPK_sum"] = df["Nitrogen"] + df["Phosphorus"] + df["Potassium"]

    if CONFIG.log_transform_micronutrients:
        for col in ["Zinc","Copper","Boron","Iron","Manganese","Sulphur"]:
            if col in df.columns:
                df[f"log1p_{col}"] = np.log1p(df[col].clip(lower=0))

    if CONFIG.create_climate_anomalies:
        for base, new in [("Temperature","Temperature_Anomaly_Z"),
                          ("Rainfall","Rainfall_Anomaly_Z")]:
            if base in df.columns and new not in df.columns:
                mu, sd = df[base].mean(), df[base].std() + 1e-6
                df[new] = (df[base] - mu) / sd

    return df

# =============================================================================
# FEATURE LISTS + PREPROCESS
# =============================================================================
def build_feature_lists(df: pd.DataFrame) -> Tuple[List[str], List[str]]:
    numeric_features = _dedupe_preserve_order([c for c in NUMERIC_FEATURE_CANDIDATES if c in df.columns])
    categorical_features = _dedupe_preserve_order([c for c in CATEGORICAL_FEATURE_CANDIDATES if c in df.columns])

    logger.info(f"Selected numeric features ({len(numeric_features)}): {numeric_features}")
    logger.info(f"Selected categorical features ({len(categorical_features)}): {categorical_features}")
    return numeric_features, categorical_features

def preprocess_features(
    df: pd.DataFrame,
    numeric_features: List[str],
    categorical_features: List[str],
) -> Tuple[pd.DataFrame, Dict]:

    feature_cols = _dedupe_preserve_order(numeric_features + categorical_features)
    X = df[feature_cols].copy()

    meta = {
        "numeric_features": numeric_features,
        "categorical_features": categorical_features,
        "numeric_medians": {},
        "numeric_clip_bounds": {},
        "categorical_modes": {},
        "feature_names": feature_cols,
    }

    for col in numeric_features:
        if col not in X.columns:
            continue
        col_data = X[col]
        if isinstance(col_data, pd.DataFrame):
            col_data = col_data.iloc[:, 0]

        col_data = pd.to_numeric(col_data, errors="coerce")
        med = col_data.median()
        col_data = col_data.fillna(med)
        ql, qh = col_data.quantile(0.01), col_data.quantile(0.99)
        col_data = col_data.clip(ql, qh)

        X[col] = col_data
        meta["numeric_medians"][col] = float(med)
        meta["numeric_clip_bounds"][col] = (float(ql), float(qh))

    for col in categorical_features:
        if col not in X.columns:
            continue
        mode_vals = X[col].mode()
        fill_val = mode_vals[0] if len(mode_vals) else "Unknown"
        X[col] = X[col].fillna(fill_val).astype(str)
        meta["categorical_modes"][col] = fill_val

    logger.info(f"[OK] Preprocessing complete. Final feature matrix: {X.shape}")
    return X, meta

def apply_preprocessing_to_input(input_df: pd.DataFrame, meta: Dict) -> pd.DataFrame:
    X = pd.DataFrame(index=input_df.index)

    for col in meta["numeric_features"]:
        vals = pd.to_numeric(input_df.get(col, np.nan), errors="coerce")
        med = meta["numeric_medians"][col]
        ql, qh = meta["numeric_clip_bounds"][col]
        X[col] = vals.fillna(med).clip(ql, qh)

    for col in meta["categorical_features"]:
        fill_val = meta["categorical_modes"][col]
        X[col] = input_df.get(col, None)
        X[col] = X[col].fillna(fill_val).astype(str)

    return X[meta["feature_names"]]

# =============================================================================
# THRESHOLD-BASED DERIVATIONS (NO TRAINING)
# =============================================================================
def categorize_ph(ph: float) -> str:
    if pd.isna(ph): return "Unknown"
    if ph < 5.5: return "Strongly_Acidic"
    if ph < 6.5: return "Acidic"
    if ph < 7.5: return "Neutral"
    if ph < 8.5: return "Alkaline"
    return "Strongly_Alkaline"

def categorize_rainfall(r: float) -> str:
    if pd.isna(r): return "Unknown"
    if r < 500: return "Low"
    if r < 1000: return "Moderate"
    if r < 1500: return "High"
    return "Very_High"

def derive_suitability_flag(row: pd.Series) -> str:
    ph = row.get("pH", np.nan)
    sfi = row.get("SoilFertilityIndex", np.nan)
    erosion = row.get("ErosionRisk", np.nan)

    ph_ok = 5.5 <= (ph if not pd.isna(ph) else 6.5) <= 8.5
    sfi_ok = not pd.isna(sfi) and sfi >= 0.4
    erosion_ok = pd.isna(erosion) or erosion < 0.7

    if ph_ok and sfi_ok and erosion_ok: return "High"
    if ph_ok and (sfi_ok or erosion_ok): return "Moderate"
    return "Low"

def derive_categorical_recommendations(input_df: pd.DataFrame) -> pd.DataFrame:
    out = pd.DataFrame(index=input_df.index)
    if "pH" in input_df.columns:
        out["pH_Class"] = input_df["pH"].apply(categorize_ph)

    rcol = "Rainfall" if "Rainfall" in input_df.columns else \
           "Rainfall_mm" if "Rainfall_mm" in input_df.columns else None
    if rcol:
        out["Rainfall_Class"] = input_df[rcol].apply(categorize_rainfall)

    out["Suitability_Flag"] = input_df.apply(derive_suitability_flag, axis=1)
    return out

# =============================================================================
# CATBOOST PARAM SANITIZER (GPU/BOOTSTRAP SAFE)
# =============================================================================
def sanitize_catboost_params(params: Dict, use_gpu: bool) -> Dict:
    """Make CatBoost params mutually compatible (esp. GPU + bootstrap rules)."""
    p = params.copy()

    # ---- enforce task type ----
    if use_gpu:
        p["task_type"] = "GPU"
        p["devices"] = str(getattr(CONFIG, "gpu_devices", "0"))
        # rsm not supported for MultiClass GPU
        p.pop("rsm", None)
    else:
        p["task_type"] = "CPU"
        p.pop("devices", None)

    # ---- bootstrap compatibility (case-robust) ----
    bt = str(p.get("bootstrap_type", "Bayesian")).lower()

    if bt == "bayesian":
        p.pop("subsample", None)
        p.setdefault("bagging_temperature", getattr(CONFIG, "catboost_bagging_temperature", 0.6))
    else:
        p.pop("bagging_temperature", None)
        p.setdefault("subsample", getattr(CONFIG, "catboost_subsample", 0.85))

    # ---- safe defaults ----
    p.setdefault("loss_function", "MultiClass")
    p.setdefault("eval_metric", getattr(CONFIG, "catboost_eval_metric", "Accuracy"))
    p.setdefault("random_seed", getattr(CONFIG, "random_seed", 42))
    p.setdefault("verbose", getattr(CONFIG, "catboost_log_period", 50))
    p.setdefault("early_stopping_rounds", getattr(CONFIG, "catboost_early_stopping_rounds", 150))
    p.setdefault("od_type", "Iter")
    p.setdefault("allow_writing_files", False)

    return p

def make_catboost_params(class_weight_dict: Dict[int, float]) -> Dict:
    p = dict(
        iterations=CONFIG.catboost_iterations,
        learning_rate=CONFIG.catboost_learning_rate,
        depth=CONFIG.catboost_depth,
        l2_leaf_reg=CONFIG.catboost_l2_leaf_reg,
        random_strength=getattr(CONFIG, "catboost_random_strength", 2.0),
        min_data_in_leaf=getattr(CONFIG, "catboost_min_data_in_leaf", 30),
        border_count=getattr(CONFIG, "catboost_border_count", 254),
        bootstrap_type=getattr(CONFIG, "catboost_bootstrap_type", "Bayesian"),
        class_weights=class_weight_dict,
        loss_function="MultiClass",
        eval_metric=CONFIG.catboost_eval_metric,
        random_seed=CONFIG.random_seed,
        early_stopping_rounds=CONFIG.catboost_early_stopping_rounds,
        verbose=CONFIG.catboost_log_period,
    )

    # rsm only for CPU (GPU multiclass doesn't support it)
    if not CONFIG.use_gpu:
        p["rsm"] = getattr(CONFIG, "catboost_rsm", 0.85)

    return sanitize_catboost_params(p, CONFIG.use_gpu)

# =============================================================================
# OPTIONAL OPTUNA TUNING (FAST + PRUNING)
# =============================================================================
def optuna_tune(
    X_train: pd.DataFrame,
    y_train: np.ndarray,
    cat_feature_indices: List[int],
    base_params: Dict,
) -> Dict:
    try:
        import optuna
    except Exception:
        logger.warning("Optuna not installed. Skipping hyperparam tuning.")
        return base_params

    logger.info("Starting Optuna hyperparameter tuning...")
    skf = StratifiedKFold(
        n_splits=CONFIG.n_folds, shuffle=True, random_state=CONFIG.random_seed
    )

    def objective(trial):
        params = base_params.copy()

        params.update({
            "depth": trial.suggest_int("depth", 6, 10),
            "learning_rate": trial.suggest_float("learning_rate", 0.015, 0.06, log=True),
            "l2_leaf_reg": trial.suggest_float("l2_leaf_reg", 3.0, 12.0, log=True),
            "random_strength": trial.suggest_float("random_strength", 1.0, 3.0),
            "min_data_in_leaf": trial.suggest_int("min_data_in_leaf", 15, 60),
        })

        # rsm only on CPU
        if not CONFIG.use_gpu:
            params["rsm"] = trial.suggest_float("rsm", 0.7, 1.0)

        bt = str(params.get("bootstrap_type", "Bayesian")).lower()
        if bt == "bayesian":
            params["bagging_temperature"] = trial.suggest_float("bagging_temperature", 0.0, 1.0)
            params.pop("subsample", None)
        else:
            params["subsample"] = trial.suggest_float("subsample", 0.6, 1.0)
            params.pop("bagging_temperature", None)

        params = sanitize_catboost_params(params, CONFIG.use_gpu)

        fold_scores = []
        for fold, (tr_idx, va_idx) in enumerate(skf.split(X_train, y_train), start=1):
            X_tr, X_va = X_train.iloc[tr_idx], X_train.iloc[va_idx]
            y_tr, y_va = y_train[tr_idx], y_train[va_idx]

            train_pool = Pool(X_tr, y_tr, cat_features=cat_feature_indices)
            val_pool   = Pool(X_va, y_va, cat_features=cat_feature_indices)

            m = CatBoostClassifier(**params)
            m.fit(train_pool, eval_set=val_pool, use_best_model=True)

            preds = m.predict(X_va).reshape(-1)
            acc = accuracy_score(y_va, preds)
            fold_scores.append(acc)

            trial.report(acc, step=fold)
            if trial.should_prune():
                raise optuna.TrialPruned()

        return float(np.mean(fold_scores))

    pruner = optuna.pruners.MedianPruner(n_startup_trials=5, n_warmup_steps=1)
    study = optuna.create_study(direction="maximize", pruner=pruner)
    study.optimize(objective, n_trials=CONFIG.optuna_trials, timeout=CONFIG.optuna_timeout_sec)

    best = base_params.copy()
    best.update(study.best_params)
    best = sanitize_catboost_params(best, CONFIG.use_gpu)

    logger.info(f"Optuna best score: {study.best_value:.4f}")
    logger.info(f"Optuna best params: {study.best_params}")
    return best

# =============================================================================
# TRAINING WITH CV
# =============================================================================
def train_model_with_cv(
    df: pd.DataFrame
) -> Tuple[CatBoostClassifier, Dict, pd.DataFrame, np.ndarray, LabelEncoder, Dict]:

    logger.info("=" * 70)
    logger.info("STARTING MODEL TRAINING PIPELINE")
    logger.info("=" * 70)

    target_col = "Recommended_Crop" if "Recommended_Crop" in df.columns else \
                 "Crop" if "Crop" in df.columns else None
    if target_col is None:
        raise ValueError("No 'Recommended_Crop' or 'Crop' column found for target.")

    y_raw = df[target_col].astype(str).copy()

    numeric_features, categorical_features = build_feature_lists(df)
    X_raw, preprocessing_meta = preprocess_features(df, numeric_features, categorical_features)

    # Safety: never allow target to sneak into features
    if target_col in X_raw.columns:
        X_raw = X_raw.drop(columns=[target_col])

    le = LabelEncoder()
    y = le.fit_transform(y_raw)
    logger.info(f"Number of classes: {len(le.classes_)}")

    X_train, X_test, y_train, y_test = train_test_split(
        X_raw, y,
        test_size=CONFIG.test_size,
        stratify=y,
        random_state=CONFIG.random_seed
    )

    # ---- robust class weights ----
    class_counts = np.bincount(y_train)
    class_counts = np.maximum(class_counts, 1)  # prevents divide-by-zero
    class_weights = len(y_train) / (len(class_counts) * class_counts)
    class_weight_dict = {int(i): float(w) for i, w in enumerate(class_weights)}

    # boost weak classes if enabled
    if getattr(CONFIG, "boost_weak_classes", False):
        for cname in getattr(CONFIG, "weak_class_names", []):
            if cname in le.classes_:
                idx = int(np.where(le.classes_ == cname)[0][0])
                class_weight_dict[idx] *= float(getattr(CONFIG, "weak_class_boost_factor", 1.5))

    cat_feature_indices = [X_train.columns.get_loc(c) for c in categorical_features]
    logger.info(f"CatBoost categorical feature indices: {cat_feature_indices}")

    base_params = make_catboost_params(class_weight_dict)

    best_params = base_params
    if CONFIG.optimize_hyperparams:
        best_params = optuna_tune(X_train, y_train, cat_feature_indices, base_params)

    skf = StratifiedKFold(
        n_splits=CONFIG.n_folds, shuffle=True, random_state=CONFIG.random_seed
    )

    fold_acc, fold_f1, best_iters = [], [], []
    logger.info("=" * 70)
    logger.info("CROSS-VALIDATION")
    logger.info("=" * 70)

    for fold, (tr_idx, va_idx) in enumerate(skf.split(X_train, y_train), start=1):
        X_tr, X_va = X_train.iloc[tr_idx], X_train.iloc[va_idx]
        y_tr, y_va = y_train[tr_idx], y_train[va_idx]

        train_pool = Pool(X_tr, y_tr, cat_features=cat_feature_indices)
        val_pool   = Pool(X_va, y_va, cat_features=cat_feature_indices)

        model = CatBoostClassifier(**best_params)
        logger.info(f"Fold {fold}/{CONFIG.n_folds}: training...")
        t0 = time.time()
        model.fit(train_pool, eval_set=val_pool, use_best_model=True)
        logger.info(f"Fold {fold} train time: {time.time() - t0:.1f}s")

        preds = model.predict(X_va).reshape(-1)
        acc = accuracy_score(y_va, preds)
        mf1 = f1_score(y_va, preds, average="macro")

        fold_acc.append(acc)
        fold_f1.append(mf1)
        best_iters.append(model.get_best_iteration())

        logger.info(
            f"Fold {fold}: Accuracy={acc:.4f}, Macro-F1={mf1:.4f}, best_iter={model.get_best_iteration()}"
        )

    logger.info("=" * 70)
    logger.info("CV SUMMARY")
    logger.info("=" * 70)
    logger.info(f"Mean CV Accuracy: {np.mean(fold_acc):.4f} ± {np.std(fold_acc):.4f}")
    logger.info(f"Mean CV Macro F1: {np.mean(fold_f1):.4f} ± {np.std(fold_f1):.4f}")

    # ---- median best-iter final fit ----
    median_best_iter = int(np.median(best_iters))
    best_params_final = best_params.copy()
    best_params_final["iterations"] = max(median_best_iter + 50, 200)
    best_params_final = sanitize_catboost_params(best_params_final, CONFIG.use_gpu)

    logger.info("=" * 70)
    logger.info("TRAINING FINAL MODEL")
    logger.info("=" * 70)

    train_pool_full = Pool(X_train, y_train, cat_features=cat_feature_indices)
    val_pool_full   = Pool(X_test,  y_test,  cat_features=cat_feature_indices)

    final_model = CatBoostClassifier(**best_params_final)
    logger.info(f"Final CatBoost params: {best_params_final}")

    final_model.fit(train_pool_full, eval_set=val_pool_full, use_best_model=True)

    metrics = comprehensive_evaluation(final_model, X_test, y_test, le)

    save_model_with_metadata(
        final_model, le, X_train, best_params_final,
        metrics, preprocessing_meta, categorical_features
    )

    return final_model, preprocessing_meta, X_test, y_test, le, metrics

# =============================================================================
# EVALUATION
# =============================================================================
def comprehensive_evaluation(
    model: CatBoostClassifier,
    X_test: pd.DataFrame,
    y_test: np.ndarray,
    le: LabelEncoder
) -> Dict:

    preds = np.asarray(model.predict(X_test)).reshape(-1)
    proba = np.asarray(model.predict_proba(X_test))

    acc = accuracy_score(y_test, preds)
    bal_acc = balanced_accuracy_score(y_test, preds)
    macro_f1 = f1_score(y_test, preds, average="macro")
    weighted_f1 = f1_score(y_test, preds, average="weighted")

    k3 = min(3, proba.shape[1])
    k5 = min(5, proba.shape[1])
    top3 = top_k_accuracy_score(y_test, proba, k=k3)
    top5 = top_k_accuracy_score(y_test, proba, k=k5)

    logger.info("=" * 70)
    logger.info("COMPREHENSIVE MODEL EVALUATION")
    logger.info("=" * 70)
    logger.info(f"Accuracy:            {acc:.4f} ({acc*100:.2f}%)")
    logger.info(f"Balanced Accuracy:   {bal_acc:.4f} ({bal_acc*100:.2f}%)")
    logger.info(f"Macro F1-Score:      {macro_f1:.4f}")
    logger.info(f"Weighted F1-Score:   {weighted_f1:.4f}")
    logger.info(f"Top-{k3} Accuracy:     {top3:.4f} ({top3*100:.2f}%)")
    logger.info(f"Top-{k5} Accuracy:     {top5:.4f} ({top5*100:.2f}%)")

    print(classification_report(y_test, preds, target_names=le.classes_, zero_division=0))

    cm = confusion_matrix(y_test, preds)
    per_class_acc = cm.diagonal() / np.maximum(cm.sum(axis=1), 1)
    worst_idx = np.argsort(per_class_acc)[:5]

    logger.info("=" * 70)
    logger.info("WORST PERFORMING CROPS")
    logger.info("=" * 70)
    for idx in worst_idx:
        logger.info(f"{le.classes_[idx]:20s}: {per_class_acc[idx]*100:5.1f}%")

    return {
        "accuracy": float(acc),
        "balanced_accuracy": float(bal_acc),
        "macro_f1": float(macro_f1),
        "weighted_f1": float(weighted_f1),
        "top3_accuracy": float(top3),
        "top5_accuracy": float(top5),
        "per_class_accuracy": per_class_acc.tolist(),
        "confusion_matrix": cm.tolist(),
    }

# =============================================================================
# SAVE ARTIFACTS
# =============================================================================
def save_model_with_metadata(
    model: CatBoostClassifier,
    le: LabelEncoder,
    X_train: pd.DataFrame,
    params: Dict,
    metrics: Dict,
    preprocessing_meta: Dict,
    categorical_features: List[str],
) -> Tuple[str, str, str]:

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    data_hash = hashlib.md5(
        pd.util.hash_pandas_object(X_train, index=True).values
    ).hexdigest()[:8]

    model_dir = Path(CONFIG.model_dir)
    model_dir.mkdir(exist_ok=True)

    model_path = model_dir / f"krishimitra_physical_v{timestamp}_{data_hash}.cbm"
    encoder_path = model_dir / f"label_encoder_v{timestamp}.pkl"
    metadata_path = model_dir / f"metadata_v{timestamp}.json"

    model.save_model(str(model_path))
    import joblib
    joblib.dump(le, encoder_path)

    metadata = {
        "version": timestamp,
        "data_hash": data_hash,
        "training_samples": len(X_train),
        "feature_names": list(X_train.columns),
        "categorical_features": categorical_features,
        "class_names": list(le.classes_),
        "metrics": metrics,
        "hyperparameters": params,
        "preprocessing_meta": preprocessing_meta,
        "config": {
            k: v for k, v in CONFIG.__dict__.items()
            if not k.startswith("_") and k != "config_file"
        },
    }

    with open(metadata_path, "w") as f:
        json.dump(metadata, f, indent=2)

    logger.info("=" * 70)
    logger.info("MODEL ARTIFACTS SAVED")
    logger.info("=" * 70)
    logger.info(f"Model:    {model_path}")
    logger.info(f"Encoder:  {encoder_path}")
    logger.info(f"Metadata: {metadata_path}")

    return str(model_path), str(encoder_path), str(metadata_path)

# =============================================================================
# LOAD LATEST + PREDICT
# =============================================================================
def load_latest_metadata_and_model(
    model_path: Optional[str] = None,
    metadata_path: Optional[str] = None,
    encoder_path: Optional[str] = None,
) -> Tuple[CatBoostClassifier, Dict, LabelEncoder]:

    model_dir = Path(CONFIG.model_dir)

    if metadata_path is None:
        metas = sorted(model_dir.glob("metadata_v*.json"))
        if not metas:
            raise FileNotFoundError("No metadata_v*.json found in models/. Train first.")
        metadata_path = str(metas[-1])

    if model_path is None:
        cbms = sorted(model_dir.glob("krishimitra_physical_v*.cbm"))
        if not cbms:
            raise FileNotFoundError("No krishimitra_physical_v*.cbm found in models/. Train first.")
        model_path = str(cbms[-1])

    if encoder_path is None:
        encs = sorted(model_dir.glob("label_encoder_v*.pkl"))
        if not encs:
            raise FileNotFoundError("No label_encoder_v*.pkl found in models/. Train first.")
        encoder_path = str(encs[-1])

    model = CatBoostClassifier()
    model.load_model(model_path)

    import joblib
    le = joblib.load(encoder_path)

    with open(metadata_path, "r") as f:
        meta = json.load(f)

    return model, meta, le

def predict_crops(
    input_data: Union[Dict, pd.DataFrame],
    model: Optional[CatBoostClassifier] = None,
    metadata: Optional[Dict] = None,
    le: Optional[LabelEncoder] = None,
    top_n: Optional[int] = None,
) -> Dict:

    if top_n is None:
        top_n = CONFIG.top_n_recommendations

    if model is None or metadata is None or le is None:
        model, metadata, le = load_latest_metadata_and_model()

    raw_df = pd.DataFrame([input_data]) if isinstance(input_data, dict) else input_data.copy()

    pre_meta = metadata["preprocessing_meta"]
    X = apply_preprocessing_to_input(raw_df, pre_meta)

    cat_feats = [
        X.columns.get_loc(c)
        for c in pre_meta["categorical_features"]
        if c in X.columns
    ]
    pool = Pool(X, cat_features=cat_feats)

    probs = model.predict_proba(pool)[0]
    idxs = np.argsort(probs)[::-1][:top_n]

    recs = []
    for r, i in enumerate(idxs, 1):
        crop = le.inverse_transform([i])[0]
        conf = float(probs[i])
        recs.append({"rank": r, "crop": crop, "confidence": conf})

    derived = derive_categorical_recommendations(raw_df)

    return {
        "input": raw_df.to_dict("records")[0],
        "recommendations": recs,
        "derived_categorical_info": derived.to_dict("records")[0],
    }

# =============================================================================
# MAIN
# =============================================================================
def main():
    logger.info("=" * 70)
    logger.info("KRISHIMITRA.AI - PHYSICAL & CHEMICAL ML PIPELINE (GPU)")
    logger.info("=" * 70)
    logger.info(f"Configuration:\n{CONFIG}")

    df = load_and_clean_data(CONFIG.data_path)
    df = feature_engineering(df)
    generate_data_quality_report(df)

    ok, issues = validate_data(df)
    if not ok:
        raise ValueError(f"Validation failed: {issues}")


    model, pre_meta, X_test, y_test, le, metrics = train_model_with_cv(df)

    logger.info("=" * 70)
    logger.info("SAMPLE INFERENCE")
    logger.info("=" * 70)

    sample_raw = X_test.iloc[[0]].copy()
    result = predict_crops(
        sample_raw.to_dict("records")[0],
        model=model,
        metadata={"preprocessing_meta": pre_meta},
        le=le
    )

    for rec in result["recommendations"]:
        logger.info(f"{rec['rank']}. {rec['crop']}  ({rec['confidence']*100:.1f}%)")
    logger.info(result["derived_categorical_info"])

    return model, le, metrics

if __name__ == "__main__":
    model, le, metrics = main()
    print("\n" + "=" * 70)
    print("PHYSICAL & CHEMICAL MODEL TRAINED SUCCESSFULLY")
    print("=" * 70)
    print(f"Accuracy: {metrics['accuracy']:.4f}")
    print(f"Top-3 Accuracy: {metrics['top3_accuracy']:.4f}")
    print("=" * 70)
