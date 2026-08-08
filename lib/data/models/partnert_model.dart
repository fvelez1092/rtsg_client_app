class PartnerModel {
  final int id;
  final String name;
  final String category;
  final String logoUrl;
  final double rating;

  const PartnerModel({
    required this.id,
    required this.name,
    required this.category,
    required this.logoUrl,
    required this.rating,
  });

  factory PartnerModel.fromJson(Map<String, dynamic> json) {
    return PartnerModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      logoUrl: json['logo_url'] ?? '',
      rating: double.tryParse(json['rating'].toString()) ?? 0,
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

  const PartnerAdModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.partnerName,
    this.actionUrl,
  });

  factory PartnerAdModel.fromJson(Map<String, dynamic> json) {
    return PartnerAdModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      partnerName: json['partner_name'] ?? '',
      actionUrl: json['action_url'],
    );
  }
}
