import 'package:forca_de_vendas/api/common/map_reader.dart';

import '../../../../../api/common/formatter/arredondamento.dart';
import '../../../../models/database/database_ambiente.dart';

class ModuloTotais {
  final int idVisita;
  int? idFormaPagamento;
  String obsNf;
  int? idAssinatura;
  double valorEntrada;
  bool comNota;

  late bool viewOnly;

  List<Map<String, dynamic>> bloqueio = [];

  ModuloTotais(
      {required this.idVisita,
      required this.idFormaPagamento,
      required this.obsNf,
      required this.idAssinatura,
      required this.valorEntrada,
      required this.comNota});

  factory ModuloTotais.fromMap(Map<String, dynamic> iMap) {
    final map = MapReader(iMap);

    final t = ModuloTotais(
        idVisita: map.integer('ID_VISITA'),
        idFormaPagamento: map.intN('ID_FORMA_PAGAMENTO'),
        obsNf: map.value('OBSERVACAO_NF'),
        idAssinatura: map.integer('ID_ASSINATURA'),
        valorEntrada: map.dou('VALOR_ENTRADA'),
        comNota: map.bo('COM_NOTA'));
    return t;
  }

  Future<void> update(Map<String, dynamic> maps) async {
    await DatabaseAmbiente.update('TB_VISITA_TOTAIS', maps,
        where: 'ID_VISITA = ?', whereArgs: [idVisita]);
  }

  static Future<ModuloTotais> fromId(int idVisita) async {
    final maps = await DatabaseAmbiente.select('TB_VISITA_TOTAIS',
        where: 'ID_VISITA = ?', whereArgs: [idVisita]);
    if (maps.length != 1) {
      throw Exception('Id visita inválido: ${idVisita}');
    }
    return ModuloTotais.fromMap(maps[0]);
  }

  Future<void> updateDescontoProduto(double pct, double total) async {
    final list = await DatabaseAmbiente.select('TB_VISITA_ITEM',
        where: 'ID_VISITA = ? AND STATUS = ?', whereArgs: [idVisita, 1]);

    double x = pct;

    double descontoRat = 0;

    Future<void> setDescontoItem(int id, double valor) async {
      await DatabaseAmbiente.update('TB_VISITA_ITEM', {'DESCONTO_VALOR': valor},
          where: 'ID = ?', whereArgs: [id]);
    }

    for (int i = 0; i < list.length; i++) {
      final item = list[i];

      final iid = item['ID'];

      final qtd = item['QUANTIDADE'];
      final unt = item['VALOR_UNITARIO'];

      final tot = qtd * unt;

      final rat = arredondarValor(tot * x);
      double des = rat;

      descontoRat += rat;
      final dif = arredondarValor(total - descontoRat);

      if (i == list.length - 1) {
        des += dif;
        descontoRat += dif;
      }
      await setDescontoItem(iid, des);
    }
  }

  void setFormaPagamento(int? id) async {
    idFormaPagamento = id;

    await update({'ID_FORMA_PAGAMENTO': id});
  }

  void setComNota(bool b) async {
    comNota = b;
    await update({'COM_NOTA': b});
  }

  void setObsNf(String text) async {
    obsNf = text;
    await update({'OBSERVACAO_NF': text});
  }
}
