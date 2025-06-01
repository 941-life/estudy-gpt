class Event {
  final DateTime date;
  final String title;

  const Event({required this.date, required this.title});

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'title': title,
  };
}
