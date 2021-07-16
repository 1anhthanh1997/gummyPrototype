final String tableGames = 'games';
final String _columnAdditionInfo = 'additionInfo';

final String updateColumnAdditionInfo = '''
        ALTER TABLE $tableGames ADD COLUMN $_columnAdditionInfo text
        ''';

class GameModel {
  static final List<String> values = [
    /// Add all fields
    id, gameId, type, level, age, lastUpdate, baseScore
  ];

  static final String id = '_id';
  static final String gameId = 'gameId';
  static final String type = 'type';
  static final String level = 'level';
  static final String age = 'age';
  static final String lastUpdate = 'lastUpdate';
  static final String baseScore = 'baseScore';
}

class Game {
  int id;
  int gameId;
  int type;
  int level;
  int age;
  int lastUpdate;
  int baseScore;

  Game({
    this.id,
    this.gameId,
    this.type,
    this.level,
    this.age,
    this.lastUpdate,
    this.baseScore,
  });

  Game copy({
    int id,
    int gameId,
    int type,
    int level,
    int age,
    int lastUpdate,
    int baseScore,
  }) =>
      Game(
        id: this.id,
        gameId: this.gameId,
        type: this.type,
        level: this.level,
        age: this.age,
        lastUpdate: this.lastUpdate,
        baseScore: this.baseScore,
      );

  static Game fromJson(Map<String, Object> json) {
    return Game(
        id: json[GameModel.id],
        gameId: json[GameModel.gameId],
        type: json[GameModel.type],
        level: json[GameModel.level],
        age: json[GameModel.age],
        lastUpdate: json[GameModel.lastUpdate],
        baseScore: json[GameModel.baseScore]);
  }

  Map<String, Object> toJson() => {
        GameModel.id: id,
        GameModel.gameId: gameId,
        GameModel.type: type,
        GameModel.level: level,
        GameModel.age: age,
        GameModel.lastUpdate: lastUpdate,
        GameModel.baseScore: baseScore,
      };
}
