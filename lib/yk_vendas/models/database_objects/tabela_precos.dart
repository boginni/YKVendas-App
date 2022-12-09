
import '../../../api/common/debugger.dart';
import '../database/database_ambiente.dart';

class TabelaPreco {
  final int id;
  final String? nome;

  TabelaPreco(this.id, {this.nome});

  static Future<void> insertTabelaPreco(final int idVisita, final int? idTabela) async {
    if (idTabela == null) {
      await DatabaseAmbiente.execute(
          'UPDATE TB_VISITA set ID_TABELA = null where ID = ?',
          args: [idVisita]);
      return;
    }

    await DatabaseAmbiente.update(
        'TB_VISITA',
        //TODO: Converter para toMap
        {
          'ID_TABELA': idTabela,
        },
        where: 'ID = ?',
        whereArgs: [idVisita],
        onFail: (e) => printDebug('error'));
  }

  static Future<TabelaPreco?> getTabelaPreco(int idVisita) async {

    final List<Map<String, dynamic>> maps = await DatabaseAmbiente.select(
        'VW_VISITA_TABELA',
        where: 'ID_VISITA = ?',
        whereArgs: [idVisita]);

    if (maps.isEmpty) {
      return null;
    }

    return TabelaPreco(
      maps[0]['ID_TABELA'],
      nome: maps[0]['NOME'],
    );
  }

  static Future<int> getIdTabela(int idVisita) async {
    final maps = await DatabaseAmbiente.select('TB_VISITA',
        where: 'ID = ?', whereArgs: [idVisita]);

    int? idTablea = maps[0]['ID_TABELA'];

    if (idTablea == null) {
      throw Exception('ID tabela inválido. idVisita: $idVisita');
    }

    return idTablea;
  }

}


