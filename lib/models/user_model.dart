class UserModel {
  final int id;
  final String name;
  final String apellidos;
  final String username;
  final String email;
  final String? phone;
  final String? address;
  final String provider;

  UserModel({
    required this.id,
    required this.name,
    required this.apellidos,
    required this.username,
    required this.email,
    this.phone,
    this.address,
    this.provider = 'local',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      apellidos: json['apellidos'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      address: json['address'],
      provider: json['provider'] ?? 'local',
    );
  }

  UserModel copyWith({
    String? name,
    String? apellidos,
    String? username,
    String? phone,
    String? address,
    String? provider,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      apellidos: apellidos ?? this.apellidos,
      username: username ?? this.username,
      email: email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      provider: provider ?? this.provider,
    );
  }
}
