import 'package:forca_de_vendas/yukem_vendas/models/database_objects/visita.dart';
import 'package:uuid/uuid.dart';

import '../database/database_ambiente.dart';

class CancelamentoVisita {
  CancelamentoVisita(
      {required this.idVisita, this.idMotivo, this.observacao = ''});

  late final int idVisita;
  late int? idMotivo;
  late String observacao;

  toMap() {
    return {
      'ID_VISITA': idVisita,
      'ID_MOTIVO': idMotivo,
      'OBSERVACAO': observacao
    };
  }

  static CancelamentoVisita createObject(Map<String, dynamic> maps) {
    return CancelamentoVisita(
        idVisita: maps['ID_VISITA'],
        idMotivo: maps['ID_MOTIVO'],
        observacao: maps['OBSERVACAO']);
  }

  Future salvar() async {
    await DatabaseAmbiente.update('TB_VISITA', {'UUID': const Uuid().v4()},
        where: 'ID = ?', whereArgs: [idVisita]);
    await DatabaseAmbiente.insert('TB_VISITA_CANCELAMENTO', toMap());
  }

  static Future insertCancelamentos(
      Map<int, Visita> map, CancelamentoVisita cancelamentoVisita) async {
    List<CancelamentoVisita> list = [];

    map.forEach((key, value) {
      final CancelamentoVisita c = CancelamentoVisita(idVisita: key);
      c.idMotivo = cancelamentoVisita.idMotivo;
      c.observacao = cancelamentoVisita.observacao;
      list.add(c);
    });

    for (final item in list) {
      await item.salvar();

      // await DatabaseAmbiente.insert('TB_VISITA_CANCELAMENTO', item.toMap());
    }
  }

  static Future<CancelamentoVisita?> getCancelamentoVisita(int idVisita) async {
    List<Map<String, dynamic>> maps = await DatabaseAmbiente.select(
        'TB_VISITA_CANCELAMENTO',
        where: 'ID_VISITA = ? ',
        whereArgs: [idVisita]);

    if (maps.isEmpty) {
      return null;
    }

    return CancelamentoVisita.createObject(maps[0]);
  }
}
