import 'dart:convert';

import 'package:app_rtsg_client/data/models/user_model.dart';

LoginResponse loginResponseFromJson(String str) =>
    LoginResponse.fromJson(json.decode(str) as Map<String, dynamic>);

String loginResponseToJson(LoginResponse data) => json.encode(data.toJson());

class LoginResponse {
  final bool? ok;
  final bool? status;
  final String? message;
  final Data? data;
  final String? error;
  final String? token;

  const LoginResponse({
    this.ok,
    this.status,
    this.message,
    this.data,
    this.error,
    this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['datos'] ?? json['data'];
    final dataMap = rawData is Map
        ? Map<String, dynamic>.from(rawData)
        : null;

    final state = _asBool(json['estado'] ?? json['ok'] ?? json['status']);
    final observation = _asString(
      json['observacion'] ?? json['message'] ?? json['error'],
    );

    return LoginResponse(
      ok: state,
      status: state,
      message: observation,
      data: dataMap == null ? null : Data.fromJson(dataMap),
      error: _asString(json['error']),
      token: _asString(json['token'] ?? dataMap?['token']),
    );
  }

  bool get success => ok == true || status == true;
  User? get user => data?.user;

  Map<String, dynamic> toJson() => {
        'estado': success,
        'observacion': message,
        'datos': data?.toJson(),
        'error': error,
        'token': token,
      };
}

class Data {
  final User? user;
  final Company? company;
  final List<Role> roles;

  const Data({
    this.user,
    this.company,
    this.roles = const <Role>[],
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    final rawUser = json['user'];
    final User? parsedUser;

    if (rawUser is Map) {
      parsedUser = User.fromJson(Map<String, dynamic>.from(rawUser));
    } else if (_looksLikeDirectUser(json)) {
      // El contrato actual devuelve el usuario directamente dentro de `datos`.
      parsedUser = User.fromJson(json);
    } else {
      parsedUser = null;
    }

    final rawCompany = json['company'];
    final company = rawCompany is Map
        ? Company.fromJson(Map<String, dynamic>.from(rawCompany))
        : null;

    final rawRoles = json['roles'];
    final roles = rawRoles is List
        ? rawRoles
            .whereType<Map>()
            .map((item) => Role.fromJson(Map<String, dynamic>.from(item)))
            .toList()
        : <Role>[];

    return Data(user: parsedUser, company: company, roles: roles);
  }

  Map<String, dynamic> toJson() => {
        'user': user?.toJson(),
        'company': company?.toJson(),
        'roles': roles.map((role) => role.toJson()).toList(),
      };
}

class Company {
  final int? idCompany;
  final String? razonSocial;
  final dynamic businessName;
  final bool? statusCompany;

  const Company({
    this.idCompany,
    this.razonSocial,
    this.businessName,
    this.statusCompany,
  });

  factory Company.fromJson(Map<String, dynamic> json) => Company(
        idCompany: _asInt(json['id_company']),
        razonSocial: _asString(json['razon_social'] ?? json['razonsocial']),
        businessName: json['business_name'] ?? json['nombrecomercial'],
        statusCompany: _asBool(
          json['status_company'] ?? json['statuscompany'],
        ),
      );

  Map<String, dynamic> toJson() => {
        'id_company': idCompany,
        'razon_social': razonSocial,
        'business_name': businessName,
        'status_company': statusCompany,
      };
}

class Role {
  final int? idRole;
  final String? role;
  final bool? statusRole;

  const Role({this.idRole, this.role, this.statusRole});

  factory Role.fromJson(Map<String, dynamic> json) => Role(
        idRole: _asInt(json['id_role'] ?? json['rolid']),
        role: _asString(json['role'] ?? json['rol']),
        statusRole: _asBool(json['status_role'] ?? json['estado']),
      );

  Map<String, dynamic> toJson() => {
        'id_role': idRole,
        'role': role,
        'status_role': statusRole,
      };
}

bool _looksLikeDirectUser(Map<String, dynamic> json) {
  return json.containsKey('idusuario') ||
      json.containsKey('id_user') ||
      json.containsKey('idpersona') ||
      json.containsKey('id_person') ||
      json.containsKey('nombres_usuario') ||
      json.containsKey('usuario');
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

bool? _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value?.toString().trim().toLowerCase();
  if (text == 'true' || text == '1') return true;
  if (text == 'false' || text == '0') return false;
  return null;
}

String? _asString(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}
