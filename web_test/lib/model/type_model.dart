final String tableTypes = 'types';

final String _columnAdditionInfo = 'additionInfo';

final String updateColumnAdditionInfoType = '''
        ALTER TABLE $tableTypes ADD COLUMN $_columnAdditionInfo text
        ''';

class TypeModel {
  static final List<String> values = [
    /// Add all fields
    id, typeId, score, skipTime
  ];

  static final String id = '_id';
  static final String typeId = 'typeId';
  static final String score = 'score';
  static final String skipTime = 'skipTime';
}

class Type {
  int id;
  int typeId;
  int skipTime;
  double score;

  Type({
    this.id,
    this.typeId,
    this.skipTime,
    this.score,
  });

  Type copy({
    int id,
    int typeId,
    int skipTime,
    double score,
  }) =>
      Type(
        id: id ?? this.id,
        typeId: typeId ?? this.typeId,
        skipTime: skipTime ?? this.skipTime,
        score: score ?? this.score,
      );

  static Type fromJson(Map<String, Object> json) => Type(
      id: json[TypeModel.id] as int,
      typeId: json[TypeModel.typeId] as int,
      skipTime: json[TypeModel.skipTime] as int,
      score: json[TypeModel.score] as double);

  Map<String, Object> toJson() => {
        TypeModel.id: id,
        TypeModel.typeId: typeId,
        TypeModel.skipTime: skipTime,
        TypeModel.score: score,
      };
}
