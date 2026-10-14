import 'package:flutter/material.dart';

class IconHelper {
  static const List<IconData> availableIcons = [
    Icons.restaurant,
    Icons.local_cafe,
    Icons.fastfood,
    Icons.shopping_bag,
    Icons.shopping_cart,
    Icons.directions_bus,
    Icons.directions_car,
    Icons.local_taxi,
    Icons.flight,
    Icons.pedal_bike,
    Icons.home,
    Icons.lightbulb,
    Icons.wifi,
    Icons.phone_android,
    Icons.water_drop,
    Icons.school,
    Icons.menu_book,
    Icons.fitness_center,
    Icons.sports_esports,
    Icons.movie,
    Icons.content_cut,
    Icons.medical_services,
    Icons.health_and_safety,
    Icons.card_giftcard,
    Icons.pets,
    Icons.work,
    Icons.account_balance_wallet,
    Icons.attach_money,
    Icons.payments,
    Icons.build,
    Icons.subscriptions,
    Icons.warning_amber,
    Icons.music_note,
    Icons.category,
    Icons.help_outline,
    Icons.savings,
    Icons.credit_card,
    Icons.receipt_long,
    Icons.celebration,
  ];

  static final Map<int, IconData> _iconMap = {
    for (final icon in availableIcons) icon.codePoint: icon,
  };

  /// Returns the corresponding [IconData] for a given code point.
  /// Falls back to [Icons.category] if not found.
  static IconData getIcon(int codePoint) {
    return _iconMap[codePoint] ?? Icons.category;
  }
}
