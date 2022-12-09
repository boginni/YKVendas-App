class Graph {
  int id = 0;
  String nome = '';
}

/// # Lista de Gráficos
/// A a lista depende da implementação de telas de gráficos
/// e ter salvo quais são funcionais
/// por enquanto, o método retornará uma lista fixa
Future<List<Graph>> getGraphList() async {
  List<String> x = [
    'Cerv 1/1',
    'Quantidade e Total Liquido R\$ Por itens : Descrição',
    'Quantidade Meta e Meta alcançada Por Outros Cadastros : Descrição',
    'Valor Venda e Valor comisssão'
  ];

  return List.generate(x.length, (i) {
    Graph g = Graph();
    g.nome = x[i];

    return g;
  });
}
