import 'package:forca_de_vendas/api/common/formatter/arredondamento.dart';
import 'package:forca_de_vendas/yukem_vendas/models/database_objects/produto_preco_qtd.dart';
import 'package:forca_de_vendas/yukem_vendas/models/database_objects/visita.dart';

import '../../../api/common/debugger.dart';
import '../database/database_ambiente.dart';

// ID_VISITA
// QUANTIDADE
// ID_TABELA
// ID_VENDEDOR
// DESCONTO_MAX
// VALOR_VENDA
// VALOR_TABELA
// VALOR_UNITARIO
// DESCONTO_VALOR
// TOTAL_LIQ
// TOTAL_BRUTO
// SUB_TOTAL_XOR

class ProdutoItemVisita {
  ///DATABASE
  int idProduto;
  int idVisita;
  int idTabela;
  int idVendedor;

  final double? estoque;

  double descontoMaxVendedor;
  double descontoMaxProduto;
  double valorVenda;
  double? valorTabela;

  double totalBruto;
  double totalLiquido;
  double totalDescontoNormal;
  double totalDescontoBrinde;

  double subTotalLiq;
  double subTotalBruto;

  double quantidadeTotal;

  double quantidadeNormal;
  double quantidadeBrinde;

  int? idItem;
  late double quantidade;
  late double quantidadeInicial;
  late double? valorUnitario;
  late double? valorUnitarioInicial;
  late double descontoValor;
  late double descontoValorInicial;
  late bool brinde;
  late bool brindeInicial;

  /// LOCAL
  late double subTotalXor;
  double alteracaoValorUnd = 0;
  double? descontoPct;

  ///MIXED
  List<ProdutoPrecoQuantidade> listPrecoQtd = [];

  bool faturamento = false;

  ProdutoItemVisita({
    required this.idProduto,
    required this.idVisita,
    required this.idTabela,
    required this.idVendedor,
    required this.estoque,
    required this.descontoMaxVendedor,
    required this.descontoMaxProduto,
    required this.valorVenda,
    required this.valorTabela,
    required this.subTotalLiq,
    required this.subTotalBruto,
    required this.quantidadeTotal,
    required this.totalBruto,
    required this.totalLiquido,
    required this.totalDescontoNormal,
    required this.totalDescontoBrinde,
    required this.quantidadeNormal,
    required this.quantidadeBrinde,
  });

  recalcDesconto() {
    if (valorUnitario != null) {
      descontoPct = descontoValor / getTotalBruto();
    } else {
      descontoPct = 0;
    }
  }

  factory ProdutoItemVisita.fromMap(Map<String, dynamic> map) {
    value(String x, {bool print = true}) {
      final y = map[x];
      if (y == null && print) {
        printDebug('null call for $x');
      }
      return y;
    }

    double? douN(String x) {
      try {
        final y = double.tryParse(value(x, print: false).toString());
        return y;
      } catch (e) {
        printDebug(x);
        printDebug(e.toString());

        return null;
      }
    }

    double dou(String x) {
      return douN(x) ?? 0;
    }

    // as TOTAL_BRUTO,
    // as TOTAL_LIQ,
    // as TOTAL_DESCONTO_VALOR,
    // as TOTAL_DESCONTO_BRINDE,

    // DESCONTO_MAXIMO
    return ProdutoItemVisita(
      idProduto: value('ID_PRODUTO'),
      idVisita: value('ID_VISITA') ?? 0,
      idTabela: value('ID_TABELA'),
      idVendedor: value('ID_VENDEDOR'),
      estoque: douN('ESTOQUE'),
      descontoMaxVendedor: dou('DESCONTO_MAX_VENDEDOR'),
      descontoMaxProduto: dou('DESCONTO_MAX_PRODUTO'),
      valorVenda: dou('VALOR_VENDA'),
      valorTabela: douN('VALOR_TABELA'),
      subTotalLiq: dou('TOTAL_LIQ'),
      subTotalBruto: dou('TOTAL_BRUTO'),
      quantidadeTotal: dou('QUANTIDADE_ATUAL'),
      totalBruto: dou('TOTAL_BRUTO'),
      totalLiquido: dou('TOTAL_LIQ'),
      totalDescontoBrinde: dou('TOTAL_DESCONTO_BRINDE'),
      totalDescontoNormal: dou('TOTAL_DESCONTO_VALOR'),
      quantidadeNormal: dou('QUANTIDADE_NORMAL'),
      quantidadeBrinde: dou('QUANTIDADE_BRINDE'),
    );
  }

  Future<dynamic> posInit() async {
    final maps = await DatabaseAmbiente.select('TB_VISITA_ITEM',
        where: 'ID = ?', whereArgs: [idItem ?? 0]);

    Map<String, dynamic>? map;

    if (maps.isNotEmpty) {
      map = maps[0];
    }

    getMap() {
      return map ?? {};
    }

    value(String x) {
      final y = getMap()[x];
      // if (y == null) {
      //   printDebug('null call for $x');
      // }
      return y;
    }

    double? douN(String x) {
      try {
        final y = double.tryParse(value(x).toString());
        return y;
      } catch (e) {
        printDebug(x);
        printDebug(e.toString());

        return null;
      }
    }

    double dou(String x) {
      return douN(x) ?? 0;
    }

    quantidade = douN('QUANTIDADE') ?? 1;
    quantidadeInicial = douN('QUANTIDADE') ?? 0;
    valorUnitario = douN('VALOR_UNITARIO');
    valorUnitarioInicial = valorUnitario;
    descontoValor = dou('DESCONTO_VALOR');
    descontoValorInicial = descontoValor;
    brinde = value('BRINDE') == 1;
    brindeInicial = brinde;
  }

  Map<String, dynamic> toMap() {
    return {
      'ID': idItem,
      'ID_VISITA': idVisita,
      'ID_PRODUTO': idProduto,
      'QUANTIDADE': quantidade,
      'VALOR_UNITARIO': valorUnitario,
      'DESCONTO_VALOR': descontoValor,
      'BRINDE': brinde ? 1 : 0,
    };
  }

  insertItem({bool noRepeat = false}) async {
    var maps = await DatabaseAmbiente.select('TB_PRODUTO',
        where: 'ID = ?', whereArgs: [idProduto]);

    final map = maps[0];

    if (map['STATUS'] == 0 || map['MOBILE'] == 0) {
      return;
    }

    DatabaseAmbiente.insert('TB_VISITA_ITEM', toMap());
  }

  static Future<void> deleteItem(int? idItem) async {
    if (idItem == null) {
      return;
    }

    await DatabaseAmbiente.update('TB_VISITA_ITEM', {'STATUS': 0},
        where: 'ID = ?', whereArgs: [idItem]);
  }

  double getDescontoPct() {
    return descontoValor / getPrecoPadrao();
  }

  double getTotalDescontoPctPedido() {
    double y = getTotalDescontoPedido();

    double x = (totalBruto - getTotalBrutoInicial()) + getTotalBruto();

    if (x == 0) {
      return 0;
    }

    return y / x;
  }

  double getPrecoAtual() {
    return valorUnitario ?? getPrecoQtd() ?? valorTabela ?? valorVenda;
  }

  @deprecated
  double getPrecoPadrao() {
    return valorUnitario ?? getPrecoQtd() ?? valorTabela ?? valorVenda;
  }

  double getPrecoTabela() {
    return getPrecoQtd() ?? valorTabela ?? valorVenda;
  }

  double getTotalBruto() {
    return getPrecoAtual() * quantidade;
  }

  double getValorUnitarioInicial() {
    valorUnitarioInicial ??= getPrecoAtual();
    return valorUnitarioInicial!;
  }

  double getTotalBrutoInicial() {
    return getValorUnitarioInicial() * quantidadeInicial;
  }

  double getTotalLiquido() {
    return getTotalBruto() - (descontoValor);
  }

  double getTotalLiquidoInicial() {
    return getTotalBrutoInicial() - descontoValor;
  }

  setDesconto(double porcentagem) {
    descontoPct = porcentagem;
    descontoValor = arredondarValor(getTotalBruto() * porcentagem);
  }

  double? getPrecoQtd() {
    for (final item in listPrecoQtd) {
      if ((quantidade >= item.intervaloInicio &&
              quantidade < item.intervaloFim) ||
          item.maximo) {
        // printDebug('==================');
        // printDebug('quantidade $quantidade');
        // printDebug(item.intervaloInicio);
        // printDebug(item.intervaloFim);
        // printDebug(item.maximo);

        return item.valor;
      }
    }
    return null;
  }

  double getQuantidadeAtual() {
    return (quantidadeTotal - quantidadeInicial) + quantidade;
  }

  double getQuantidadeProdutoAtual() {
    return ((quantidadeNormal + quantidadeBrinde) - quantidadeInicial) +
        quantidade;
  }

  double getValorBrinde() {
    double y = 0;

    if (brinde) {
      y = getPrecoAtual() * quantidade;
    }

    return y;
  }

  getTotalBrindePedido() {
    double y = 0;

    if (brindeInicial) {
      y = valorUnitarioInicial! * quantidadeInicial;
    }

    return (totalDescontoBrinde - y) + getValorBrinde();
  }

  double getTotalLiquidoPedido() {
    // if(){
    //
    // }

    return totalLiquido - getTotalLiquidoInicial() + getTotalLiquido();
  }

  double getTotalDescontoPedido() {
    return (totalDescontoNormal - descontoValorInicial) + descontoValor;
  }

  double getTotalBrutoPedido() {
    double x = 0;

    if (!brinde) {
      x = getTotalBruto();
    }

    double y = totalBruto - getTotalBrutoInicial() + x;

    return y;
  }
}

Future<ProdutoItemVisita> getProdutoItemVisita({
  required int idVisita,
  required int idProduto,
  required int idVendedor,
  required int idTabela,
  required int? idItem,
}) async {

  final param = [idProduto, idVendedor, idTabela, idVisita];
  const where =
      'ID_PRODUTO = ? and ID_VENDEDOR = ? and ID_TABELA = ? and ID_VISITA = ?';

  final maps = await DatabaseAmbiente.select('VW_VISITA_NEW_ITEM',
      where: where, whereArgs: param);


  return await _getItem(ProdutoItemVisita.fromMap(maps[0])..idItem = idItem);
}

Future<ProdutoItemVisita> _getItem(ProdutoItemVisita item) async {

  item.listPrecoQtd =
      await getProdutoPrecoQuantidadeList(item.idProduto, item.idTabela);

  await item.posInit();

  item.recalcDesconto();

  final visista = await Visita.getVisita(item.idVisita);

  item.faturamento = visista.faturamento;

  return item;
}
