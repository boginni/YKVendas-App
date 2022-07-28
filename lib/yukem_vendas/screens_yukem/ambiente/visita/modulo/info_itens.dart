// ignore_for_file: non_constant_identifier_names

import 'package:forca_de_vendas/api/common/map_reader.dart';
import 'package:forca_de_vendas/yukem_vendas/models/database/database_ambiente.dart';

class InfoItens {
  final int ID_VISITA;
  final int PRODUTOS;
  final int QUANTIDADE;
  final int QUANTIDADE_BRINDE;
  final double TOTAL_BRUTO;
  final double TOTAL_DESCONTO;
  final double TOTAL_DESCONTO_VALOR;
  final double TOTAL_DESCONTO_BRINDE;
  final double TOTAL_LIQ;
  final double PESO_LIQUIDO_TOTAL;

  InfoItens(
      {required this.ID_VISITA,
      required this.PRODUTOS,
      required this.QUANTIDADE,
      required this.QUANTIDADE_BRINDE,
      required this.TOTAL_BRUTO,
      required this.TOTAL_DESCONTO,
      required this.TOTAL_DESCONTO_VALOR,
      required this.TOTAL_DESCONTO_BRINDE,
      required this.TOTAL_LIQ,
      required this.PESO_LIQUIDO_TOTAL});

  factory InfoItens.fromMap(Map<String, dynamic> iMap) {
    final map = MapReader(iMap);

    final i = InfoItens(
        ID_VISITA: map.integer('ID_VISITA'),
        PRODUTOS: map.integer('PRODUTOS'),
        QUANTIDADE: map.integer('QUANTIDADE'),
        QUANTIDADE_BRINDE: map.integer('QUANTIDADE_BRINDE'),
        TOTAL_BRUTO: map.dou('TOTAL_BRUTO'),
        TOTAL_DESCONTO: map.dou('TOTAL_DESCONTO'),
        TOTAL_DESCONTO_VALOR: map.dou('TOTAL_DESCONTO_VALOR'),
        TOTAL_DESCONTO_BRINDE: map.dou('TOTAL_DESCONTO_BRINDE'),
        TOTAL_LIQ: map.dou('TOTAL_LIQ'),
        PESO_LIQUIDO_TOTAL: map.dou('PESO_LIQUIDO_TOTAL'));

    return i;
  }

  static Future<InfoItens?> getFromId(int idVisita) async {
    final maps = await DatabaseAmbiente.select('VW_VISITA_INFO_ITENS',
        where: 'ID_VISITA = ?', whereArgs: [idVisita]);

    if (maps.isEmpty) {
      return null;
    }

    return InfoItens.fromMap(maps[0]);
  }
}
