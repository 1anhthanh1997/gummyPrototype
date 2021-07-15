import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:web_test/model/game_model.dart';

class GamesDatabase {
  static final GamesDatabase instance = GamesDatabase._init();

  static Database _database;


  GamesDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await _initDB('games.db');
    return _database;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createTable);
  }

  Future _createTable(db,int version) async {
    await _createGameDB(db, version);
    await _checkTableUserGameData(db);
  }

  Future _createGameDB(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final textType = 'TEXT NOT NULL';
    final boolType = 'BOOLEAN NOT NULL';
    final integerType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE $tableGames ( 
  ${GameModel.id} $idType, 
  ${GameModel.type} $integerType,
  ${GameModel.level} $integerType,
  ${GameModel.age} $integerType,
  ${GameModel.skipTime} $integerType,
  ${GameModel.baseScore} $integerType
  )
''');
  }

  Future _checkTableUserGameData(db) async {
    String checkFieldExistsSql = 'PRAGMA table_info("$tableGames")';
    List<Map> maps = await db.rawQuery(checkFieldExistsSql);
    print(maps.toString());
    bool foundAdditionInfoColumn = false;
    for (int i = 0; i < maps.length; i++) {
      if (maps[i]['name'] == 'additionInfo') {
        foundAdditionInfoColumn = true;
      }
    }
    // print("foundLastupdateColumn $foundLastupdateColumn");
    if (foundAdditionInfoColumn == false) {
      await db.execute(updateColumnAdditionInfo);
    }
  }

  Future<Game> create(Game game) async {
    final db = await instance.database;
    final id = await db.insert(tableGames, game.toJson());
    return game.copy(id: id);
  }

  Future<Game> readGame(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableGames,
      columns: GameModel.values,
      where: '${GameModel.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Game.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Game>> readAllGames() async {
    final db = await instance.database;

    final orderBy = '${GameModel.id} ASC';

    final result = await db.query(tableGames, orderBy: orderBy);
    print(result);

    return result.map((json) => Game.fromJson(json)).toList();
  }

  Future<int> update(Game game) async {
    final db = await instance.database;

    return db.update(
      tableGames,
      game.toJson(),
      where: '${GameModel.id} = ?',
      whereArgs: [game.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableGames,
      where: '${GameModel.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}