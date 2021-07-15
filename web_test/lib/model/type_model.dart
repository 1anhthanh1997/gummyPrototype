final String tableNotes = 'notes';

class TypeModel {
  static final List<String> values = [
    /// Add all fields
    id, score, skipTime
  ];

  static final String id = '_id';
  static final String score = 'score';
  static final String skipTime = 'skipTime';
}

class Type {
  final int id;
  final int skipTime;
  final int score;

  const Type({
    this.id,
    this.skipTime,
    this.score,
  });

  Type copy({
    int id,
    int skipTime,
    int score,
  }) =>
      Type(
        id: id ?? this.id,
        skipTime: skipTime ?? this.skipTime,
        score: score ?? this.score,
      );

  static Type fromJson(Map<String, Object> json) => Type(
      id: json[TypeModel.id] as int,
      skipTime: json[TypeModel.skipTime] as int,
      score: json[TypeModel.score] as int);

  Map<String, Object> toJson() => {
    TypeModel.id: id,
    TypeModel.skipTime: skipTime,
    TypeModel.score: score,
      };
}
