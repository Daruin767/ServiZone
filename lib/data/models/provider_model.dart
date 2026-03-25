class ProviderModel {
  final String id;
  String name;
  String email;
  String phone;
  String category;
  String address;
  double rating;
  int completedServices;
  bool isActive;
  bool isVerified;
  final DateTime joinDate;

  ProviderModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.category,
    required this.address,
    required this.rating,
    required this.completedServices,
    required this.isActive,
    required this.isVerified,
    DateTime? joinDate,
  }) : joinDate = joinDate ?? DateTime.now();
}


