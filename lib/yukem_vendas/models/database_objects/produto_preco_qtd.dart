import '../../../api/common/debugger.dart';
import '../database/database_ambiente.dart';

class ProdutoPrecoQuantidade {
  int idPrecoQtd;
  int idProduto;
  int idTabela;

  double valor;

  int intervaloInicio;
  int intervaloFim;

  bool maximo;

  String tabelaNome; // NOME_TABELA

  ProdutoPrecoQuantidade(
      {required this.idPrecoQtd,
      required this.idProduto,
      required this.idTabela,
      required this.valor,
      required this.intervaloInicio,
      required this.intervaloFim,
      required this.maximo,
      required this.tabelaNome});

  factory ProdutoPrecoQuantidade.fromMap(Map<String, dynamic> map) {
    value(String x) {
      final y = map[x];

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

    bool bo(String x) {
      final y = value(x);
      if (y == null) {
        throw Exception("$x não deveria ser nulo");
      }

      return y == 1;
    }

    return ProdutoPrecoQuantidade(
        idPrecoQtd: value('ID'),
        idProduto: value('ID_PRODUTO'),
        idTabela: value('ID_TABELA'),
        valor: dou('VALOR'),
        intervaloInicio: value('INICIAL'),
        intervaloFim: value('FINAL'),
        maximo: bo('MAXIMO'),
        tabelaNome: value('NOME_TABELA'));
  }
}

// pq.ID,
// pq.ID_PRODUTO,
// pq.ID_TABELA,
// pq.VALOR,
// pq.QUANTIDADE_INICIAL INICIAL,
//     pq.QUANTIDADE_FINAL FINAL,
// (pq.QUANTIDADE_FINAL = pqx.FINAL_MAX) MAXIMO

Future<List<ProdutoPrecoQuantidade>> getProdutoPrecoQuantidadeList(
    int idProduto, int idTabela) async {
  List<Map<String, dynamic>> maps = await DatabaseAmbiente.select(
      'VW_PRODUTO_PRECO_QTD',
      where: 'ID_PRODUTO = ? and ID_TABELA = ?',
      whereArgs: [idProduto, idTabela]);

  return List.generate(
      maps.length, (index) => ProdutoPrecoQuantidade.fromMap(maps[index]));
}

Future<List<ProdutoPrecoQuantidade>> getProdutoPrecoQuantidadeListFull(
    int idProduto) async {
  List<Map<String, dynamic>> maps = await DatabaseAmbiente.select(
      'VW_PRODUTO_PRECO_QTD',
      where: 'ID_PRODUTO = ?',
      whereArgs: [idProduto],
      orderBy: 'ID_TABELA');

  return List.generate(
      maps.length, (index) => ProdutoPrecoQuantidade.fromMap(maps[index]));
}
