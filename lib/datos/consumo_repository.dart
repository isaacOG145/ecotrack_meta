// lib/datos/consumo_repository.dart
import '../dominio/consumo.dart';

abstract class ConsumoRepository {
  Future<void> guardar(Consumo consumo);
  Future<List<Consumo>> todos();
}

