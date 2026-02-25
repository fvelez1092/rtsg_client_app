class LoginRequest {
  const LoginRequest(this.userName, this.password);
  final String userName;
  final String password;
  Map<String, dynamic> toJson() {
    return {'userName': userName, 'password': password};
  }
}
