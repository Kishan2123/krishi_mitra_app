class MarketPrice {
  const MarketPrice({
    required this.cropName,
    required this.currentPrice,
    required this.previousPrice,
    required this.market,
    required this.date,
    required this.demand,
    this.arrivalDate,
  });

  final String cropName;
  final double currentPrice;
  final double previousPrice;
  final String market;
  final String date;
  final String demand;
  final DateTime? arrivalDate;

  factory MarketPrice.fromAgmarknet(Map<String, dynamic> json, {double? previousPrice}) {
    final current = _asDouble(json['modal_price']);
    final commodity = (json['commodity'] as String? ?? '').trim();
    final market = (json['market'] as String? ?? '').trim();
    final arrival = parseArrivalDate(json['arrival_date'] as String?);
    final resolvedPrevious = previousPrice ?? current;

    return MarketPrice(
      cropName: commodity.isEmpty ? 'Unknown crop' : commodity,
      currentPrice: current,
      previousPrice: resolvedPrevious,
      market: market.isEmpty ? 'Unknown market' : market,
      date: formatArrival(arrival),
      demand: _demandFromChange(current, resolvedPrevious),
      arrivalDate: arrival,
    );
  }

  MarketPrice copyWith({
    String? cropName,
    double? currentPrice,
    double? previousPrice,
    String? market,
    String? date,
    String? demand,
    DateTime? arrivalDate,
  }) {
    return MarketPrice(
      cropName: cropName ?? this.cropName,
      currentPrice: currentPrice ?? this.currentPrice,
      previousPrice: previousPrice ?? this.previousPrice,
      market: market ?? this.market,
      date: date ?? this.date,
      demand: demand ?? this.demand,
      arrivalDate: arrivalDate ?? this.arrivalDate,
    );
  }

  static double toDouble(dynamic value) => _asDouble(value);

  static double _asDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  static DateTime? parseArrivalDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final parts = raw.split('/');
    if (parts.length == 3) {
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day != null && month != null && year != null) {
        return DateTime.utc(year, month, day);
      }
    }
    return DateTime.tryParse(raw);
  }

  static String formatArrival(DateTime? date) {
    if (date == null) return 'Updated recently';
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$day-$month-${date.year}';
  }

  static String _demandFromChange(double current, double previous) {
    final change = previous == 0 ? 0 : ((current - previous) / previous) * 100;
    if (change >= 5) return 'High';
    if (change <= -5) return 'Low';
    return 'Medium';
  }
}
