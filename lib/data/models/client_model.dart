class Client {
  final int idPerson;
  final String razonSocial;
  final String nipTipo;
  final String nip;
  final String email;
  final String cellular;
  final String address;
  final bool statusPerson;

  Client({
    required this.idPerson,
    required this.razonSocial,
    required this.nipTipo,
    required this.nip,
    required this.email,
    required this.cellular,
    required this.address,
    required this.statusPerson,
  });

  Client copyWith({
    int? idPerson,
    String? razonSocial,
    String? nipTipo,
    String? nip,
    String? email,
    String? cellular,
    String? address,
    bool? statusPerson,
  }) {
    return Client(
      idPerson: idPerson ?? this.idPerson,
      razonSocial: razonSocial ?? this.razonSocial,
      nipTipo: nipTipo ?? this.nipTipo,
      nip: nip ?? this.nip,
      email: email ?? this.email,
      cellular: cellular ?? this.cellular,
      address: address ?? this.address,
      statusPerson: statusPerson ?? this.statusPerson,
    );
  }

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      idPerson: json['id_person'] ?? 0,
      razonSocial: json['razon_social'] ?? '',
      nipTipo: json['nip_tipo'] ?? '',
      nip: json['nip'] ?? '',
      email: json['email'] ?? '',
      cellular: json['cellular'] ?? '',
      // NOTE: backend sends "anddress" misspelled
      address: json['anddress'] ?? '',
      statusPerson: json['status_person'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_person': idPerson,
      'razon_social': razonSocial,
      'nip_tipo': nipTipo,
      'nip': nip,
      'email': email,
      'cellular': cellular,
      'anddress': address,
      'status_person': statusPerson,
    };
  }
}
