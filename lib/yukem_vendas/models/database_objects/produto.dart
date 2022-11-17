import '../database/database_ambiente.dart';

class ProdutoListNormal {
  final String nome;
  final int id;

  ProdutoListNormal({required this.nome, required this.id});

  static Future<List<ProdutoListNormal>> getProdutos({
    required String where,
    required List<dynamic> args,
    required bool limitar,
    int limit = 100,
  }) async {
    final maps = await DatabaseAmbiente.select(
      'VW_PRODUTO_INFO',
      where: where,
      whereArgs: args,
      orderBy: 'NOME',
      limit: limitar ? limit : null,
    );

    final list = List.generate(
      maps.length,
      (index) => ProdutoListNormal(
        nome: maps[index]['NOME'].toString(),
        id: int.parse(maps[index]['ID_PRODUTO'].toString()),
      ),
    );

    return list;
  }
}

class ProdutoInfo {
  final int id;
  final String nome;
  final String descricao;

  final String grupo;
  final String subGrupo;
  final String departamento;

  final double estoque;
  final double preco;
  final String unidade;

  ProdutoInfo({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.grupo,
    required this.subGrupo,
    required this.departamento,
    required this.estoque,
    required this.preco,
    required this.unidade,
  });

  factory ProdutoInfo.fromMap(Map<String, dynamic> map) {
    dynamic get(x) {
      return map[x];
    }

    double Double(x) {
      final str = get(x).toString();

      return double.tryParse(str) ?? 0;
    }

    return ProdutoInfo(
        id: get('ID_PRODUTO'),
        nome: get('NOME'),
        descricao: get('DESCRICAO'),
        grupo: 'padrão',
        //get('GRUPO'),
        subGrupo: get('SUBGRUPO'),
        departamento: get('DEPARTAMENTO'),
        estoque: Double('ESTOQUE'),
        preco: Double('PRECO'),
        unidade: get('UNIDADE'));
  }

  static Future<ProdutoInfo> getData(int idProduto) async {
    List<Map<String, dynamic>> maps = await DatabaseAmbiente.select(
        'VW_PRODUTO_INFO',
        where: 'ID_PRODUTO = ?',
        whereArgs: [idProduto]);

    return ProdutoInfo.fromMap(maps[0]);
  }
}
