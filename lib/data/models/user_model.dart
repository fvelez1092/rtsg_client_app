import 'package:app_rtsg_client/data/models/saved_address_model.dart';

class User {
  final int? idUser;
  final int? idPerson;
  final String? fullName;
  final String? birthDate;
  final String? documentNumber;
  final String? razonSocial;
  final String? username;
  final String? user;
  final String? nip;
  final String? email;
  final String? landline;
  final String? cellphone;
  final String? address;
  final String? role;
  final int? idRole;
  final String? sex;
  final bool? recovery;
  final dynamic photo;
  final bool? statusUser;
  final String? observation;
  final String? placeOfBirth;
  final String? nationality;
  final String? personType;
  final int? parishId;
  final int? occupationId;
  final String? occupation;
  final int? customerCode;
  final String? registrationDate;
  final String? modificationDate;
  final bool? roleActive;
  final List<SavedAddress> addresses;
  final List<UserCompany> companies;
  final List<UserUnit> units;
  final List<UserDriver> drivers;

  const User({
    this.idUser,
    this.idPerson,
    this.fullName,
    this.birthDate,
    this.documentNumber,
    this.razonSocial,
    this.username,
    this.user,
    this.nip,
    this.email,
    this.landline,
    this.cellphone,
    this.address,
    this.role,
    this.idRole,
    this.sex,
    this.recovery,
    this.photo,
    this.statusUser,
    this.observation,
    this.placeOfBirth,
    this.nationality,
    this.personType,
    this.parishId,
    this.occupationId,
    this.occupation,
    this.customerCode,
    this.registrationDate,
    this.modificationDate,
    this.roleActive,
    this.addresses = const <SavedAddress>[],
    this.companies = const <UserCompany>[],
    this.units = const <UserUnit>[],
    this.drivers = const <UserDriver>[],
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        idUser: _asInt(
          json['id_user'] ?? json['idusuario'] ?? json['usuarioid'],
        ),
        idPerson: _asInt(
          json['id_person'] ?? json['idpersona'] ?? json['id_persona'],
        ),
        fullName: _asString(
          json['full_name'] ??
              json['nombres_usuario'] ??
              json['razon_social'] ??
              json['username'],
        ),
        birthDate: _asString(
          json['birth_date'] ??
              json['fechanacimiento'] ??
              json['fecha_nacimiento'],
        ),
        documentNumber: _asString(
          json['document_number'] ??
              json['cedulausuario'] ??
              json['cedula_ruc'],
        ),
        razonSocial: _asString(
          json['razon_social'] ?? json['nombres_usuario'],
        ),
        username: _asString(json['username'] ?? json['nombres_usuario']),
        user: _asString(json['user'] ?? json['usuario']),
        nip: _asString(json['nip']),
        email: _asString(
          json['email'] ?? json['correo'] ?? json['usuario'],
        ),
        landline: _asString(
          json['landline'] ?? json['telefonofijo'] ?? json['telefono_fijo'],
        ),
        cellphone: _asString(
          json['cellular'] ??
              json['cellphone'] ??
              json['telefonocelular'] ??
              json['telefono_celular'],
        ),
        address: _asString(
          json['address'] ??
              json['anddress'] ??
              json['direccion'] ??
              _defaultAddressText(json['direcciones']),
        ),
        role: _asString(json['role'] ?? json['rol']),
        idRole: _asInt(json['id_role'] ?? json['rolid'] ?? json['rol_id']),
        sex: _asString(json['sex'] ?? json['sexo']),
        recovery: _asBool(json['recovery'] ?? json['recuperacion']),
        photo: json['photo'] ?? json['foto'],
        statusUser: _asBool(json['status_user'] ?? json['estado']),
        observation: _asString(
          json['observation'] ??
              json['observacion'] ??
              json['observacion_persona'],
        ),
        placeOfBirth: _asString(json['lugar_nacimiento']),
        nationality: _asString(json['nacionalidad']),
        personType: _asString(json['tipopersona']),
        parishId: _asInt(json['parroquia_id']),
        occupationId: _asInt(json['ocupacion_id']),
        occupation: _asString(json['ocupacion']),
        customerCode: _asInt(json['codigocliente']),
        registrationDate: _asString(json['fecha_registro']),
        modificationDate: _asString(json['fecha_modificacion']),
        roleActive: _asBool(json['estadorol']),
        addresses: _parseAddresses(json['direcciones']),
        companies: _parseCompanies(json['empresa'] ?? json['companies']),
        units: _parseUnits(json['unidad'] ?? json['units']),
        drivers: _parseDrivers(json['chofer'] ?? json['drivers']),
      );

  Map<String, dynamic> toJson() => {
        'id_user': idUser,
        'id_person': idPerson,
        'full_name': fullName,
        'birth_date': birthDate,
        'document_number': documentNumber,
        'razon_social': razonSocial,
        'username': username,
        'user': user,
        'nip': nip,
        'email': email,
        'landline': landline,
        'cellphone': cellphone,
        'address': address,
        'role': role,
        'id_role': idRole,
        'sex': sex,
        'recovery': recovery,
        'photo': photo,
        'status_user': statusUser,
        'observation': observation,
        'place_of_birth': placeOfBirth,
        'nationality': nationality,
        'person_type': personType,
        'parish_id': parishId,
        'occupation_id': occupationId,
        'occupation': occupation,
        'customer_code': customerCode,
        'registration_date': registrationDate,
        'modification_date': modificationDate,
        'role_active': roleActive,
        'addresses': addresses.map((address) => address.toUpdateJson()).toList(),
        'companies': companies.map((company) => company.toJson()).toList(),
        'units': units.map((unit) => unit.toJson()).toList(),
        'drivers': drivers.map((driver) => driver.toJson()).toList(),
      };

  String get displayName {
    final values = [fullName, razonSocial, username, user, email];
    for (final value in values) {
      if (value != null && value.trim().isNotEmpty) return value.trim();
    }
    return '';
  }

  UserCompany? get primaryCompany => companies.isEmpty ? null : companies.first;
  UserUnit? get primaryUnit => units.isEmpty ? null : units.first;

  SavedAddress? get primaryAddress {
    for (final address in addresses) {
      if (address.isDefault) return address;
    }
    return addresses.isEmpty ? null : addresses.first;
  }
}

class UserCompany {
  final int? idCompany;
  final String? ruc;
  final String? razonSocial;
  final String? nombreComercial;
  final String? celular;
  final String? telefono;
  final String? correo;
  final String? direccion;
  final String? enlace;
  final int? numeroUnidades;
  final bool? statusCompany;
  final String? observationCompany;
  final String? dateRegisterCompany;
  final String? dateModifyCompany;
  final int? paisId;
  final int? provinciaId;
  final int? cantonId;
  final int? tiempoAlertaAgendada;
  final dynamic logo;

  const UserCompany({
    this.idCompany,
    this.ruc,
    this.razonSocial,
    this.nombreComercial,
    this.celular,
    this.telefono,
    this.correo,
    this.direccion,
    this.enlace,
    this.numeroUnidades,
    this.statusCompany,
    this.observationCompany,
    this.dateRegisterCompany,
    this.dateModifyCompany,
    this.paisId,
    this.provinciaId,
    this.cantonId,
    this.tiempoAlertaAgendada,
    this.logo,
  });

  factory UserCompany.fromJson(Map<String, dynamic> json) => UserCompany(
        idCompany: _asInt(json['id_company'] ?? json['idCompany']),
        ruc: _asString(json['ruc']),
        razonSocial: _asString(json['razonsocial'] ?? json['razon_social']),
        nombreComercial: _asString(
          json['nombrecomercial'] ?? json['nombre_comercial'],
        ),
        celular: _asString(json['celular']),
        telefono: _asString(json['telefono']),
        correo: _asString(json['correo']),
        direccion: _asString(json['direccion']),
        enlace: _asString(json['enlace']),
        numeroUnidades: _asInt(
          json['numerounidades'] ?? json['numero_unidades'],
        ),
        statusCompany: _asBool(
          json['statuscompany'] ?? json['status_company'],
        ),
        observationCompany: _asString(
          json['observationcompany'] ?? json['observation_company'],
        ),
        dateRegisterCompany: _asString(
          json['dateregistercompany'] ?? json['date_register_company'],
        ),
        dateModifyCompany: _asString(
          json['datemodifycompany'] ?? json['date_modify_company'],
        ),
        paisId: _asInt(json['pais_id']),
        provinciaId: _asInt(json['provincia_id']),
        cantonId: _asInt(json['canton_id']),
        tiempoAlertaAgendada: _asInt(json['tiempoalertaagendada']),
        logo: json['logo'],
      );

  Map<String, dynamic> toJson() => {
        'id_company': idCompany,
        'ruc': ruc,
        'razonsocial': razonSocial,
        'nombrecomercial': nombreComercial,
        'celular': celular,
        'telefono': telefono,
        'correo': correo,
        'direccion': direccion,
        'enlace': enlace,
        'numerounidades': numeroUnidades,
        'statuscompany': statusCompany,
        'observationcompany': observationCompany,
        'dateregistercompany': dateRegisterCompany,
        'datemodifycompany': dateModifyCompany,
        'pais_id': paisId,
        'provincia_id': provinciaId,
        'canton_id': cantonId,
        'tiempoalertaagendada': tiempoAlertaAgendada,
        'logo': logo,
      };
}

class UserUnit {
  final int? id;
  final String? plate;
  final String? brand;
  final String? model;
  final String? vehicleYear;
  final String? lastReviewDate;
  final String? observation;
  final int? partnerId;
  final bool? status;
  final int? unitNumber;
  final String? razonSocial;
  final String? registerDate;
  final String? modifyDate;
  final String? time;
  final String? observation10;

  const UserUnit({
    this.id,
    this.plate,
    this.brand,
    this.model,
    this.vehicleYear,
    this.lastReviewDate,
    this.observation,
    this.partnerId,
    this.status,
    this.unitNumber,
    this.razonSocial,
    this.registerDate,
    this.modifyDate,
    this.time,
    this.observation10,
  });

  factory UserUnit.fromJson(Map<String, dynamic> json) => UserUnit(
        id: _asInt(json['id']),
        plate: _asString(json['placa'] ?? json['plate']),
        brand: _asString(json['marca'] ?? json['brand']),
        model: _asString(json['modelo'] ?? json['model']),
        vehicleYear: _asString(
          json['ano_vehiculo'] ??
              json['año_vehiculo'] ??
              json['vehicle_year'],
        ),
        lastReviewDate: _asString(
          json['fechaultimarevision'] ??
              json['fecha_ultima_revision'] ??
              json['last_review_date'],
        ),
        observation: _asString(json['observacion'] ?? json['observation']),
        partnerId: _asInt(json['socio_id'] ?? json['partner_id']),
        status: _asBool(json['estado'] ?? json['status']),
        unitNumber: _asInt(
          json['numerounidad'] ?? json['numero_unidad'] ?? json['unit_number'],
        ),
        razonSocial: _asString(json['razon_social']),
        registerDate: _asString(json['fecha_registro'] ?? json['register_date']),
        modifyDate: _asString(
          json['fecha_modificacion'] ?? json['modify_date'],
        ),
        time: _asString(json['hora'] ?? json['time']),
        observation10: _asString(json['observacion10']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'placa': plate,
        'marca': brand,
        'modelo': model,
        'ano_vehiculo': vehicleYear,
        'fechaultimarevision': lastReviewDate,
        'observacion': observation,
        'socio_id': partnerId,
        'estado': status,
        'numerounidad': unitNumber,
        'razon_social': razonSocial,
        'fecha_registro': registerDate,
        'fecha_modificacion': modifyDate,
        'hora': time,
        'observacion10': observation10,
      };
}

class UserDriver {
  final int? id;
  final int? personId;
  final String? fullName;
  final String? email;
  final String? cellphone;
  final int? unitId;
  final int? unitNumber;
  final String? plate;
  final bool? status;

  const UserDriver({
    this.id,
    this.personId,
    this.fullName,
    this.email,
    this.cellphone,
    this.unitId,
    this.unitNumber,
    this.plate,
    this.status,
  });

  factory UserDriver.fromJson(Map<String, dynamic> json) => UserDriver(
        id: _asInt(json['id']),
        personId: _asInt(json['personaid'] ?? json['persona_id']),
        fullName: _asString(json['nombre_persona'] ?? json['nombres']),
        email: _asString(json['correo'] ?? json['email']),
        cellphone: _asString(
          json['telefonocelular'] ?? json['telefono_celular'],
        ),
        unitId: _asInt(json['unidadid'] ?? json['unidad_id']),
        unitNumber: _asInt(json['numerounidad'] ?? json['numero_unidad']),
        plate: _asString(json['placa']),
        status: _asBool(json['estado']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'persona_id': personId,
        'nombre_persona': fullName,
        'correo': email,
        'telefono_celular': cellphone,
        'unidad_id': unitId,
        'numero_unidad': unitNumber,
        'placa': plate,
        'estado': status,
      };
}

List<SavedAddress> _parseAddresses(dynamic value) {
  if (value is! List) return const <SavedAddress>[];
  return value
      .whereType<Map>()
      .map((item) => SavedAddress.fromJson(Map<String, dynamic>.from(item)))
      .toList();
}

String? _defaultAddressText(dynamic value) {
  final addresses = _parseAddresses(value);
  if (addresses.isEmpty) return null;

  for (final address in addresses) {
    if (address.isDefault) return address.address;
  }
  return addresses.first.address;
}

List<UserDriver> _parseDrivers(dynamic value) {
  if (value is! List) return const <UserDriver>[];
  return value
      .whereType<Map>()
      .map((item) => UserDriver.fromJson(Map<String, dynamic>.from(item)))
      .toList();
}

List<UserCompany> _parseCompanies(dynamic value) {
  if (value is! List) return const <UserCompany>[];
  return value
      .whereType<Map>()
      .map((item) => UserCompany.fromJson(Map<String, dynamic>.from(item)))
      .toList();
}

List<UserUnit> _parseUnits(dynamic value) {
  if (value is! List) return const <UserUnit>[];
  return value
      .whereType<Map>()
      .map((item) => UserUnit.fromJson(Map<String, dynamic>.from(item)))
      .toList();
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
