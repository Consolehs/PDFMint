import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseService {
  static Database? _database;
  static const String _dbName = 'pdfmint.db';
  static const int _dbVersion = 1;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    // Desktop için FFI başlat
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'PDFMint', _dbName);

    await Directory(p.dirname(dbPath)).create(recursive: true);

    return await databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: _dbVersion,
        onCreate: _createTables,
        onUpgrade: _upgradeTables,
      ),
    );
  }

  static Future<void> _createTables(Database db, int version) async {
    // İşlem geçmişi tablosu
    await db.execute('''
      CREATE TABLE IF NOT EXISTS processing_history (
        id TEXT PRIMARY KEY,
        tool_id TEXT NOT NULL,
        tool_name TEXT NOT NULL,
        input_files TEXT NOT NULL,
        output_file TEXT,
        timestamp INTEGER NOT NULL,
        success INTEGER NOT NULL DEFAULT 1,
        error_message TEXT,
        duration_ms INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Son kullanılan klasörler
    await db.execute('''
      CREATE TABLE IF NOT EXISTS recent_folders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        path TEXT NOT NULL UNIQUE,
        last_used INTEGER NOT NULL,
        use_count INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Favori araçlar
    await db.execute('''
      CREATE TABLE IF NOT EXISTS favorite_tools (
        tool_id TEXT PRIMARY KEY,
        added_at INTEGER NOT NULL
      )
    ''');

    // Uygulama ayarları
    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _upgradeTables(
      Database db, int oldVersion, int newVersion) async {
    // Gelecekteki migration'lar için
  }

  // İşlem Geçmişi CRUD
  static Future<void> insertHistory({
    required String id,
    required String toolId,
    required String toolName,
    required List<String> inputFiles,
    String? outputFile,
    required bool success,
    String? errorMessage,
    required int durationMs,
  }) async {
    final db = await database;
    await db.insert(
      'processing_history',
      {
        'id': id,
        'tool_id': toolId,
        'tool_name': toolName,
        'input_files': inputFiles.join('|'),
        'output_file': outputFile,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'success': success ? 1 : 0,
        'error_message': errorMessage,
        'duration_ms': durationMs,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getHistory({
    int limit = 100,
    int offset = 0,
  }) async {
    final db = await database;
    return await db.query(
      'processing_history',
      orderBy: 'timestamp DESC',
      limit: limit,
      offset: offset,
    );
  }

  static Future<void> clearHistory() async {
    final db = await database;
    await db.delete('processing_history');
  }

  static Future<void> deleteHistoryItem(String id) async {
    final db = await database;
    await db.delete('processing_history', where: 'id = ?', whereArgs: [id]);
  }

  // Son Klasörler
  static Future<void> addRecentFolder(String path) async {
    final db = await database;
    await db.rawInsert('''
      INSERT INTO recent_folders (path, last_used, use_count)
      VALUES (?, ?, 1)
      ON CONFLICT(path) DO UPDATE SET
        last_used = ?,
        use_count = use_count + 1
    ''', [path, DateTime.now().millisecondsSinceEpoch,
        DateTime.now().millisecondsSinceEpoch]);
  }

  static Future<List<String>> getRecentFolders({int limit = 10}) async {
    final db = await database;
    final results = await db.query(
      'recent_folders',
      columns: ['path'],
      orderBy: 'last_used DESC',
      limit: limit,
    );
    return results.map((r) => r['path'] as String).toList();
  }

  // Favori Araçlar
  static Future<void> toggleFavoriteTool(String toolId) async {
    final db = await database;
    final existing = await db.query(
      'favorite_tools',
      where: 'tool_id = ?',
      whereArgs: [toolId],
    );

    if (existing.isEmpty) {
      await db.insert('favorite_tools', {
        'tool_id': toolId,
        'added_at': DateTime.now().millisecondsSinceEpoch,
      });
    } else {
      await db.delete('favorite_tools',
          where: 'tool_id = ?', whereArgs: [toolId]);
    }
  }

  static Future<List<String>> getFavoriteTools() async {
    final db = await database;
    final results = await db.query('favorite_tools',
        columns: ['tool_id'], orderBy: 'added_at DESC');
    return results.map((r) => r['tool_id'] as String).toList();
  }

  static Future<bool> isToolFavorite(String toolId) async {
    final db = await database;
    final results = await db.query(
      'favorite_tools',
      where: 'tool_id = ?',
      whereArgs: [toolId],
    );
    return results.isNotEmpty;
  }

  // Uygulama Ayarları
  static Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'app_settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<String?> getSetting(String key) async {
    final db = await database;
    final results = await db.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (results.isEmpty) return null;
    return results.first['value'] as String;
  }

  // İstatistikler
  static Future<Map<String, dynamic>> getStats() async {
    final db = await database;

    final totalCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM processing_history'));
    final successCount = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM processing_history WHERE success = 1'));
    final mostUsedTool = await db.rawQuery('''
      SELECT tool_id, tool_name, COUNT(*) as count
      FROM processing_history
      GROUP BY tool_id
      ORDER BY count DESC
      LIMIT 1
    ''');

    return {
      'total': totalCount ?? 0,
      'success': successCount ?? 0,
      'mostUsedTool':
          mostUsedTool.isNotEmpty ? mostUsedTool.first['tool_name'] : null,
    };
  }
}
