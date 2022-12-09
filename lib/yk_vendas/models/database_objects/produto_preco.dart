import '../../../api/common/debugger.dart';
import '../database/database_ambiente.dart';

class ProdutoPrecoTabela {
  int idProduto;
  int idTabela;

  double valorOriginal;
  double? valorTabela;

  String nomeTabela; // NOME_TABELA

  ProdutoPrecoTabela(
      {required this.idProduto,
      required this.idTabela,
      required this.valorOriginal,
      required this.valorTabela,
      required this.nomeTabela});

  factory ProdutoPrecoTabela.fromMap(Map<String, dynamic> map) {
    value(String x) {
      final y = map[x];

      if (y == null) {
        // printDebug('null call for $x');
      }

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

    bool bo(String x) {
      final y = value(x);
      if (y == null) {
        throw Exception("$x não deveria ser nulo");
      }

      return y == 1;
    }

// p.ID AS ID_PRODUTO,
// tb.NOME AS NOME_TABELA,
// tb.ID AS ID_TABELA,
// p.VALOR_VENDA AS VALOR_ORIGINAL,
// pt.VALOR AS VALOR_TABELA
    return ProdutoPrecoTabela(
        idProduto: value('ID_PRODUTO'),
        idTabela: value('ID_TABELA'),
        valorOriginal: dou('VALOR_ORIGINAL'),
        valorTabela: douN('VALOR_TABELA'),
        nomeTabela: value('NOME_TABELA'));
  }
}

// pq.ID,
// pq.ID_PRODUTO,
// pq.ID_TABELA,
// pq.VALOR,
// pq.QUANTIDADE_INICIAL INICIAL,
//     pq.QUANTIDADE_FINAL FINAL,
// (pq.QUANTIDADE_FINAL = pqx.FINAL_MAX) MAXIMO

Future<List<ProdutoPrecoTabela>> getProdutoPrecoTabelaList(
    int idProduto, int idTabela) async {
  List<Map<String, dynamic>> maps = await DatabaseAmbiente.select(
      'VW_PRODUTO_PRECO',
      where: 'ID_PRODUTO = ? and ID_TABELA = ?',
      whereArgs: [idProduto, idTabela]);

  return List.generate(
      maps.length, (index) => ProdutoPrecoTabela.fromMap(maps[index]));
}

Future<List<ProdutoPrecoTabela>> getProdutoPrecoTabelaListFull(
    int idProduto) async {
  List<Map<String, dynamic>> maps = await DatabaseAmbiente.select(
      'VW_PRODUTO_PRECO',
      where: 'ID_PRODUTO = ?',
      whereArgs: [idProduto],
      orderBy: 'ID_TABELA');

  return List.generate(
      maps.length, (index) => ProdutoPrecoTabela.fromMap(maps[index]));
}
