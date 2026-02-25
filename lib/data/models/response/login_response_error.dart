import 'dart:convert';

class LoginResponseError {
  bool estado;
  String observacion;
  Datos datos;

  LoginResponseError({
    required this.estado,
    required this.observacion,
    required this.datos,
  });

  factory LoginResponseError.fromRawJson(String str) =>
      LoginResponseError.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LoginResponseError.fromJson(Map<String, dynamic> json) =>
      LoginResponseError(
        estado: json["estado"],
        observacion: json["observacion"],
        datos: Datos.fromJson(json["datos"]),
      );

  Map<String, dynamic> toJson() => {
        "estado": estado,
        "observacion": observacion,
        "datos": datos.toJson(),
      };
}

class Datos {
  Datos();

  factory Datos.fromRawJson(String str) => Datos.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Datos.fromJson(Map<String, dynamic> json) => Datos();

  Map<String, dynamic> toJson() => {};
}
