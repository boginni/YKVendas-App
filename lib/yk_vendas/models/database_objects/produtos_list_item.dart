import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../../api/common/debugger.dart';
import '../database/database_ambiente.dart';
import '../database/query_filter_produto.dart';
import 'tabela_precos.dart';

class ProdutoListItem {
  final int idTabela;
  final int idProduto;
  final int idVisita;

  final String nome;
  final double? estoque;

  //gtin
  final int quantidadeNormal;
  final int quantidadeBrinde;

  // String unidade = "";

  final double totalLiq;
  final double totalBruto;
  final bool editavel;

  final double? valorTabela;
  final double? valorOriginal;

  factory ProdutoListItem.fromMap(Map<String, dynamic> map) {
    dynamic value(String x) {
      final y = map[x];
      if (y == null) {
        // printDebug(x);
      }
      return y;
    }

    double? douN(String x) {
      try {
        return double.tryParse(value(x).toString());
      } catch (e) {
        // printDebug(x);
        rethrow;
      }
    }

    double dou(String x) {
      return douN(x) ?? 0.0;
    }

    return ProdutoListItem(
        idTabela: value('ID_TABELA'),
        idProduto: value('ID_PRODUTO'),
        idVisita: value('ID_VISITA'),
        nome: value('NOME'),
        estoque: dou('ESTOQUE'),
        quantidadeNormal: value('QUANTIDADE_NORMAL'),
        //TODO ERRO NA DATABASE
        quantidadeBrinde: value('QUANTIDADE_BRINDE'),
        totalLiq: dou('TOTAL_LIQ'),
        totalBruto: dou('TOTAL_BRUTO'),
        editavel: value('EDITAVEL') == 1,
        valorTabela: douN('VALOR_TABELA'),
        valorOriginal: douN('VALOR_ORIGINAL'));
  }

  render(PdfGrid grid) {
    final PdfGridRow row = grid.rows.add();
    int i = 0;

    add(dynamic value, {int d = 2}) {
      if (value.runtimeType != String) {
        value = value.toStringAsFixed(d);
      }
      row.cells[i++].value = value;
    }

    // dynamic b = brinde ? "Brinde" : quantidade * valorUnitario - descontoValor;

    add('');
    add(idProduto, d: 0);
    add(nome);
    add(valorTabela);
    add(estoque, d: 0);
    // add(peso);
    // add(b);
  }

  ProdutoListItem(
      {required this.idTabela,
      required this.idProduto,
      required this.idVisita,
      required this.nome,
      required this.estoque,
      required this.quantidadeNormal,
      required this.quantidadeBrinde,
      required this.totalLiq,
      required this.totalBruto,
      required this.editavel,
      required this.valorTabela,
      required this.valorOriginal});

  getQuantidade() => (quantidadeBrinde + quantidadeNormal);
}

/// Retorna a lista de produtos da tabela [VW_PRODUTO_LIST]
Future<List<ProdutoListItem>> getProdutoList(
  int idVisita, {
  required FiltrosProdutos filtros,
  int? idTabela,
  bool limitar = false,
  int limit = 100,
}) async {
  return _selectMainStream(
    filtros.getWhere(),
    filtros.getArgs(),
    idTabela,
    limitar: limitar,
    limit: limit
  );
}

/// Retorna os itens(Produtos) selecionados de uma visita através da tabela [VW_VISITA_ITEM]
/// onde o status é Ativo [statusAtivo]
Future<List<ProdutoListItem>> getProdutoItensVisita(int idVisita) async {
  int? idTabela = await TabelaPreco.getIdTabela(idVisita);

  String args = "EDITAVEL = ? AND ID_VISITA = ?";
  List<dynamic> param = [1, idVisita];

  final list = await _selectMainStream(
    args,
    param,
    idTabela,
  );

  return list;
}

Future<List<ProdutoListItem>> _selectMainStream(
    String where, List<dynamic> args, int? idTabela,
    {bool limitar = false, limit = 100}) async {
  final List<Map<String, dynamic>> maps;

  idTabela ??= 0;

  where += ' and ID_TABELA = ?';
  args.add(idTabela);

  maps = await DatabaseAmbiente.select(
    'VW_PRODUTO_LIST_TAB',
    where: where,
    whereArgs: args,
    limit: limitar ? limit : null,
  );

  return _mapToList(maps);
}

/// Retorna um produto da tabela [VW_PRODUTO_LIST]
Future<ProdutoListItem> getProduto(int idVisita, int idProduto) async {
  int? idTabela = await TabelaPreco.getIdTabela(idVisita);

  String args = 'ID_VISITA = ? and  ID_PRODUTO = ?';
  List<dynamic> param = [idVisita, idProduto];

  final maps = await _selectMainStream(args, param, idTabela);

  return maps[0];
}

List<ProdutoListItem> _mapToList(List<Map<String, dynamic>> maps) {
  return List.generate(maps.length, (i) {
    // printDebug(maps[i]['ID_VISITA']);

    try {
      return ProdutoListItem.fromMap(maps[i]);
    } catch (e) {
      printDebug(e.toString());
      rethrow;
    }
  });
}

Future abaterEstoque(int idVisita) async {
  final list = await getProdutoItensVisita(idVisita);

  for (final item in list) {
    await movimentarEstoque(item.idProduto, -item.getQuantidade(),
        idVisita: idVisita);
  }
}

Future<bool> validarItens(int idVisita) async {
  final list = await getProdutoItensVisita(idVisita);

  for (final item in list) {
    if (item.estoque != null && item.getQuantidade() > item.estoque!) {
      return false;
    }
  }

  return true;
}

Future movimentarEstoque(int idProduto, int quantidade, {int? idVisita}) async {
  final map = {
    'ID_PRODUTO': idProduto,
    'ID_VISITA': idVisita,
    'QUANTIDADE': quantidade
  };

  DatabaseAmbiente.insert('TB_PRODUTO_ESTOQUE_MOV', map);
}
