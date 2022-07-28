import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forca_de_vendas/yukem_vendas/models/configuracao/app_ambiente.dart';

import '../../../../api/common/components/list_scrollable.dart';
import '../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../api/common/debugger.dart';
import '../../../../api/models/configuracao/app_system.dart';
import '../../../../api/models/interface/realtime_sync.dart';
import '../../../common/custom_tiles/object_tiles/tile_cliente.dart';
import '../../../models/database_objects/cliente.dart';

class ContainerClienteSelector extends StatefulWidget {
  const ContainerClienteSelector(
      {Key? key, required this.onPressed, int? this.idVendedor})
      : super(key: key);

  final Function(Cliente cliente) onPressed;
  final int? idVendedor;

  @override
  State<ContainerClienteSelector> createState() =>
      _ContainerClienteSelectorState();
}

class _ContainerClienteSelectorState extends State<ContainerClienteSelector>
    implements RealTimeSync {
  final _scrollController = ScrollController();
  final controllerPesquisa = TextEditingController();

  List<Cliente> clientes = [];

  @override
  void initState() {
    super.initState();
    RealTimeSync.addListener(this);
  }

  @override
  void dispose() {
    super.dispose();
    RealTimeSync.removeListener(this);
  }

  @override
  void onEvent(List<int> events) {
    bool toUp = false;

    for (final i in events) {
      if (i == 6) {
        toUp = true;
      }
    }

    if (!toUp) {
      return;
    }

    try {
      setState(() {});
    } catch (e) {
      printDebug(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final appSystem = AppSystem.of(context);
    final appAmbinete = AppAmbiente.of(context);

    Future<List<Cliente>> getClietes() async {
      String x = controllerPesquisa.text;

      final field = appAmbinete.buscaClientId ? 'ID_SYNC =' : 'CPF_CNPJ like';

      final filter = '(NOME like ? or APELIDO like ? or $field ?)';

      String args = 'STATUS = ?';
      List<dynamic> param = [1];

      if (x.isNotEmpty) {
        args += ' and ${filter}';
        param.add('%$x%');
        param.add('%$x%');
        param.add(appAmbinete.buscaClientId ? x : '%$x%');
      }

      bool firma =
          (appAmbinete.usarFirma && widget.idVendedor == appAmbinete.firma);



      if (!firma && appAmbinete.usarFiltroClienteVendedor) {
        if (widget.idVendedor != null) {
          args += ' and (ID_VENDEDOR = ? or (TO_SYNC = 1 and ID_SYNC IS NULL))';
          param.add(widget.idVendedor);
        }
      }

      bool normal = (firma && appAmbinete.usarFiltroClienteVendedor) || widget.idVendedor == null;

      return Cliente.getList(args, param, normal: normal );
    }

    final field = appAmbinete.buscaClientId ? 'Id' : 'CPF/CNPJ';

    return ListView(
      controller: _scrollController,
      children: [
        Card(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            child: ListViewNested(
              children: [
                TextFormField(
                  controller: controllerPesquisa,
                  decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      hintText: "Nome, Apelido ou $field"),
                  style: textNormalStyle(appSystem),
                  onChanged: (x) {
                    if (appSystem.usarPesquisaDinamica) {
                      setState(() {});
                    }
                  },
                ),
                Row(
                  children: [
                    // Flexible(
                    //   flex: 1,
                    //   child: GestureDetector(
                    //     child: IconNormal(Icons.settings),
                    //   ),
                    // ),
                    // const SizedBox(
                    //   width: 4,
                    // ),

                    Expanded(
                      flex: 6,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {});
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        child: const TextTitle('Pesquisar'),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
        FutureBuilder(
          future: getClietes(),
          builder:
              (BuildContext context, AsyncSnapshot<List<Cliente>> snapshot) {
            if (snapshot.hasData) {
              clientes = snapshot.data!;
            }

            if (clientes.isNotEmpty) {
              return ListViewScrollable(
                maxCount: clientes.length,
                itemBuilder: (BuildContext context, int index) {
                  final curCliente = clientes[index];
                  return TileCliente(
                    cliente: curCliente,
                    onClick: () => widget.onPressed(curCliente),
                  );
                },
                scrollController: _scrollController,
                limiterDefault: 20,
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Carregando Registros');
            }

            return const Center(
              child: TextNormal('Não existem registros a serem carregados!'),
            );
          },
        ),
      ],
    );
  }
}
