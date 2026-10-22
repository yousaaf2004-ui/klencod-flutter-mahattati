// db_helper.dart — SQLite local database | Flutter | Windows/Android
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._internal();
  static Database? _db;

  DBHelper._internal();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'mahattati.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'user'
      )
    ''');

    await db.execute('''
      CREATE TABLE vehicles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        plate_number TEXT UNIQUE NOT NULL,
        model TEXT NOT NULL,
        color TEXT NOT NULL,
        year INTEGER NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE stations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        location TEXT NOT NULL,
        is_open INTEGER NOT NULL DEFAULT 0,
        allocated_liters REAL NOT NULL DEFAULT 0,
        remaining_liters REAL NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE bookings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        station_id INTEGER NOT NULL,
        vehicle_id INTEGER NOT NULL,
        booking_date TEXT NOT NULL,
        group_number INTEGER NOT NULL,
        barcode TEXT UNIQUE NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (station_id) REFERENCES stations(id),
        FOREIGN KEY (vehicle_id) REFERENCES vehicles(id)
      )
    ''');

    // بيانات تجريبية — محطات سبها
    await db.insert('stations', {
      'name': 'محطة الوسط',
      'location': 'وسط سبها',
      'is_open': 0,
      'allocated_liters': 0,
      'remaining_liters': 0,
    });
    await db.insert('stations', {
      'name': 'محطة المطار',
      'location': 'طريق المطار',
      'is_open': 0,
      'allocated_liters': 0,
      'remaining_liters': 0,
    });
    await db.insert('stations', {
      'name': 'محطة الجديدة',
      'location': 'المنطقة الجديدة',
      'is_open': 0,
      'allocated_liters': 0,
      'remaining_liters': 0,
    });

    // حسابات افتراضية
    await db.insert('users', {
      'name': 'مستودع سبها',
      'phone': '0910000001',
      'password': '1234',
      'role': 'depot',
    });
    await db.insert('users', {
      'name': 'محطة الوسط',
      'phone': '0910000002',
      'password': '1234',
      'role': 'station',
    });
    await db.insert('users', {
      'name': 'إدارة المرور',
      'phone': '0910000003',
      'password': '1234',
      'role': 'traffic',
    });
  }
}