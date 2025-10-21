class Auth {
  final String email;
  final String password;

  Auth({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  factory Auth.fromJson(Map<String, dynamic> json) {
    return Auth(
      email: json['email'],
      password: json['password'],
    );
  }
}