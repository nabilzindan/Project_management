import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../constants/app_constants.dart';

/// Singleton helper untuk mengelola koneksi database SQLite.
///
/// `sqflite` murni hanya menyediakan implementasi native untuk Android,
/// iOS, dan macOS. Saat aplikasi berjalan di Windows atau Linux desktop,
/// kita wajib mengganti `databaseFactory` ke implementasi FFI
/// (`sqflite_common_ffi`) sebelum database pertama kali dibuka, jika tidak
/// akan muncul error: "Bad state: databaseFactory not initialized".
class DatabaseHelper {
  DatabaseHelper._internal() {
    _initializeFactory();
  }
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  void _initializeFactory() {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final isDesktop = !kIsWeb && (Platform.isWindows || Platform.isLinux);

    // Di desktop, getDatabasesPath() bawaan FFI bisa mengarah ke direktori
    // kerja aplikasi yang tidak selalu writable/konsisten, sehingga kita
    // tentukan sendiri lokasi penyimpanan di folder data aplikasi.
    final dbPath = isDesktop
        ? (await getApplicationSupportDirectory()).path
        : await getDatabasesPath();

    final path = join(dbPath, AppConstants.dbName);

    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.tableProducts} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        stock INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableOrders} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_name TEXT NOT NULL,
        total_price REAL NOT NULL,
        order_date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableOrderItems} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        FOREIGN KEY (order_id) REFERENCES ${AppConstants.tableOrders} (id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES ${AppConstants.tableProducts} (id)
      )
    ''');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
