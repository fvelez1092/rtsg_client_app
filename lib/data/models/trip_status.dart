enum TripStatus {
  idle, // no hay carrera activa
  creating, // creando carrera
  searching, // buscando conductor
  accepted, // conductor aceptó
  arrived, // conductor llegó al origen
  started, // viaje iniciado
  completed, // viaje finalizado
  cancelled, // cancelado por cliente
  failed, // error
}
