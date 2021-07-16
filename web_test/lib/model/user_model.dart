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
  static final String correctTime = 'correctTime';
  static final String wrongTime = 'wrongTime';
}

class User {
  int id;
  String name;
  String image;
  int score;
  int correctTime;
  int wrongTime;

  User(
      {this.id,
      this.name,
      this.image,
      this.score,
      this.correctTime,
      this.wrongTime});

  User copy(
          {int id,
          String name,
          String image,
          int score,
          int correctTime,
          int wrongTime}) =>
      User(
        id: id ?? this.id,
        name: name ?? this.name,
        image: image ?? this.image,
        score: score ?? this.score,
        correctTime: correctTime ?? this.correctTime,
        wrongTime: wrongTime ?? this.wrongTime,
      );

  static User fromJson(Map<String, Object> json) => User(
        id: json[UserModel.id] as int,
        name: json[UserModel.name] as String,
        image: json[UserModel.image] as String,
        score: json[UserModel.score] as int,
        correctTime: json[UserModel.correctTime] as int,
        wrongTime: json[UserModel.wrongTime] as int,
      );

  Map<String, Object> toJson() => {
        UserModel.id: id,
        UserModel.name: name,
        UserModel.image: image,
        UserModel.score: score,
        UserModel.correctTime: correctTime,
        UserModel.wrongTime: wrongTime
      };
}
