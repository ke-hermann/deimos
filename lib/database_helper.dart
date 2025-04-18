import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

// Import the Category enum from main.dart (adjust path if needed)
import 'main.dart';

class DatabaseHelper {
  // Database constants
  static const _databaseName = "items_manager.db";
  static const _databaseVersion = 1;

  static const tableItems = 'items';
  static const columnId = '_id';
  static const columnCategory = 'category';
  static const columnContent = 'content';
  static const columnCreatedAt = 'createdAt'; // Optional: Track creation time

  // Make this a singleton class.
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only have a single app-wide reference to the database.
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    // Lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database!;
  }

  // Opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $tableItems (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnCategory TEXT NOT NULL,
            $columnContent TEXT NOT NULL,
            $columnCreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP
          )
          ''');
  }

  // --- Helper Methods ---

  // Inserts a row in the database
  Future<int> insertItem(Category category, String content) async {
    Database db = await instance.database;
    Map<String, dynamic> row = {
      columnCategory: category.name, // Store enum name as string
      columnContent: content,
    };
    return await db.insert(tableItems, row);
  }

  // Retrieves all items for a specific category, ordered by creation time (newest first)
  Future<List<String>> getItems(Category category) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query(
      tableItems,
      columns: [columnContent], // Only fetch the content for now
      where: '$columnCategory = ?',
      whereArgs: [category.name],
      orderBy: '$columnCreatedAt DESC', // Order by newest first
    );

    // Convert the List<Map<String, dynamic>> into a List<String>
    return result.map((map) => map[columnContent] as String).toList();
  }

  // --- We might add methods like update and delete later ---
  /*
  Future<int> updateItem(int id, String newContent) async {
    Database db = await instance.database;
    Map<String, dynamic> row = {
      columnContent: newContent,
      // You might want to update other fields too
    };
    return await db.update(tableItems, row, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> deleteItem(int id) async {
    Database db = await instance.database;
    return await db.delete(tableItems, where: '$columnId = ?', whereArgs: [id]);
  }

  // Example: Get items as full objects (more flexible)
  Future<List<Map<String, dynamic>>> getItemsAsMaps(Category category) async {
     Database db = await instance.database;
     return await db.query(
       tableItems,
       where: '$columnCategory = ?',
       whereArgs: [category.name],
       orderBy: '$columnCreatedAt DESC',
     );
   }
  */
}