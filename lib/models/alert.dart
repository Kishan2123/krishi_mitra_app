class Alert {
  final String category;
  final String message;
  final String severity;
  final String time;

  Alert({
    required this.category,
    required this.message,
    required this.severity,
    required this.time,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      category: json['category'],
      message: json['message'],
      severity: json['severity'],
      time: json['time'],
    );
  }
}