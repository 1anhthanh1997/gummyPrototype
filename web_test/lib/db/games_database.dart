import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:web_test/model/game_model.dart';
import 'package:web_test/model/type_model.dart';
import 'package:web_test/model/user_model.dart';

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

  Future _createTable(db, int version) async {
    await _createGameDB(db, version);
    await _createTypeDB(db, version);
    await _createUserDB(db, version);
    // await _checkTableGameData(db);
    // await _checkTableTypeData(db);
    // await _checkTableUserData(db);
  }

  Future _createUserDB(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final textType = 'TEXT NOT NULL';
    final boolType = 'BOOLEAN NOT NULL';
    final integerType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE $tableUsers ( 
  ${UserModel.id} $idType, 
  ${UserModel.name} $textType,
  ${UserModel.image} $textType,
  ${UserModel.score} $integerType,
  ${UserModel.correctTime} $integerType,
  ${UserModel.wrongTime} $integerType
  )
''');
  }

  Future _createTypeDB(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final textType = 'TEXT NOT NULL';
    final boolType = 'BOOLEAN NOT NULL';
    final integerType = 'INTEGER NOT NULL';
    final doubleType = 'DOUBLE NOT NULL';


    await db.execute('''
CREATE TABLE $tableTypes ( 
  ${TypeModel.id} $idType, 
  ${TypeModel.typeId} $integerType,
  ${TypeModel.skipTime} $integerType,
  ${TypeModel.score} $doubleType
  )
''');
  }

  Future _createGameDB(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final textType = 'TEXT NOT NULL';
    final boolType = 'BOOLEAN NOT NULL';
    final integerType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE $tableGames ( 
  ${GameModel.id} $idType, 
  ${GameModel.gameId} $integerType, 
  ${GameModel.type} $integerType,
  ${GameModel.level} $integerType,
  ${GameModel.age} $integerType,
  ${GameModel.lastUpdate} $integerType,
  ${GameModel.baseScore} $integerType
  )
''');
  }

  ///Action for gameTables
  ///

  Future<Game> createGame(Game game) async {
    print(game);
    Game searchedGame = await readGame(game.gameId);
    if (searchedGame != null) {
      print('Game is exist');
      return null;
    }else{
      final db = await instance.database;
      final id = await db.insert(tableGames, game.toJson());
      return game.copy(id: id);
    }
  }

  Future<Game> readGame(int gameId) async {
    final db = await instance.database;

    final maps = await db.query(
      tableGames,
      columns: GameModel.values,
      where: '${GameModel.gameId} = ?',
      whereArgs: [gameId],
    );

    if (maps.isNotEmpty) {
      return Game.fromJson(maps.first);
    } else {
      print('This is new game');
      return null;
    }
  }

  Future<List<Game>> readAllGames() async {
    final db = await instance.database;

    final orderBy = '${GameModel.id} ASC';

    final result = await db.query(tableGames, orderBy: orderBy);
    print(result);

    return result.map((json) => Game.fromJson(json)).toList();
  }

  Future<int> updateGame(Game game) async {
    final db = await instance.database;

    return db.update(
      tableGames,
      game.toJson(),
      where: '${GameModel.gameId} = ?',
      whereArgs: [game.gameId],
    );
  }

  Future<int> deleteGame(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableGames,
      where: '${GameModel.id} = ?',
      whereArgs: [id],
    );
  }

  ///Action for tableTypes
  Future<Type> createType(Type type) async {
    Type searchedType = await readType(type.typeId);
    if (searchedType != null) {
      print('Type is exist');
      return null;
    }
    final db = await instance.database;
    final id = await db.insert(tableTypes, type.toJson());
    return type.copy(id: id);
  }

  Future<Type> readType(int typeId) async {
    final db = await instance.database;

    final maps = await db.query(
      tableTypes,
      columns: TypeModel.values,
      where: '${TypeModel.typeId} = ?',
      whereArgs: [typeId],
    );

    if (maps.isNotEmpty) {
      return Type.fromJson(maps.first);
    } else {
      print('This is new game');
    }
  }

  Future<List<Type>> readAllTypes() async {
    final db = await instance.database;

    final orderBy = '${TypeModel.id} ASC';

    final result = await db.query(tableTypes, orderBy: orderBy);
    print('Type');
    print(result);

    return result.map((json) => Type.fromJson(json)).toList();
  }

  Future<int> updateType(Type type) async {
    final db = await instance.database;

    return db.update(
      tableTypes,
      type.toJson(),
      where: '${TypeModel.id} = ?',
      whereArgs: [type.id],
    );
  }

  Future<int> deleteType(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableTypes,
      where: '${TypeModel.id} = ?',
      whereArgs: [id],
    );
  }

  ///Action for tableUsers
  Future<User> createUser(User user) async {
    User searchedUser = await readUser(user.name);
    if (searchedUser != null) {
      print('User is exist');
      return null;
    }
    final db = await instance.database;
    final id = await db.insert(tableUsers, user.toJson());
    return user.copy(id: id);
  }

  Future<User> readUser(String name) async {
    final db = await instance.database;

    final maps = await db.query(
      tableUsers,
      columns: UserModel.values,
      where: '${UserModel.name} = ?',
      whereArgs: [name],
    );

    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    } else {
      print('This is new game');
      return null;
    }
  }

  Future<List<User>> readAllUser() async {
    final db = await instance.database;

    final orderBy = '${UserModel.id} ASC';

    final result = await db.query(tableUsers, orderBy: orderBy);
    print('User');
    print(result);

    return result.map((json) => User.fromJson(json)).toList();
  }

  Future<int> updateUser(User user) async {
    final db = await instance.database;

    return db.update(
      tableUsers,
      user.toJson(),
      where: '${UserModel.name} = ?',
      whereArgs: [user.name],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableUsers,
      where: '${UserModel.id} = ?',
      whereArgs: [id],
    );
  }

  /// Close the db
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
