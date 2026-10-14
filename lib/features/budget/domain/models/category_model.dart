import 'package:flutter/material.dart';
import '../../../../core/utils/icon_helper.dart';

class CategoryModel {
  final String id;
  final String nameTk;
  final String nameEn;
  final int iconCode;
  final String colorHex;
  final String type; // 'expense' or 'income'

  const CategoryModel({
    required this.id,
    required this.nameTk,
    required this.nameEn,
    required this.iconCode,
    required this.colorHex,
    required this.type,
  });

  IconData get icon => IconHelper.getIcon(iconCode);

  Color get color {
    final buffer = StringBuffer();
    if (colorHex.length == 6 || colorHex.length == 7) buffer.write('ff');
    buffer.write(colorHex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  String getName(String locale) => locale == 'en' ? nameEn : nameTk;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name_tk': nameTk,
      'name_en': nameEn,
      'icon_code': iconCode,
      'color_hex': colorHex,
      'type': type,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      nameTk: map['name_tk'] as String,
      nameEn: map['name_en'] as String,
      iconCode: map['icon_code'] as int,
      colorHex: map['color_hex'] as String,
      type: map['type'] as String,
    );
  }
}
