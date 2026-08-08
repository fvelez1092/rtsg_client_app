import 'package:app_rtsg_client/data/models/partnert_model.dart';

class HomeService {
  Future<List<PartnerAdModel>> getPartnerAds() async {
    await Future.delayed(const Duration(milliseconds: 700));

    return const [
      PartnerAdModel(
        id: 1,
        title: '20% de descuento',
        description: 'Presenta RTSG y obtén descuento en tu compra.',
        imageUrl:
            'https://images.unsplash.com/photo-1441986300917-64674bd600d8',
        partnerName: 'Partner Comercial',
      ),
      PartnerAdModel(
        id: 2,
        title: 'Promoción exclusiva',
        description: 'Beneficios especiales para usuarios de RTSG.',
        imageUrl: 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d',
        partnerName: 'Partner RTSG',
      ),
      PartnerAdModel(
        id: 3,
        title: 'Viaja y gana',
        description: 'Acumula beneficios en establecimientos aliados.',
        imageUrl:
            'https://images.unsplash.com/photo-1528698827591-e19ccd7bc23d',
        partnerName: 'Beneficios RTSG',
      ),
    ];
  }

  Future<List<PartnerModel>> getPartners() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return const [
      PartnerModel(
        id: 1,
        name: 'Coffee Place',
        category: 'Cafetería',
        logoUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb',
        rating: 4.8,
      ),
      PartnerModel(
        id: 2,
        name: 'Market Express',
        category: 'Supermercado',
        logoUrl: 'https://images.unsplash.com/photo-1578916171728-46686eac8d58',
        rating: 4.7,
      ),
      PartnerModel(
        id: 3,
        name: 'Restaurante Central',
        category: 'Restaurante',
        logoUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4',
        rating: 4.9,
      ),
    ];
  }
}
