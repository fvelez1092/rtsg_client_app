class TripRequest {
  final bool boot;
  final String telefonoCliente;
  final int clienteId;
  final String direccionPartida;
  final String estadoCarrera;
  final String unidadId;
  final int usuarioId;

  const TripRequest({
    required this.boot,
    required this.telefonoCliente,
    required this.clienteId,
    required this.direccionPartida,
    required this.estadoCarrera,
    required this.unidadId,
    required this.usuarioId,
  });

  Map<String, dynamic> toJson() {
    return {
      'boot': boot,
      'telefonocliente': telefonoCliente,
      'clienteid': clienteId,
      'direccionpartida': direccionPartida,
      'estadocarrera': estadoCarrera,
      'unidadid': unidadId,
      'usuarioid': usuarioId,
    };
  }
}
