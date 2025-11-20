class PestDetectionResult {
  final String pest;
  final int confidence;
  final String severity;
  final String treatment;

  PestDetectionResult({
    required this.pest,
    required this.confidence,
    required this.severity,
    required this.treatment,
  });

  factory PestDetectionResult.fromJson(Map<String, dynamic> json) {
    return PestDetectionResult(
      pest: json['pest'],
      confidence: json['confidence'],
      severity: json['severity'],
      treatment: json['treatment'],
    );
  }
}