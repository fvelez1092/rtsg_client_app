import 'dart:convert';

TripCategory tripCategoryFromJson(String str) =>
    TripCategory.fromJson(json.decode(str));

String tripCategoryToJson(TripCategory data) => json.encode(data.toJson());

class TripCategory {
  final int? idTravelCategory;
  final String? name;
  final String? description;
  final int? baseFare;
  final bool? status;
  final DateTime? createdAt;
  final dynamic updatedAt;

  TripCategory({
    this.idTravelCategory,
    this.name,
    this.description,
    this.baseFare,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory TripCategory.fromJson(Map<String, dynamic> json) => TripCategory(
    idTravelCategory: json["id_travel_category"],
    name: json["name"],
    description: json["description"],
    baseFare: json["base_fare"],
    status: json["status"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id_travel_category": idTravelCategory,
    "name": name,
    "description": description,
    "base_fare": baseFare,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt,
  };
}
