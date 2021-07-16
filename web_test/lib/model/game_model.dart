final String tableGames = 'games';
final String _columnAdditionInfo = 'additionInfo';

final String updateColumnAdditionInfo = '''
        ALTER TABLE $tableGames ADD COLUMN $_columnAdditionInfo text
        ''';

class GameModel {
  static final List<String> values = [
    /// Add all fields
    id, gameId, type, level, age, baseScore
  ];

  static final String id = '_id';
  static final String gameId = 'gameId';
  static final String type = 'type';
  static final String level = 'level';
  static final String age = 'age';
  static final String baseScore = 'baseScore';
}

class Game {
  final int id;
  final int gameId;
  final int type;
  final int level;
  final int age;
  final int baseScore;

  const Game({
    this.id,
    this.gameId,
    this.type,
    this.level,
    this.age,
    this.baseScore,
  });

  Game copy({
    int id,
    int gameId,
    int type,
    int level,
    int age,
    int skipTime,
    int baseScore,
  }) =>
      Game(
        id: this.id,
        gameId: this.gameId,
        type: this.type,
        level: this.level,
        age: this.age,
        baseScore: this.baseScore,
      );

  static Game fromJson(Map<String, Object> json) {
    return Game(
        id: json[GameModel.id],
        gameId: json[GameModel.gameId],
        type: json[GameModel.type],
        level: json[GameModel.level],
        age: json[GameModel.age],
        baseScore: json[GameModel.baseScore]);
  }

  Map<String, Object> toJson() => {
        GameModel.id: id,
        GameModel.gameId: gameId,
        GameModel.type: type,
        GameModel.level: level,
        GameModel.age: age,
        GameModel.baseScore: baseScore,
      };
}
