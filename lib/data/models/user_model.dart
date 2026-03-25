class User {
  final String id;
  String name;
  String phone;
  String address;
  int age;
  bool status1;
  bool status2;
  bool status3;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.age,
    required this.status1,
    required this.status2,
    required this.status3,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}


