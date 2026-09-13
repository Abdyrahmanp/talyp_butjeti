class TransactionModel {
  final String id;
  final double amount;
  final String categoryId;
  final String title;
  final String? note;
  final DateTime date;
  final String type; // 'expense' or 'income'

  const TransactionModel({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.title,
    this.note,
    required this.date,
    required this.type,
  });

  bool get isExpense => type == 'expense';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category_id': categoryId,
      'title': title,
      'note': note,
      'date': date.toIso8601String(),
      'type': type,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      amount: (map['amount'] as num).toDouble(),
      categoryId: map['category_id'] as String,
      title: map['title'] as String,
      note: map['note'] as String?,
      date: DateTime.parse(map['date'] as String),
      type: map['type'] as String,
    );
  }

  TransactionModel copyWith({
    String? id,
    double? amount,
    String? categoryId,
    String? title,
    String? note,
    DateTime? date,
    String? type,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      note: note ?? this.note,
      date: date ?? this.date,
      type: type ?? this.type,
    );
  }
}
