import 'package:latlong2/latlong.dart';

class SavedAddress {
  final int? id;
  final int? personId;
  final String label;
  final String address;
  final String exactLocation;
  final int? baseId;
  final double? latitude;
  final double? longitude;
  final bool isDefault;
  final bool active;
  final String? city;
  final String? province;
  final String country;
  final String? postalCode;

  const SavedAddress({
    this.id,
    this.personId,
    required this.label,
    required this.address,
    this.exactLocation = '',
    this.baseId,
    this.latitude,
    this.longitude,
    this.isDefault = false,
    this.active = true,
    this.city,
    this.province,
    this.country = 'Ecuador',
    this.postalCode,
  });

  LatLng? get point {
    final lat = latitude;
    final lon = longitude;
    return lat == null || lon == null ? null : LatLng(lat, lon);
  }

  factory SavedAddress.fromJson(Map<String, dynamic> json) {
    final rawCoordinates = json['coordenadas'];
    final coordinates = rawCoordinates is Map
        ? Map<String, dynamic>.from(rawCoordinates)
        : const <String, dynamic>{};

    return SavedAddress(
      id: _asNullableInt(json['id_persona_direccion'] ?? json['id']),
      personId: _asNullableInt(json['persona_id']),
      label: (json['alias'] ?? json['label'] ?? '').toString(),
      address: (json['direccion'] ?? json['address'] ?? '').toString(),
      exactLocation:
          (json['ubicacion_exacta'] ?? json['exact_location'] ?? '').toString(),
      baseId: _asNullableInt(json['base_id']),
      latitude: _asNullableDouble(
        coordinates['lat'] ?? json['latitude'],
      ),
      longitude: _asNullableDouble(
        coordinates['long'] ?? json['longitude'],
      ),
      isDefault: _asBool(json['is_default']),
      active: json.containsKey('estado_direccion')
          ? _asBool(json['estado_direccion'])
          : true,
      city: json['ciudad']?.toString(),
      province: json['provincia']?.toString(),
      country: (json['pais'] ?? 'Ecuador').toString(),
      postalCode: json['codigo_postal']?.toString(),
    );
  }

  Map<String, dynamic> toUpdateJson() => {
        if (id != null) 'id_persona_direccion': id,
        'alias': label,
        'direccion': address,
        'ubicacion_exacta': exactLocation,
        'base_id': baseId,
        'is_default': isDefault,
        'coordenadas': {
          'lat': latitude,
          'long': longitude,
        },
      };
}

int? _asNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double? _asNullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final normalized = value?.toString().trim().toLowerCase();
  return normalized == 'true' || normalized == '1' || normalized == 'si';
}
