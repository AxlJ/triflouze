class Expense {
  final String id;
  final String title;
  final double amount;
  final String currency;
  final String category;
  final List<String> forMembers;
  final DateTime date;
  final List<String> tags;
  final String comment;
  final String addedBy;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.currency,
    required this.category,
    required this.forMembers,
    required this.date,
    this.tags = const [],
    this.comment = '',
    this.addedBy = '',
  });

  Expense copyWith({
    String? title,
    double? amount,
    String? currency,
    String? category,
    List<String>? forMembers,
    DateTime? date,
    List<String>? tags,
    String? comment,
    String? addedBy,
  }) {
    return Expense(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      forMembers: forMembers ?? this.forMembers,
      date: date ?? this.date,
      tags: tags ?? this.tags,
      comment: comment ?? this.comment,
      addedBy: addedBy ?? this.addedBy,
    );
  }
}
