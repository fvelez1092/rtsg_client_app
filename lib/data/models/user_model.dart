class User {
  final int? idUser;
  final int? idPerson;
  final String? razonSocial;
  final String? username;
  final String? user;
  final String? nip;
  final String? email;
  final String? cellphone;
  final String? address;
  final String? role;
  final int? idRole;
  final dynamic photo;
  final bool? statusUser;

  User({
    this.idUser,
    this.idPerson,
    this.razonSocial,
    this.username,
    this.user,
    this.photo,
    this.statusUser,
    this.nip,
    this.email,
    this.cellphone,
    this.address,
    this.role,
    this.idRole,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    idUser: json["id_user"],
    idPerson: json["id_person"],
    razonSocial: json["razon_social"],
    username: json["username"],
    user: json["user"],
    nip: json["nip"],
    email: json["email"],
    cellphone: json["cellular"],
    address: json["anddress"],
    role: json["role"],
    idRole: json["id_role"],
    photo: json["photo"],
    statusUser: json["status_user"],
  );

  Map<String, dynamic> toJson() => {
    "id_user": idUser,
    "id_person": idPerson,
    "razon_social": razonSocial,
    "username": username,
    "user": user,
    "nip": nip,
    "email": email,
    "cellphone": cellphone,
    "address": address,
    "role": role,
    "id_role": idRole,
    "photo": photo,
    "status_user": statusUser,
  };
}
