import 'package:forca_de_vendas/api/common/formatter/date_time_formatter.dart';
import 'package:sqflite/sqflite.dart';

import '../../../api/common/debugger.dart';
import '../database/database_ambiente.dart';

class ChegadaCliente {
  late final DateTime chegada;
  final int idVisita;

  double titulosVencer = 0;
  double limiteCredito = 0;

  // late final String statusUltimaVisita;

  ChegadaCliente(this.idVisita) {
    chegada = DateTime.now();
  }

  Map<String, Object?> toMap() {
    return {'ID_VISITA': idVisita, 'DATA': DateFormatter.databaseDateTime.format(chegada)};
  }

  /// Insere os dados de chegada no cliente [TB_VISITA_CHEGADA]
  Future<void> salvar() async {
    try {
      final db = await DatabaseAmbiente.getDatabase();
      await db.insert(
        'TB_VISITA_CHEGADA',
        toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } catch (e) {
      printDebug(e.toString());
    }
  }
}
