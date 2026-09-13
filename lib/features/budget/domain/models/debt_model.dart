class DebtModel {
  final String id;
  final String personName;
  final double amount;
  final String type; // 'lent' or 'borrowed'
  final DateTime? dueDate;
  final String? note;
  final bool isSettled;
  final DateTime createdAt;

  const DebtModel({
    required this.id,
    required this.personName,
    required this.amount,
    required this.type,
    this.dueDate,
    this.note,
    required this.isSettled,
    required this.createdAt,
  });

  bool get isLent => type == 'lent';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'person_name': personName,
      'amount': amount,
      'type': type,
      'due_date': dueDate?.toIso8601String(),
      'note': note,
      'is_settled': isSettled ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory DebtModel.fromMap(Map<String, dynamic> map) {
    return DebtModel(
      id: map['id'] as String,
      personName: map['person_name'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] as String,
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date'] as String) : null,
      note: map['note'] as String?,
      isSettled: (map['is_settled'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  DebtModel copyWith({
    String? id,
    String? personName,
    double? amount,
    String? type,
    DateTime? dueDate,
    String? note,
    bool? isSettled,
    DateTime? createdAt,
  }) {
    return DebtModel(
      id: id ?? this.id,
      personName: personName ?? this.personName,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      dueDate: dueDate ?? this.dueDate,
      note: note ?? this.note,
      isSettled: isSettled ?? this.isSettled,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
