import 'package:sqflite/sqflite.dart';

import '../../../api/common/debugger.dart';
import '../database/database_ambiente.dart';

class DadosEntrega {
  final int idVisita;

  DateTime? data;

  bool restricao;

  String detalheRestricao;

  String obs;

  DadosEntrega(this.idVisita,
      {this.detalheRestricao = '',
        this.obs = '',
        this.restricao = false,
        this.data});

  static DadosEntrega dummy(int idVisita) {
    return DadosEntrega(idVisita, data: DateTime.now());
  }

  String getData() => dateTimeToString(data!);

  int getRestricao() {
    return restricao ? 1 : 0;
  }

  String getDetalhe() {
    return restricao ? detalheRestricao : '';
  }

  Map<String, dynamic> toMap() {
    return {
      'ID_VISITA': idVisita,
      'DATA': getData(),
      'RESTRICAO': getRestricao(),
      'DETALHE': getDetalhe(),
      'OBSERVACAO': obs,
    };
  }

  static DadosEntrega createObject(Map<String, dynamic> maps) {
    DadosEntrega x = DadosEntrega(maps['ID_VISITA'],
        data: parseStringToDateTime(maps['DATA']),
        obs: maps['OBSERVACAO'],
        detalheRestricao: maps['DETALHE'],
        restricao: getBool(maps['RESTRICAO']));

    return x;
  }
}

/// Retorna um [DadosEntrega] da tabela [TB_VISITA_ENTREGA] de acordo com o [idVisita]
Future<DadosEntrega?> getDadosEntrega(final int idVisita) async {
  DadosEntrega? dados;

  try {
    List<Map<String, dynamic>> x = await DatabaseAmbiente.select('TB_VISITA_ENTREGA',
        where: 'ID_VISITA = ?', whereArgs: [idVisita]);

    if (x.isEmpty) {
      return dados;
    }

    dados = DadosEntrega.createObject(x[0]);
  } catch (e) {
    printDebug(e.toString());
  }

  return dados;
}

/// Insere dados da entrega [x] na tabela [TB_VISITA_ENTREGA]
Future<void> insertDadosEntrega(final DadosEntrega x) async {
  try {
    final db = await DatabaseAmbiente.getDatabase();

    await db.insert(
      'TB_VISITA_ENTREGA',
      x.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  } catch (e) {
    printDebug(e.toString());
  }
}