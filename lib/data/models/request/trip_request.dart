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
  final String direccionDestino;
  final double latitudDestino;
  final double longitudDestino;
  final double distancia;
  final double costo;

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
    required this.direccionDestino,
    required this.latitudDestino,
    required this.longitudDestino,
    required this.distancia,
    required this.costo,
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
      'direcciondestino': direccionDestino,
      'coordenadasdestino': {'lat': latitudDestino, 'long': longitudDestino},
      'distancia': distancia,
      'costo': costo,
      if (personaDireccionId != null)
        'persona_direccion_id': personaDireccionId,
      if (baseId != null) 'baseid': baseId,
      'estadocarrera': estadoCarrera,
      'unidadid': unidadId,
      'usuarioid': usuarioId,
    };
  }
}
