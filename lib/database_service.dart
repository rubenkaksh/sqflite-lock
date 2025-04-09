import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/photo.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create your tables here
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        description TEXT,
        date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE photos(
        id INTEGER PRIMARY KEY,
        albumId INTEGER NOT NULL,
        title TEXT NOT NULL,
        url TEXT NOT NULL,
        thumbnailUrl TEXT NOT NULL
      )
    ''');
  }

  // Insert a transaction
  Future<int> insertTransaction(Map<String, dynamic> transaction) async {
    final Database db = await database;
    return await db.insert('transactions', transaction);
  }

  // Get all transactions
  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    final Database db = await database;
    return await db.query('transactions');
  }

  // Update a transaction
  Future<int> updateTransaction(Map<String, dynamic> transaction) async {
    final Database db = await database;
    return await db.update(
      'transactions',
      transaction,
      where: 'id = ?',
      whereArgs: [transaction['id']],
    );
  }

  // Delete a transaction
  Future<int> deleteTransaction(int id) async {
    final Database db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Insert a photo
  Future<int> insertPhoto(Photo photo) async {
    final Database db = await database;
    return await db.insert(
      'photos',
      photo.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Insert multiple photos
  Future<void> insertPhotos(List<Photo> photos, {int attempt = 1}) async {
    final Database db = await database;
    final List<Map<String, dynamic>> storeables = photos.map((e) {
      e.newId = e.id + 5000 * attempt;
      return e.toJson();
    }).toList();
    print(' >>>============>>> GOING FOR WRITE');
    await db.transaction((txn) async {
      for (var photo in storeables) {
        await txn.insert(
          'photos',
          photo,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
    print(' OOO============OOO DONE WITH WRITE');
  }

  // Get all photos - using separate read connection
  Future<List<Photo>> getAllPhotos() async {
    final Database db = await database;
    print(' <<<============<<< GOING FOR READ');
    final List<Map<String, dynamic>> maps = await db.query('photos');
    print(' XXX============XXX DONE WITH READ');
    return List.generate(maps.length, (i) {
      return Photo.fromJson(maps[i]);
    });
  }

  // Delete all photos
  Future<int> deleteAllPhotos() async {
    final Database db = await database;
    return await db.delete('photos');
  }

  // Execute multiple operations in a transaction
  Future<void> executeTransaction(
      List<Future<void> Function(Transaction)> operations) async {
    final Database db = await database;
    await db.transaction((txn) async {
      for (var operation in operations) {
        await operation(txn);
      }
    });
  }

  // Close the database
  Future<void> close() async {
    final Database db = await database;
    await db.close();
  }
}
