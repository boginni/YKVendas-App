import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../api/common/debugger.dart';
import '../../../../api/models/configuracao/app_system.dart';
import '../../../../api/models/interface/realtime_sync.dart';
import '../../../common/custom_tiles/object_tiles/tile_cliente.dart';
import '../../../models/configuracao/app_ambiente.dart';
import '../../../models/database_objects/cliente.dart';

class ContainerClienteSelector extends StatefulWidget {
  const ContainerClienteSelector(
      {Key? key, required this.onPressed, int? this.idVendedor})
      : super(key: key);

  final Function(Cliente cliente) onPressed;
  final int? idVendedor;

  @override
  State<ContainerClienteSelector> createState() =>
      ContainerClienteSelectorState();
}

class ContainerClienteSelectorState extends State<ContainerClienteSelector>
    implements RealTimeSync {
  final _scrollController = ScrollController();
  final controllerPesquisa = TextEditingController();

  List<Cliente> clientes = [];
  bool onLoading = true;
  bool btnLoading = false;
  int limit = 12;

  @override
  void initState() {
    super.initState();
    RealTimeSync.addListener(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getData();
    });
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

  Future getData() async {
    String x = controllerPesquisa.text;

    final appAmbinete = AppAmbiente.of(context);

    final field = appAmbinete.buscaClientId ? 'ID_SYNC =' : 'CPF_CNPJ like';

    final filter = '(NOME like ? or APELIDO like ? or $field ?)';

    String args = 'STATUS = 1';
    List<dynamic> param = [];

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
        args += ' and (ID_VENDEDOR = ? )';
        param.add(widget.idVendedor);
      }
    }

    bool normal = (firma && appAmbinete.usarFiltroClienteVendedor) ||
        widget.idVendedor == null;

    Cliente.getList(args, param, normal: normal, limit: limit).then((value) {
      setState(() {
        onLoading = false;
        btnLoading = false;
        clientes = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final appSystem = AppSystem.of(context);
    final appAmbinete = AppAmbiente.of(context);
    final field = appAmbinete.buscaClientId ? 'Id' : 'CPF/CNPJ';

    return Column(
      children: [
        Card(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            child: Column(
              children: [
                SizedBox(
                  child: TextField(
                    controller: controllerPesquisa,
                    decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: "Nome, Apelido ou $field"),
                    style: textNormalStyle(appSystem),
                    onChanged: (x) {
                      if (appSystem.usarPesquisaDinamica) {
                        limit = 12;
                        getData();
                      }
                    },
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          limit = 12;
                          getData();
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
        Expanded(
          child: RefreshIndicator(
            onRefresh: getData,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              children: [
                ListView.builder(
                  physics: const ClampingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: clientes.length > 100 ? 100 : clientes.length,
                  itemBuilder: (BuildContext context, int index) {
                    final curCliente = clientes[index];
                    return TileCliente(
                      cliente: curCliente,
                      onClick: () => widget.onPressed(curCliente),
                    );
                  },
                ),
                btnLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : TextButton(
                        onPressed: () {
                          setState(() {
                            btnLoading = true;
                          });
                          Future.delayed(
                            const Duration(milliseconds: 250),
                            () {
                              limit += 100;
                              getData();
                            },
                          );
                        },
                        child: const Text('Carregar Mais'),
                      )
              ],
            ),
          ),
        )
      ],
    );
  }
}
