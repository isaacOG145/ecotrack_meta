// lib/presentacion/consumos_view_model.dart
import 'package:flutter/foundation.dart';
import '../datos/consumo_repository.dart';
import '../dominio/consumo.dart';
import '../dominio/meta.dart';

class ConsumosViewModel extends ChangeNotifier {
  final ConsumoRepository _repositorio;

  ConsumosViewModel(this._repositorio);

  List<Consumo> consumos = [];
  String? error;
  bool guardando = false;
  double meta = metaInicial;

  // --- Derivados ---
  double get total => consumos.fold(0.0, (suma, item) => suma + item.litros);

  double get avance => avanceDeMeta(total: total, meta: meta);

  bool get metaSuperada => total > meta;

  // --- Métodos ---
  Future<void> cargar() async {
    consumos = await _repositorio.todos();
    notifyListeners();
  }

  Future<bool> guardar(String laboratorio, String litrosTexto) async {
    // 1. Convertir texto a número aceptando comas decimales y espacios
    final textoLimpio = litrosTexto.replaceAll(' ', '').replaceAll(',', '.');
    final litros = double.tryParse(textoLimpio);

    // 2. Validar con el dominio
    // 2. Validar con el dominio
    final validacion = validarConsumo(laboratorio: laboratorio, litros: litros);
    if (validacion != null) {
      error = validacion;
      notifyListeners();
      return false;
    }

    // 3. Marca guardando y limpia errores previos
    guardando = true;
    error = null;
    notifyListeners();

    // 4. Guardar en repositorio y recargar la lista
    await _repositorio.guardar(Consumo(laboratorio: laboratorio, litros: litros!));
    consumos = await _repositorio.todos();

    // 5. Finalizar estado
    guardando = false;
    notifyListeners();
    return true;
  }

  void subirMeta() {
    meta = ajustarMeta(meta, pasoMeta);
    notifyListeners();
  }

  void bajarMeta() {
    meta = ajustarMeta(meta, -pasoMeta);
    notifyListeners();
  }
}