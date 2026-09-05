import 'package:latlong2/latlong.dart';

class SavedAddress {
  final String id;
  final String label;
  final String address;
  final double latitude;
  final double longitude;

  const SavedAddress({
    required this.id,
    required this.label,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  LatLng get point => LatLng(latitude, longitude);

  factory SavedAddress.fromJson(Map<String, dynamic> json) {
    return SavedAddress(
      id: (json['id'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
  };
}
