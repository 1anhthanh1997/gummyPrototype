final String tableGames = 'games';
final String _columnAdditionInfo = 'additionInfo';

final String updateColumnAdditionInfo = '''
        ALTER TABLE $tableGames ADD COLUMN $_columnAdditionInfo text
        ''';
class GameModel {
  static final List<String> values = [
    /// Add all fields
    id, type, level, age, age, skipTime, baseScore
  ];

  static final String id = '_id';
  static final String type = 'type';
  static final String level = 'level';
  static final String age = 'age';
  static final String skipTime = 'skipTime';
  static final String baseScore = 'baseScore';
}

class Game {
  final int id;
  final int type;
  final int level;
  final int age;
  final int skipTime;
  final int baseScore;

  const Game({
    this.id,
    this.type,
    this.level,
    this.age,
    this.skipTime,
    this.baseScore,
  });

  Game copy({
    int id,
    int type,
    int level,
    int age,
    int skipTime,
    int baseScore,
  }) =>
      Game(
        id: this.id,
        type: this.type,
        level: this.level,
        age: this.age,
        skipTime: this.skipTime,
        baseScore: this.baseScore,
      );

  static Game fromJson(Map<String, Object> json) {
    print(json[GameModel.age] is String);
    return Game(
        id: json[GameModel.id],
        type: json[GameModel.type],
        level: json[GameModel.level],
        age: json[GameModel.age],
        skipTime: json[GameModel.skipTime],
        baseScore: json[GameModel.baseScore]);
  }

  Map<String, Object> toJson() => {
        GameModel.id: id,
        GameModel.type: type,
        GameModel.level: level,
        GameModel.age: age,
        GameModel.skipTime: skipTime,
        GameModel.baseScore: baseScore,
      };
}
