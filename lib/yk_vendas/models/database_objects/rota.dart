import '../../../api/common/formatter/date_time_formatter.dart';
import '../database/database_ambiente.dart';

class Rota {
  String? nome = '';
  int? id = 0;
  bool disp = false;
  int clientes = 0;

  /// retorna a lista de rotas da tabela [TB_ROTAS]
  static Future<List<Rota>> getRotas(int idVendedor) async {
    String hoje = days[DateFormatter.semana.format(DateTime.now())]!;

    final args = [idVendedor];

    final List<Map<String, dynamic>> maps = await DatabaseAmbiente.select(
        'VW_ROTA',
        where: 'ID_VENDEDOR = ?',
        whereArgs: args);

    DatabaseAmbiente.select('VW_ROTA');

    // printDebug('test');

    return List.generate(
      maps.length,
          (i) {
        Rota r = Rota();
        r.nome = maps[i]['NOME'];
        r.id = maps[i]['ID'];
        r.disp = maps[i][hoje] == 'T';
        r.clientes = maps[i]['CLIENTES'];
        return r;
      },
    );
  }


}

