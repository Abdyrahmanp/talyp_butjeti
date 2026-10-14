import 'package:flutter/material.dart';
import '../../../../core/utils/icon_helper.dart';

class SubscriptionModel {
  final String id;
  final String title;
  final double amount;
  final int dueDay; // 1-31
  final String categoryId;
  final bool isActive;
  final int iconCode;

  const SubscriptionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.dueDay,
    required this.categoryId,
    required this.isActive,
    required this.iconCode,
  });

  IconData get icon => IconHelper.getIcon(iconCode);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'due_day': dueDay,
      'category_id': categoryId,
      'is_active': isActive ? 1 : 0,
      'icon_code': iconCode,
    };
  }

  factory SubscriptionModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionModel(
      id: map['id'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      dueDay: map['due_day'] as int,
      categoryId: map['category_id'] as String,
      isActive: (map['is_active'] as int) == 1,
      iconCode: map['icon_code'] as int,
    );
  }

  SubscriptionModel copyWith({
    String? id,
    String? title,
    double? amount,
    int? dueDay,
    String? categoryId,
    bool? isActive,
    int? iconCode,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      dueDay: dueDay ?? this.dueDay,
      categoryId: categoryId ?? this.categoryId,
      isActive: isActive ?? this.isActive,
      iconCode: iconCode ?? this.iconCode,
    );
  }
}
