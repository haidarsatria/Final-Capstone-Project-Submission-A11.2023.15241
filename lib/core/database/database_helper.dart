import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('warungku_v2.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // 1. Tabel Produk
    await db.execute('''
      CREATE TABLE products ( 
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        name TEXT, 
        price INTEGER, 
        stock INTEGER, 
        photo_url TEXT, 
        category TEXT, 
        barcode TEXT
      )
    ''');

    // 2. Tabel Transaksi
    await db.execute('''
      CREATE TABLE transactions ( 
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        date TEXT, 
        total_amount INTEGER, 
        payment_method TEXT,
        customer_name TEXT,  -- Kolom Baru
        receipt_photo TEXT   -- Kolom Baru
      )
    ''');

    // 3. Tabel Detail Transaksi (Items)
    await db.execute('''
      CREATE TABLE transaction_items ( 
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        transaction_id INTEGER, 
        product_id INTEGER, 
        qty INTEGER, 
        price_at_purchase INTEGER
      )
    ''');

    // 4. Tabel Riwayat Stok (Stock Movements)
    await db.execute('''
      CREATE TABLE stock_movements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER,
        type TEXT, 
        quantity INTEGER,
        date TEXT,
        photo_proof TEXT,
        notes TEXT
      )
    ''');
  }

  Future<int> insert(String table, Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await instance.database;
    return await db.query(table);
  }

  Future<List<Map<String, dynamic>>> query(String table,
      {String? where, List<Object?>? whereArgs, String? orderBy}) async {
    final db = await instance.database;
    return await db.query(table,
        where: where, whereArgs: whereArgs, orderBy: orderBy);
  }

  Future<List<Map<String, dynamic>>> rawQuery(String sql,
      [List<Object?>? arguments]) async {
    final db = await instance.database;
    return await db.rawQuery(sql, arguments);
  }

  Future<int> update(String table, Map<String, dynamic> row) async {
    final db = await instance.database;
    int id = row['id'];
    return await db.update(table, row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(String table, int id) async {
    final db = await instance.database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }
}
