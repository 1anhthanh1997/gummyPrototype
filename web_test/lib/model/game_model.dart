final String tableNotes = 'games';

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
        id: id ?? this.id,
        type: type ?? this.type,
        level: level ?? this.level,
        age: age ?? this.age,
        skipTime: skipTime ?? this.skipTime,
        baseScore: baseScore ?? this.baseScore,
      );

  static Game fromJson(Map<String, Object> json) => Game(
      id: json[GameModel.id] as int,
      type: json[GameModel.type] as int,
      level: json[GameModel.level] as int,
      age: json[GameModel.age] as int,
      skipTime: json[GameModel.skipTime] as int,
      baseScore: json[GameModel.baseScore] as int);

  Map<String, Object> toJson() => {
        GameModel.id: id,
        GameModel.type: type,
        GameModel.level: level,
        GameModel.age: age,
        GameModel.skipTime: skipTime,
        GameModel.baseScore: baseScore,
      };
}
