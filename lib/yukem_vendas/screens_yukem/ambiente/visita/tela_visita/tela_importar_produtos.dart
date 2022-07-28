
import 'package:flutter/material.dart';
import 'package:forca_de_vendas/api/common/components/barra_progresso.dart';
import 'package:forca_de_vendas/yukem_vendas/common/custom_tiles/object_tiles/tile_historico_produto.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../../api/common/components/list_scrollable.dart';
import '../../../../../api/common/components/mostrar_confirmacao.dart';
import '../../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../../api/models/database_objects/query_filter.dart';
import '../../../../models/database/database_ambiente.dart';
import '../../../../models/database_objects/historico_pedido.dart';

import '../../../../models/database_objects/visita.dart';

class TelaImportarProdutos extends StatefulWidget {
  static const String routeName = '/telaImportarProdutos';

  const TelaImportarProdutos({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TelaImportarProdutosState();
}

class _TelaImportarProdutosState extends State<TelaImportarProdutos> {
  final _controllerScroll = ScrollController();

  List<HistoricoPedido> items = [];

  bool toSearch = true;

  final _controllerPesquisa = TextEditingController();

  bool onStart = true;

  @override
  Widget build(BuildContext context) {
    List<dynamic> args =
        ModalRoute.of(context)!.settings.arguments as List<dynamic>;

    final int idVisita = args[0] as int;

    Future<int?> getIdPessoa() async {
      final value = await DatabaseAmbiente.select('TB_VISITA',
          where: 'ID =?', whereArgs: [idVisita]);
      return value[0]['ID_CLIENTE_SYNC'];
    }

    int? idPessoa;

    final filtros = FiltrosVisitas();

    setup() async {
      idPessoa = await getIdPessoa();
      _controllerPesquisa.text = idPessoa.toString();
      onStart = false;
    }

    filtros.pesquisa = _controllerPesquisa.text;

    importData(int export) async {
      bool result = await mostrarCaixaConfirmacao(context,
          content: 'Deseja realmente importar os dados dessa visita?');
      if (result) {
        await importProdutos(idVisita, export)
            .then((value) => Navigator.of(context).pop());
      }
    }

    QueryFilter getQuery() {
      String x = _controllerPesquisa.text;

      bool y = isNumeric(x);

      return QueryFilter(args: {
        'ID_CLIENTE': intValue(x),
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historico'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: InkWell(
              child: const Icon(Icons.sync, size: 26.0),
              onTap: () async {
                if (idPessoa == null) {
                  // DatabaseAmbiente.select('TB_VISITA',
                  //     where: 'ID =?', whereArgs: [idVisita]).then((value) {
                  //   idPessoa = value[0]['ID_CLIENTE_SYNC'];
                  //   _controllerPesquisa.text = idPessoa.toString();
                  // });

                  //   key.currentState!.setError(
                  //       'Cliente Inválido', 'Esse ainda não foi sincronizado');
                  //   return;
                  return;
                }

                GlobalKey<BarraProgressoCircularState> key =
                    mostrarBarraProgressoCircular(context);

                syncHostorico([idPessoa!], context)
                    .then((value) {
                  if (key.currentState != null) {
                    if (value) {
                      key.currentState!.finish();
                      setState(() {
                        toSearch = true;
                      });
                    } else {
                      key.currentState!.setError('Erro', 'content');
                    }
                  }
                });
              },
            ),
          ),
        ],
      ),
      body: FutureBuilder(
          future: setup(),
          builder: (context, x) {
            Widget listWidget = x.connectionState == ConnectionState.done
                ? FutureBuilder(
                    future: getHistPedidos(queryFilter: getQuery()),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<HistoricoPedido>?> snapshot) {
                      if (snapshot.data != null) {
                        items = snapshot.data!;
                      }

                      return ListViewScrollable(
                        scrollController: _controllerScroll,
                        maxCount: items.length,
                        itemBuilder: (BuildContext context, int i) {
                          final item = items[i];
                          return TileHistoricoProduto(
                            item: item,
                            idVisita: idVisita,
                          );

                        },
                      );
                    },
                  )
                : Container();

            return ListView(
              controller: _controllerScroll,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListViewNested(
                      children: [
                        const TextTitle('Pesquisa'),
                        TextFormField(
                          controller: _controllerPesquisa,
                          decoration:
                              const InputDecoration(hintText: 'ID Pessoa'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              toSearch = true;
                            });
                          },
                          child: const TextNormal('Pesquisar'),
                        ),
                      ],
                    ),
                  ),
                ),
                listWidget,
              ],
            );
          }),
    );
  }

  Visita? selecVisita;
}

Future importProdutos(int import, int export) async {
  Database db = await DatabaseAmbiente.getDatabase();

  await db
      .execute('delete from TB_VISITA_TABELA where ID_VISITA = ?;', [import]);

  await db.execute('delete from TB_VISITA_ITEM where ID_VISITA = ?;', [import]);

  await db.execute(
      'insert into TB_VISITA_TABELA(ID_VISITA, ID_TABELA_PRECOS)'
      ' select ?, ID_TABELA_PRECOS from TB_VISITA_TABELA where ID_VISITA = ?;',
      [import, export]);

  await db.execute(
      'INSERT INTO TB_VISITA_ITEM'
      ' ( ID_VISITA, ID_PRODUTO, QUANTIDADE, STATUS, VALOR_UNITARIO, DESCONTO_VALOR)'
      ' SELECT ?, ID_PRODUTO, QUANTIDADE, STATUS, VALOR_UNITARIO, DESCONTO_VALOR '
      'from TB_VISITA_ITEM where ID_VISITA = ?;',
      [import, export]);
}
