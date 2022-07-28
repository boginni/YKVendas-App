import 'package:sqflite/sqflite.dart';

import '../../../api/common/formatter/arredondamento.dart';
import '../database/database_ambiente.dart';

class TotaisPedido {
  final int idVisita;

  double totalBruto;
  double totalDesconto;
  double totalLiquido;
  int quantidade;
  int itens;
  int? idFormaPagamento;
  int? idVendedor;

  // double descontoPorcentagem;
  double descontoValor;
  String obsNF;
  bool comNota;

  TotaisPedido(this.idVisita,
      {required this.totalBruto,
      required this.totalLiquido,
      required this.totalDesconto,
      required this.quantidade,
      required this.itens,
      required this.idFormaPagamento,
      this.obsNF = '',
      // this.descontoPorcentagem = 0,
      this.descontoValor = 0,
      required this.comNota});

  factory TotaisPedido.fromMap(Map<String, dynamic> map) {
    value(String x) {
      final y = map[x];
      if (y == null) {
        // printDebug('null call for $x');
        //
      }
      return y;
    }

    double? douN(String x) {
      try {
        final y = double.tryParse(value(x).toString());
        return y;
      } catch (e) {
        // printDebug(x);
        // printDebug(e);
        return null;
      }
    }

    double dou(String x) {
      return douN(x) ?? 0;
    }

    return TotaisPedido(
      value('ID_VISITA'),
      totalBruto: dou('TOTAL_BRUTO'),
      totalDesconto: dou('TOTAL_DESCONTO'),
      totalLiquido: dou('TOTAL_LIQ'),
      quantidade: value('QUANTIDADE'),
      itens: value('PRODUTOS'),
      idFormaPagamento: value('ID_FORMA_PAGAMENTO'),
      obsNF: value('OBSERVACAO_NF'),
      descontoValor: dou('DESCONTO_VALOR'),
      comNota: value('COM_NOTA') == 1,
      // descontoPorcentagem: maps['DESCONTO_PORCENTAGEM'].toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ID_VISITA': idVisita,
      'ID_FORMA_PAGAMENTO': idFormaPagamento,
      'OBSERVACAO_NF': obsNF,
      // 'DESCONTO_PORCENTAGEM': descontoPorcentagem,
      'DESCONTO_VALOR': descontoValor,
      'ID_VENDEDOR': idVendedor,
      'COM_NOTA': comNota ? 1 : 0
    };
  }

  /// Retona o Totais de um pedido da tabela [VW_TOTAIS_PEDIDO]
  static Future<TotaisPedido?> getTotaisPedido(int idVisita) async {
    List<Map<String, dynamic>> maps = [];

    maps = await DatabaseAmbiente.select('VW_VISITA_TOTAIS',
        where: 'ID_VISITA = ?', whereArgs: [idVisita]);
    if (maps.isEmpty) {
      return null;
    }

    return TotaisPedido.fromMap(maps[0]);
  }

  Future<void> salvar() async {
    await DatabaseAmbiente.insert('TB_VISITA_TOTAIS', toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  double _desconto() {
    double x = 1 - ((totalBruto - descontoValor) / totalBruto);

    x = arredondaFracao(x);

    return x;
  }

  Future<void> updateDescontoProduto() async {
    final list = await DatabaseAmbiente.select('TB_VISITA_ITEM',
        where: 'ID_VISITA = ? AND STATUS = ?', whereArgs: [idVisita, 1]);

    double x = _desconto();

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
      final dif = arredondarValor(descontoValor - descontoRat);

      if (i == list.length - 1) {
        des += dif;
        descontoRat += dif;
      }
      await setDescontoItem(iid, des);
    }
  }
}
