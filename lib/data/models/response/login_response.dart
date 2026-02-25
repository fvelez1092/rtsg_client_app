import 'dart:convert';

import 'package:app_rtsg_client/data/models/user_model.dart';

LoginResponse loginResponseFromJson(String str) =>
    LoginResponse.fromJson(json.decode(str));

String loginResponseToJson(LoginResponse data) => json.encode(data.toJson());

class LoginResponse {
  final bool ok;
  final int? status;
  final String? message;
  final Data? data;
  final String? error;
  final String? token;

  LoginResponse({
    required this.ok,
    this.status,
    this.message,
    this.data,
    this.error,
    this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    ok: json["ok"],
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    error: json["error"],
    token: json["token"],
  );

  Map<String, dynamic> toJson() => {
    "ok": ok,
    "status": status,
    "message": message,
    "data": data?.toJson(),
    "error": error,
    "token": token,
  };
}

class Data {
  final User? user;
  final Company? company;
  final List<Role>? roles;

  Data({this.user, this.company, this.roles});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    company: json["company"] == null ? null : Company.fromJson(json["company"]),
    roles: json["roles"] == null
        ? []
        : List<Role>.from(json["roles"]!.map((x) => Role.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "user": user?.toJson(),
    "company": company?.toJson(),
    "roles": roles == null
        ? []
        : List<dynamic>.from(roles!.map((x) => x.toJson())),
  };
}

class Company {
  final int? idCompany;
  final String? razonSocial;
  final dynamic businessName;
  final bool? statusCompany;

  Company({
    this.idCompany,
    this.razonSocial,
    this.businessName,
    this.statusCompany,
  });

  factory Company.fromJson(Map<String, dynamic> json) => Company(
    idCompany: json["id_company"],
    razonSocial: json["razon_social"],
    businessName: json["business_name"],
    statusCompany: json["status_company"],
  );

  Map<String, dynamic> toJson() => {
    "id_company": idCompany,
    "razon_social": razonSocial,
    "business_name": businessName,
    "status_company": statusCompany,
  };
}

class Role {
  final int? idRole;
  final String? role;
  final bool? statusRole;

  Role({this.idRole, this.role, this.statusRole});

  factory Role.fromJson(Map<String, dynamic> json) => Role(
    idRole: json["id_role"],
    role: json["role"],
    statusRole: json["status_role"],
  );

  Map<String, dynamic> toJson() => {
    "id_role": idRole,
    "role": role,
    "status_role": statusRole,
  };
}
