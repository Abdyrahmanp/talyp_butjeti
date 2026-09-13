import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';
import '../domain/models/category_model.dart';
import '../domain/models/debt_model.dart';
import '../domain/models/subscription_model.dart';
import '../domain/models/transaction_model.dart';
import '../domain/models/user_profile_model.dart';

class DatabaseRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // In-memory fallback data structures for Desktop / Web
  UserProfileModel _userProfile = const UserProfileModel(
    id: 1,
    monthlyBudget: 1500.0,
    scholarshipAmount: 750.0,
    scholarshipPayDay: 25,
    currency: 'TMT',
    locale: 'tk',
    isDarkMode: true,
  );

  final List<CategoryModel> _categories = [
    CategoryModel(
      id: 'cat_food',
      nameTk: 'Nahar / Kafeteriýa',
      nameEn: 'Food / Canteen',
      iconCode: Icons.restaurant.codePoint,
      colorHex: '#F43F5E',
      type: 'expense',
    ),
    CategoryModel(
      id: 'cat_dorm',
      nameTk: 'Obşejitiýe / Kireý',
      nameEn: 'Dorm / Rent',
      iconCode: Icons.home.codePoint,
      colorHex: '#8B5CF6',
      type: 'expense',
    ),
    CategoryModel(
      id: 'cat_transport',
      nameTk: 'Ulag / Awtobus',
      nameEn: 'Transportation',
      iconCode: Icons.directions_bus.codePoint,
      colorHex: '#0EA5E9',
      type: 'expense',
    ),
    CategoryModel(
      id: 'cat_books',
      nameTk: 'Kitap / Kançelyariýa',
      nameEn: 'Books / Stationery',
      iconCode: Icons.menu_book.codePoint,
      colorHex: '#F59E0B',
      type: 'expense',
    ),
    CategoryModel(
      id: 'cat_leisure',
      nameTk: 'Danç / Gezim',
      nameEn: 'Social / Leisure',
      iconCode: Icons.sports_esports.codePoint,
      colorHex: '#EC4899',
      type: 'expense',
    ),
    CategoryModel(
      id: 'cat_sub',
      nameTk: 'Abunalyklar',
      nameEn: 'Subscriptions',
      iconCode: Icons.subscriptions.codePoint,
      colorHex: '#6366F1',
      type: 'expense',
    ),
    CategoryModel(
      id: 'cat_emergency',
      nameTk: 'Gyssagly Ýagdaý',
      nameEn: 'Emergency',
      iconCode: Icons.warning_amber.codePoint,
      colorHex: '#EF4444',
      type: 'expense',
    ),
    CategoryModel(
      id: 'cat_scholarship',
      nameTk: 'Talyphak / Girdeji',
      nameEn: 'Scholarship / Income',
      iconCode: Icons.account_balance_wallet.codePoint,
      colorHex: '#10B981',
      type: 'income',
    ),
  ];

  final List<TransactionModel> _transactions = [];

  final List<SubscriptionModel> _subscriptions = [
    SubscriptionModel(
      id: 'sub_1',
      title: 'Dorm WiFi / Internet',
      amount: 50.0,
      dueDay: 10,
      categoryId: 'cat_sub',
      isActive: true,
      iconCode: Icons.wifi.codePoint,
    ),
    SubscriptionModel(
      id: 'sub_2',
      title: 'Spotify / Music',
      amount: 25.0,
      dueDay: 15,
      categoryId: 'cat_sub',
      isActive: true,
      iconCode: Icons.music_note.codePoint,
    ),
  ];

  final List<DebtModel> _debts = [];

  // --- User Profile ---
  Future<UserProfileModel> getUserProfile() async {
    final db = await _dbHelper.database;
    if (db == null) return _userProfile;
    try {
      final maps = await db.query('users', where: 'id = ?', whereArgs: [1]);
      if (maps.isNotEmpty) {
        return UserProfileModel.fromMap(maps.first);
      }
    } catch (_) {}
    return _userProfile;
  }

  Future<void> updateUserProfile(UserProfileModel profile) async {
    _userProfile = profile;
    final db = await _dbHelper.database;
    if (db == null) return;
    try {
      await db.update(
        'users',
        profile.toMap(),
        where: 'id = ?',
        whereArgs: [profile.id],
      );
    } catch (_) {}
  }

  // --- Categories ---
  Future<List<CategoryModel>> getCategories() async {
    final db = await _dbHelper.database;
    if (db == null) return _categories;
    try {
      final maps = await db.query('categories');
      if (maps.isNotEmpty) {
        return maps.map((map) => CategoryModel.fromMap(map)).toList();
      }
    } catch (_) {}
    return _categories;
  }

  // --- Transactions ---
  Future<List<TransactionModel>> getTransactionsForMonth(int year, int month) async {
    final db = await _dbHelper.database;
    if (db == null) {
      return _transactions
          .where((t) => t.date.year == year && t.date.month == month)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    }
    try {
      final startStr = DateTime(year, month, 1).toIso8601String();
      final endStr = DateTime(year, month + 1, 0, 23, 59, 59).toIso8601String();

      final maps = await db.query(
        'transactions',
        where: 'date >= ? AND date <= ?',
        whereArgs: [startStr, endStr],
        orderBy: 'date DESC',
      );

      return maps.map((map) => TransactionModel.fromMap(map)).toList();
    } catch (_) {
      return _transactions;
    }
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await _dbHelper.database;
    if (db == null) return List.unmodifiable(_transactions);
    try {
      final maps = await db.query('transactions', orderBy: 'date DESC');
      return maps.map((map) => TransactionModel.fromMap(map)).toList();
    } catch (_) {
      return _transactions;
    }
  }

  Future<void> addTransaction(TransactionModel tx) async {
    _transactions.insert(0, tx);
    final db = await _dbHelper.database;
    if (db == null) return;
    try {
      await db.insert(
        'transactions',
        tx.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {}
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    final db = await _dbHelper.database;
    if (db == null) return;
    try {
      await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
    } catch (_) {}
  }

  // --- Subscriptions ---
  Future<List<SubscriptionModel>> getSubscriptions() async {
    final db = await _dbHelper.database;
    if (db == null) return List.unmodifiable(_subscriptions);
    try {
      final maps = await db.query('subscriptions');
      if (maps.isNotEmpty) {
        return maps.map((map) => SubscriptionModel.fromMap(map)).toList();
      }
    } catch (_) {}
    return _subscriptions;
  }

  Future<void> addSubscription(SubscriptionModel sub) async {
    _subscriptions.add(sub);
    final db = await _dbHelper.database;
    if (db == null) return;
    try {
      await db.insert(
        'subscriptions',
        sub.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {}
  }

  Future<void> updateSubscription(SubscriptionModel sub) async {
    final idx = _subscriptions.indexWhere((s) => s.id == sub.id);
    if (idx != -1) _subscriptions[idx] = sub;

    final db = await _dbHelper.database;
    if (db == null) return;
    try {
      await db.update(
        'subscriptions',
        sub.toMap(),
        where: 'id = ?',
        whereArgs: [sub.id],
      );
    } catch (_) {}
  }

  Future<void> deleteSubscription(String id) async {
    _subscriptions.removeWhere((s) => s.id == id);
    final db = await _dbHelper.database;
    if (db == null) return;
    try {
      await db.delete('subscriptions', where: 'id = ?', whereArgs: [id]);
    } catch (_) {}
  }

  // --- Debts ---
  Future<List<DebtModel>> getDebts() async {
    final db = await _dbHelper.database;
    if (db == null) return List.unmodifiable(_debts);
    try {
      final maps = await db.query('debts', orderBy: 'created_at DESC');
      return maps.map((map) => DebtModel.fromMap(map)).toList();
    } catch (_) {
      return _debts;
    }
  }

  Future<void> addDebt(DebtModel debt) async {
    _debts.insert(0, debt);
    final db = await _dbHelper.database;
    if (db == null) return;
    try {
      await db.insert(
        'debts',
        debt.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {}
  }

  Future<void> updateDebt(DebtModel debt) async {
    final idx = _debts.indexWhere((d) => d.id == debt.id);
    if (idx != -1) _debts[idx] = debt;

    final db = await _dbHelper.database;
    if (db == null) return;
    try {
      await db.update(
        'debts',
        debt.toMap(),
        where: 'id = ?',
        whereArgs: [debt.id],
      );
    } catch (_) {}
  }

  Future<void> deleteDebt(String id) async {
    _debts.removeWhere((d) => d.id == id);
    final db = await _dbHelper.database;
    if (db == null) return;
    try {
      await db.delete('debts', where: 'id = ?', whereArgs: [id]);
    } catch (_) {}
  }
}
