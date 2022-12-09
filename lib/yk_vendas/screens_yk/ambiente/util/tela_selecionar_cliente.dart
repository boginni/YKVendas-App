import 'package:flutter/material.dart';

import '../../../../api/common/components/list_scrollable.dart';
import '../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../api/models/configuracao/app_system.dart';
import '../../../../api/models/database_objects/query_filter.dart';
import '../../../common/custom_tiles/object_tiles/tile_cliente.dart';
import '../../../models/configuracao/app_ambiente.dart';
import '../../../models/database_objects/cliente.dart';
import '../base/custom_drawer.dart';

class TelaIncluirVisita extends StatefulWidget {
  const TelaIncluirVisita({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => TelaIncluirVisitaState();
}

class TelaIncluirVisitaState extends State<TelaIncluirVisita> {
  final _scrollController = ScrollController();
  final controllerPesquisa = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final appAmbiente = AppAmbiente.of(context);
    final appSystem = AppSystem.of(context);

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecionar cliente'),
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pop(null);
          },
        ),
      ),
      drawer: const CustomDrawer(),
      body: ListView(
        controller: _scrollController,
        children: [
          ///Barra de pesquisa
          Card(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              child: ListViewNested(
                children: [
                  TextFormField(
                    controller: controllerPesquisa,
                    decoration: const InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: "Nome do Cliente"),
                    style: textNormalStyle(appSystem),
                    onChanged: (x) {
                      if (appSystem.usarPesquisaDinamica) {
                        setState(() {});
                      }
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      setState(() {});
                    },
                    child: const TextTitle('Pesquisar'),
                  )
                ],
              ),
            ),
          ),

          /// Tile clientes
          FutureBuilder(
            future: Cliente.getClientes(
                queryFilter:
                    QueryFilter(args: {'NOME': controllerPesquisa.text})),
            builder:
                (BuildContext context, AsyncSnapshot<List<Cliente>> snapshot) {
              if (snapshot.hasData) {
                List<Cliente> clientes = snapshot.data!;
                int size = clientes.length;

                if (size == 0) {
                  return const Text(
                    'Não existem registros a serem carregados!',
                    textAlign: TextAlign.center,
                  );
                }
                return ListViewScrollable(
                  maxCount: clientes.length,
                  itemBuilder: (BuildContext context, int index) {
                    final curCliente = clientes[index];
                    return TileCliente(
                      cliente: curCliente,
                      onClick: () {
                        Navigator.of(context).pop(curCliente.id);
                      },
                    );
                  },
                  scrollController: _scrollController,
                  limiterDefault: 20,
                );
              } else {
                return const Text('Carregando Registros!');
              }
            },
          ),
        ],
      ),
    );
  }
}
