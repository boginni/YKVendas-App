import 'package:flutter/material.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/dashboard/components/container_loading.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/remake/util/tiles/tile_historico_pedido.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../api/models/database_objects/query_filter.dart';
import '../../../models/database/database_ambiente.dart';
import '../../../models/database_objects/historico_pedido.dart';

class TelaHistoricoPedidos extends StatefulWidget {
  const TelaHistoricoPedidos(
      {Key? key, required this.idPessoa, required this.idVisita})
      : super(key: key);

  final int? idPessoa;
  final int? idVisita;

  @override
  State<StatefulWidget> createState() => _TelaHistoricoPedidosState();
}

class _TelaHistoricoPedidosState extends State<TelaHistoricoPedidos> {
  List<HistoricoPedido> itens = [];
  bool onLoading = true;

  @override
  void initState() {
    super.initState();
    getData();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historico'),
        actions: [
          InkWell(
            onTap: () {
              getOnlineData();
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(Icons.sync, size: 26.0),
            ),
          ),
          SizedBox(
            width: 10,
          ),
        ],
      ),
      body: onLoading
          ? const ContainerLoading()
          : RefreshIndicator(
              onRefresh: () async => getData(),
              child: ListView.builder(
                itemCount: itens.length,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                itemBuilder: (BuildContext context, int i) {
                  return TileHistoricoPedido(
                    item: itens[i],
                    idVisita: widget.idVisita,
                  );
                },
              ),
            ),
    );
  }

  getData() {
    final q = QueryFilter(args: {
      'ID_CLIENTE': widget.idPessoa,
    });

    getHistPedidos(queryFilter: q).then((value) {
      setState(() {
        onLoading = false;
        itens = value;
      });
    });
  }

  getOnlineData() {
    if (widget.idPessoa != null) {
      setState(() {
        onLoading = true;
        syncHostorico([widget.idPessoa!], context).then((value) {
          getData();
        });
      });
    }
  }
}

// Card(
//   child: Padding(
//     padding: const EdgeInsets.all(8.0),
//     child: ListViewNested(
//       children: [
//         const TextTitle('Pesquisa'),
//         TextFormField(
//           controller: _controllerPesquisa,
//           decoration:
//           const InputDecoration(hintText: 'ID Pessoa'),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             setState(() {
//               toSearch = true;
//             });
//           },
//           child: const TextNormal('Pesquisar'),
//         ),
//       ],
//     ),
//   ),
// ),

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
