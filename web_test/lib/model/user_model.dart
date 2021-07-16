final String tableUsers = 'users';

final String _columnAdditionInfo = 'additionInfo';

final String updateColumnAdditionInfoUser = '''
        ALTER TABLE $tableUsers ADD COLUMN $_columnAdditionInfo text
        ''';

class UserModel {
  static final List<String> values = [
    /// Add all fields
    id, name, image, score
  ];

  static final String id = '_id';
  static final String name = 'name';
  static final String image = 'image';
  static final String score = 'score';
}

class User {
  final int id;
  final String name;
  final String image;
  final int score;

  const User({
    this.id,
    this.name,
    this.image,
    this.score,
  });

  User copy({
    int id,
    String name,
    String image,
    int score,
  }) =>
      User(
        id: id ?? this.id,
        name: name ?? this.name,
        image: image ?? this.image,
        score: score ?? this.score,
      );

  static User fromJson(Map<String, Object> json) => User(
      id: json[UserModel.id] as int,
      name: json[UserModel.name] as String,
      image: json[UserModel.image] as String,
      score: json[UserModel.score] as int);

  Map<String, Object> toJson() => {
        UserModel.id: id,
        UserModel.name: name,
        UserModel.image: image,
        UserModel.score: score,
      };
}
