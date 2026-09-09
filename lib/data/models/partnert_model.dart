class PartnerModel {
  final int id;
  final String name;
  final String category;
  final String logoUrl;
  final double rating;
  final String description;
  final bool verified;
  final bool active;
  final double? latitude;
  final double? longitude;
  final String? owner;
  final DateTime? startDate;
  final DateTime? endDate;

  const PartnerModel({
    required this.id,
    required this.name,
    required this.category,
    required this.logoUrl,
    required this.rating,
    this.description = '',
    this.verified = false,
    this.active = true,
    this.latitude,
    this.longitude,
    this.owner,
    this.startDate,
    this.endDate,
  });

  factory PartnerModel.fromJson(Map<String, dynamic> json) {
    final coordinates = json['coordenadas'];
    final coords = coordinates is Map
        ? Map<String, dynamic>.from(coordinates)
        : const <String, dynamic>{};

    return PartnerModel(
      id: _asInt(json['id_partner'] ?? json['id']),
      name: (json['nombre_comercio'] ?? json['name'] ?? '').toString(),
      category: (json['categoria'] ?? json['category'] ?? '').toString(),
      logoUrl: (json['logo'] ?? json['logo_url'] ?? '').toString(),
      rating: _asDouble(json['calificacion'] ?? json['rating']),
      description: (json['descripcion'] ?? json['description'] ?? '').toString(),
      verified: _asBool(json['verificado']),
      active: json.containsKey('estado') ? _asBool(json['estado']) : true,
      latitude: _asNullableDouble(coords['latitud']),
      longitude: _asNullableDouble(coords['longitud']),
      owner: json['propietario']?.toString(),
      startDate: _asDate(json['fecha_inicio']),
      endDate: _asDate(json['fecha_fin']),
    );
  }
}

class PartnerAdImageModel {
  final int id;
  final String imageUrl;
  final String description;
  final int order;
  final bool primary;
  final bool active;

  const PartnerAdImageModel({
    required this.id,
    required this.imageUrl,
    this.description = '',
    this.order = 0,
    this.primary = false,
    this.active = true,
  });

  factory PartnerAdImageModel.fromJson(Map<String, dynamic> json) {
    return PartnerAdImageModel(
      id: _asInt(json['id_publicidad_imagen'] ?? json['id']),
      imageUrl: (json['imagen'] ?? json['image_url'] ?? '').toString(),
      description: (json['descripcion'] ?? json['description'] ?? '').toString(),
      order: _asInt(json['orden']),
      primary: _asBool(json['principal']),
      active: json.containsKey('estado') ? _asBool(json['estado']) : true,
    );
  }
}

class PartnerAdModel {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final String partnerName;
  final String? actionUrl;
  final int? partnerId;
  final String logoUrl;
  final String actionType;
  final int priority;
  final bool active;
  final double rating;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<PartnerAdImageModel> images;

  const PartnerAdModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.partnerName,
    this.actionUrl,
    this.partnerId,
    this.logoUrl = '',
    this.actionType = 'NINGUNA',
    this.priority = 0,
    this.active = true,
    this.rating = 0,
    this.startDate,
    this.endDate,
    this.images = const <PartnerAdImageModel>[],
  });

  factory PartnerAdModel.fromJson(Map<String, dynamic> json) {
    final rawImages = json['imagenes'];
    final images = rawImages is List
        ? rawImages
            .whereType<Map>()
            .map((item) => PartnerAdImageModel.fromJson(
                  Map<String, dynamic>.from(item),
                ))
            .where((item) => item.active && item.imageUrl.isNotEmpty)
            .toList()
        : <PartnerAdImageModel>[];

    images.sort((a, b) {
      if (a.primary != b.primary) return a.primary ? -1 : 1;
      return a.order.compareTo(b.order);
    });

    final mainImage = images.isNotEmpty
        ? images.first.imageUrl
        : (json['image_url'] ?? '').toString();

    return PartnerAdModel(
      id: _asInt(json['id_publicidad'] ?? json['id']),
      title: (json['titulo'] ?? json['title'] ?? '').toString(),
      description: (json['descripcion'] ?? json['description'] ?? '').toString(),
      imageUrl: mainImage,
      partnerName:
          (json['nombre_comercio'] ?? json['partner_name'] ?? '').toString(),
      actionUrl: (json['enlace'] ?? json['action_url'])?.toString(),
      partnerId: _asNullableInt(json['partner_id']),
      logoUrl: (json['logo'] ?? '').toString(),
      actionType: (json['tipo_accion'] ?? 'NINGUNA').toString(),
      priority: _asInt(json['prioridad']),
      active: json.containsKey('estado') ? _asBool(json['estado']) : true,
      rating: _asDouble(json['calificacion']),
      startDate: _asDate(json['fecha_inicio']),
      endDate: _asDate(json['fecha_fin']),
      images: images,
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int? _asNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double _asDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

double? _asNullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final normalized = value?.toString().trim().toLowerCase();
  return normalized == 'true' || normalized == '1' || normalized == 'si';
}

DateTime? _asDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
