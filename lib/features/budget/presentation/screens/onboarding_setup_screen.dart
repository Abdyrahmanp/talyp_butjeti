import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/app_translations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/haptic_helper.dart';
import '../providers/budget_provider.dart';
import '../providers/settings_provider.dart';
import 'main_navigation_screen.dart';

class OnboardingSetupScreen extends ConsumerStatefulWidget {
  final bool isEditing;

  const OnboardingSetupScreen({
    super.key,
    this.isEditing = false,
  });

  @override
  ConsumerState<OnboardingSetupScreen> createState() => _OnboardingSetupScreenState();
}

class _OnboardingSetupScreenState extends ConsumerState<OnboardingSetupScreen> {
  late TextEditingController _budgetController;
  late TextEditingController _scholarshipController;
  int _payDay = 25;
  String _selectedLocale = 'tk';

  static const List<double> _budgetPresets = [500, 1000, 1500, 2000, 3000];
  static const List<double> _scholarshipPresets = [500, 750, 1000, 1500];

  @override
  void initState() {
    super.initState();
    final profile = ref.read(settingsProvider).value;
    final initialBudget = profile?.monthlyBudget ?? 1500.0;
    final initialScholarship = profile?.scholarshipAmount ?? 750.0;
    _payDay = profile?.scholarshipPayDay ?? 25;
    _selectedLocale = profile?.locale ?? 'tk';

    _budgetController = TextEditingController(text: initialBudget.toStringAsFixed(0));
    _scholarshipController = TextEditingController(text: initialScholarship.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _budgetController.dispose();
    _scholarshipController.dispose();
    super.dispose();
  }

  double get _currentBudget => double.tryParse(_budgetController.text) ?? 0.0;
  double get _currentScholarship => double.tryParse(_scholarshipController.text) ?? 0.0;

  int _calculateDaysUntilPayDay() {
    final now = DateTime.now();
    final today = now.day;
    if (_payDay >= today) {
      return _payDay - today;
    } else {
      final daysInCurrentMonth = DateTime(now.year, now.month + 1, 0).day;
      return (daysInCurrentMonth - today) + _payDay;
    }
  }

  double _calculateEstimatedDailyLimit() {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final remainingDays = (daysInMonth - now.day + 1).clamp(1, 31);
    final budget = _currentBudget;
    if (budget <= 0) return 0.0;
    return budget / remainingDays;
  }

  Future<void> _submitSetup() async {
    final budget = double.tryParse(_budgetController.text);
    final scholarship = double.tryParse(_scholarshipController.text) ?? 0.0;

    if (budget == null || budget <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dogry bütçe mukdaryny giriziň')),
      );
      return;
    }

    HapticHelper.mediumImpact();

    await ref.read(settingsProvider.notifier).completeOnboarding(
      monthlyBudget: budget,
      scholarshipAmount: scholarship,
      scholarshipPayDay: _payDay,
      locale: _selectedLocale,
    );

    await ref.read(budgetProvider.notifier).loadBudgetData();

    if (!mounted) return;

    if (widget.isEditing) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final daysToPay = _calculateDaysUntilPayDay();
    final estimatedDaily = _calculateEstimatedDailyLimit();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar: Language Switcher & Optional Close Button (if editing)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.isEditing)
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    )
                  else
                    const SizedBox(width: 48),

                  // Language Switcher
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'tk', label: Text('Türkmen')),
                      ButtonSegment(value: 'en', label: Text('English')),
                    ],
                    selected: {_selectedLocale},
                    onSelectionChanged: (val) {
                      HapticHelper.selectionClick();
                      setState(() {
                        _selectedLocale = val.first;
                      });
                      ref.read(settingsProvider.notifier).setLocale(val.first);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Hero Header with Icon & Welcome
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.emerald],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 18,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      AppTranslations.get('welcome_title', _selectedLocale),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppTranslations.get('welcome_tagline', _selectedLocale),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Visual Logic Flowchart Card ("How it works")
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.black12,
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: AppColors.amber, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          AppTranslations.get('onboarding_logic_title', _selectedLocale),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Step 1: Starting Funds
                    _buildStepRow(
                      icon: Icons.wallet_rounded,
                      iconColor: AppColors.primary,
                      title: AppTranslations.get('logic_step_1_title', _selectedLocale),
                      desc: AppTranslations.get('logic_step_1_desc', _selectedLocale),
                      isDark: isDark,
                    ),

                    _buildArrowDivider(),

                    // Step 2: Decrease as you spend
                    _buildStepRow(
                      icon: Icons.trending_down_rounded,
                      iconColor: AppColors.rose,
                      title: AppTranslations.get('logic_step_2_title', _selectedLocale),
                      desc: AppTranslations.get('logic_step_2_desc', _selectedLocale),
                      isDark: isDark,
                    ),

                    _buildArrowDivider(),

                    // Step 3: Dynamic safe limit
                    _buildStepRow(
                      icon: Icons.shield_outlined,
                      iconColor: AppColors.emerald,
                      title: AppTranslations.get('logic_step_3_title', _selectedLocale),
                      desc: AppTranslations.get('logic_step_3_desc', _selectedLocale),
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Budget Input Configuration Section
              Text(
                AppTranslations.get('setup_budget_heading', _selectedLocale),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // 1. Initial / Current Budget TextField
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppTranslations.get('current_funds_label', _selectedLocale),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _budgetController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                      decoration: InputDecoration(
                        suffixText: 'TMT',
                        suffixStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          AppTranslations.get('quick_presets', _selectedLocale),
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _budgetPresets.map((val) {
                                final isSelected = _currentBudget == val;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: ChoiceChip(
                                    label: Text('${val.toInt()} TMT'),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      if (selected) {
                                        HapticHelper.selectionClick();
                                        setState(() {
                                          _budgetController.text = val.toStringAsFixed(0);
                                        });
                                      }
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Scholarship / Income Input & Payday Picker
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppTranslations.get('scholarship_label', _selectedLocale),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _scholarshipController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        suffixText: 'TMT',
                        suffixStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          AppTranslations.get('quick_presets', _selectedLocale),
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _scholarshipPresets.map((val) {
                                final isSelected = _currentScholarship == val;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: ChoiceChip(
                                    label: Text('${val.toInt()} TMT'),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      if (selected) {
                                        HapticHelper.selectionClick();
                                        setState(() {
                                          _scholarshipController.text = val.toStringAsFixed(0);
                                        });
                                      }
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Payday selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppTranslations.get('payday_label', _selectedLocale),
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$_payDay-i',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _payDay.toDouble(),
                      min: 1,
                      max: 31,
                      divisions: 30,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() {
                          _payDay = val.round();
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Live Simulation Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.18),
                      AppColors.emerald.withValues(alpha: 0.18),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppTranslations.get('estimated_daily_safe', _selectedLocale),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.format(estimatedDaily),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.emerald,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 38,
                      width: 1,
                      color: isDark ? Colors.white24 : Colors.black12,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppTranslations.get('days_to_payday', _selectedLocale),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$daysToPay gün',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Button (Start Budgeting / Save)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _submitSetup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 3,
                  ),
                  child: Text(
                    widget.isEditing
                        ? AppTranslations.get('save_changes_btn', _selectedLocale)
                        : AppTranslations.get('start_budget_button', _selectedLocale),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String desc,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildArrowDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Icon(
        Icons.keyboard_arrow_down_rounded,
        size: 20,
        color: Colors.grey.withValues(alpha: 0.5),
      ),
    );
  }
}
