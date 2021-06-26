class Person {
  late String name;
  late String email;

  Person({this.name = '', this.email = ''});
  Person.fromJson(Map<String,dynamic>json){
    name=json['name'];
    email=json['email'];
  }
}
