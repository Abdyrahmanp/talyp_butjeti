class UserProfileModel {
  final int id;
  final double monthlyBudget;
  final double scholarshipAmount;
  final int scholarshipPayDay; // 1-31
  final String currency;
  final String locale;
  final bool isDarkMode;

  const UserProfileModel({
    required this.id,
    required this.monthlyBudget,
    required this.scholarshipAmount,
    required this.scholarshipPayDay,
    required this.currency,
    required this.locale,
    required this.isDarkMode,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'monthly_budget': monthlyBudget,
      'scholarship_amount': scholarshipAmount,
      'scholarship_pay_day': scholarshipPayDay,
      'currency': currency,
      'locale': locale,
      'is_dark_mode': isDarkMode ? 1 : 0,
    };
  }

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      id: map['id'] as int,
      monthlyBudget: (map['monthly_budget'] as num).toDouble(),
      scholarshipAmount: (map['scholarship_amount'] as num).toDouble(),
      scholarshipPayDay: map['scholarship_pay_day'] as int,
      currency: map['currency'] as String,
      locale: map['locale'] as String,
      isDarkMode: (map['is_dark_mode'] as int) == 1,
    );
  }

  UserProfileModel copyWith({
    int? id,
    double? monthlyBudget,
    double? scholarshipAmount,
    int? scholarshipPayDay,
    String? currency,
    String? locale,
    bool? isDarkMode,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      scholarshipAmount: scholarshipAmount ?? this.scholarshipAmount,
      scholarshipPayDay: scholarshipPayDay ?? this.scholarshipPayDay,
      currency: currency ?? this.currency,
      locale: locale ?? this.locale,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}
