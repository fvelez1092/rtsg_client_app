class TripRequest {
  final bool boot;
  final String telefonoCliente;
  final int clienteId;
  final String direccionPartida;
  final String ubicacionExactaCliente;
  final double latitudPartida;
  final double longitudPartida;
  final int? personaDireccionId;
  final int? baseId;
  final String estadoCarrera;
  final String unidadId;
  final int usuarioId;

  const TripRequest({
    required this.boot,
    required this.telefonoCliente,
    required this.clienteId,
    required this.direccionPartida,
    required this.ubicacionExactaCliente,
    required this.latitudPartida,
    required this.longitudPartida,
    this.personaDireccionId,
    this.baseId,
    required this.estadoCarrera,
    required this.unidadId,
    required this.usuarioId,
  });

  Map<String, dynamic> toJson() {
    return {
      'origen': 'M',
      'boot': boot,
      'telefonocliente': telefonoCliente,
      'clienteid': clienteId,
      'direccionpartida': direccionPartida,
      'ubicacionexactacliente': ubicacionExactaCliente,
      'coordenadaspartida': {'lat': latitudPartida, 'long': longitudPartida},
      if (personaDireccionId != null)
        'persona_direccion_id': personaDireccionId,
      if (baseId != null) 'baseid': baseId,
      'estadocarrera': estadoCarrera,
      'unidadid': unidadId,
      'usuarioid': usuarioId,
    };
  }
}
