import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static bool _isDesktop = false;

  DatabaseHelper._init() {
    _isDesktop = !kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS);
  }

  bool get isDesktop => _isDesktop;

  Future<Database?> get database async {
    if (_isDesktop) return null;
    if (_database != null) return _database!;
    try {
      _database = await _initDB('talyp_butjet.db');
      return _database;
    } catch (_) {
      // Fallback to desktop mode if mobile sqflite factory is missing
      _isDesktop = true;
      return null;
    }
  }

  Future<Database> _initDB(String filePath) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final path = join(docsDir.path, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        monthly_budget REAL NOT NULL,
        scholarship_amount REAL NOT NULL,
        scholarship_pay_day INTEGER NOT NULL,
        currency TEXT NOT NULL,
        locale TEXT NOT NULL,
        is_dark_mode INTEGER NOT NULL
      )
    ''');

    await db.insert('users', {
      'id': 1,
      'monthly_budget': 1500.0,
      'scholarship_amount': 750.0,
      'scholarship_pay_day': 25,
      'currency': 'TMT',
      'locale': 'tk',
      'is_dark_mode': 1,
    });

    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name_tk TEXT NOT NULL,
        name_en TEXT NOT NULL,
        icon_code INTEGER NOT NULL,
        color_hex TEXT NOT NULL,
        type TEXT NOT NULL
      )
    ''');

    final defaultCategories = [
      {
        'id': 'cat_food',
        'name_tk': 'Nahar / Kafeteriýa',
        'name_en': 'Food / Canteen',
        'icon_code': Icons.restaurant.codePoint,
        'color_hex': '#F43F5E',
        'type': 'expense',
      },
      {
        'id': 'cat_dorm',
        'name_tk': 'Obşejitiýe / Kireý',
        'name_en': 'Dorm / Rent',
        'icon_code': Icons.home.codePoint,
        'color_hex': '#8B5CF6',
        'type': 'expense',
      },
      {
        'id': 'cat_transport',
        'name_tk': 'Ulag / Awtobus',
        'name_en': 'Transportation',
        'icon_code': Icons.directions_bus.codePoint,
        'color_hex': '#0EA5E9',
        'type': 'expense',
      },
      {
        'id': 'cat_books',
        'name_tk': 'Kitap / Kançelyariýa',
        'name_en': 'Books / Stationery',
        'icon_code': Icons.menu_book.codePoint,
        'color_hex': '#F59E0B',
        'type': 'expense',
      },
      {
        'id': 'cat_leisure',
        'name_tk': 'Danç / Gezim',
        'name_en': 'Social / Leisure',
        'icon_code': Icons.sports_esports.codePoint,
        'color_hex': '#EC4899',
        'type': 'expense',
      },
      {
        'id': 'cat_sub',
        'name_tk': 'Abunalyklar',
        'name_en': 'Subscriptions',
        'icon_code': Icons.subscriptions.codePoint,
        'color_hex': '#6366F1',
        'type': 'expense',
      },
      {
        'id': 'cat_emergency',
        'name_tk': 'Gyssagly Ýagdaý',
        'name_en': 'Emergency',
        'icon_code': Icons.warning_amber.codePoint,
        'color_hex': '#EF4444',
        'type': 'expense',
      },
      {
        'id': 'cat_scholarship',
        'name_tk': 'Talyphak / Girdeji',
        'name_en': 'Scholarship / Income',
        'icon_code': Icons.account_balance_wallet.codePoint,
        'color_hex': '#10B981',
        'type': 'income',
      },
    ];

    for (final cat in defaultCategories) {
      await db.insert('categories', cat);
    }

    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        category_id TEXT NOT NULL,
        title TEXT NOT NULL,
        note TEXT,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('CREATE INDEX idx_tx_date ON transactions (date)');
    await db.execute('CREATE INDEX idx_tx_category ON transactions (category_id)');

    await db.execute('''
      CREATE TABLE subscriptions (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        due_day INTEGER NOT NULL,
        category_id TEXT NOT NULL,
        is_active INTEGER NOT NULL,
        icon_code INTEGER NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    await db.insert('subscriptions', {
      'id': 'sub_1',
      'title': 'Dorm WiFi / Internet',
      'amount': 50.0,
      'due_day': 10,
      'category_id': 'cat_sub',
      'is_active': 1,
      'icon_code': Icons.wifi.codePoint,
    });
    await db.insert('subscriptions', {
      'id': 'sub_2',
      'title': 'Spotify / Music',
      'amount': 25.0,
      'due_day': 15,
      'category_id': 'cat_sub',
      'is_active': 1,
      'icon_code': Icons.music_note.codePoint,
    });

    await db.execute('''
      CREATE TABLE debts (
        id TEXT PRIMARY KEY,
        person_name TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        due_date TEXT,
        note TEXT,
        is_settled INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
    }
  }
}
