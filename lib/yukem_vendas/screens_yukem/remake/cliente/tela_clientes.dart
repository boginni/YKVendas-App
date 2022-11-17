import 'package:flutter/material.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/clientes/tela_clientes.dart';

import '../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../api/common/debugger.dart';
import '../../../../api/models/configuracao/app_system.dart';
import '../../../../api/models/interface/realtime_sync.dart';
import '../../../common/custom_tiles/object_tiles/tile_cliente.dart';
import '../../../models/configuracao/app_ambiente.dart';
import '../../../models/configuracao/app_user.dart';
import '../../../models/database_objects/cliente.dart';
import '../../../models/internet/sync_cliente.dart';

class TelaBuscarCliente extends StatefulWidget {
  const TelaBuscarCliente({Key? key, required this.mostrarTodos})
      : super(key: key);
  static const routeName = 'TelaSelecionarCliente';

  final bool mostrarTodos;

  @override
  State<StatefulWidget> createState() => _TelaBuscarClienteState();
}

class _TelaBuscarClienteState extends State<TelaBuscarCliente>
    implements RealTimeSync {
  final _scrollController = ScrollController();
  final controllerPesquisa = TextEditingController();
  List<Cliente> clientes = [];
  int limit = 20;

  bool onLoading = true;

  @override
  void initState() {
    super.initState();
    RealTimeSync.addListener(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      search();
    });
  }

  dynamic update(Object? value) {
    SyncClientes.syncClientes(context).then((value) {
      if (value) search();
    });
  }

  @override
  void dispose() {
    super.dispose();
    RealTimeSync.removeListener(this);
  }

  search() {
    final appAmbinete = AppAmbiente.of(context);

    final clienteVendedor =
        appAmbinete.usarFiltroClienteVendedor && !widget.mostrarTodos;

    Cliente.getData(
      context,
      busca: controllerPesquisa.text,
      buscaIdCnpj: appAmbinete.buscaClientId,
      clienteVendedor: clienteVendedor,
      limit: limit,
    ).then((value) {
      setState(() {
        clientes = value;
        onLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final appUser = AppUser.of(context);
    int? idVendedor = widget.mostrarTodos ? null : appUser.vendedorAtual;

    final appSystem = AppSystem.of(context);
    final appAmbinete = AppAmbiente.of(context);
    final field = appAmbinete.buscaClientId ? 'Id' : 'CPF/CNPJ';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Clientes'),
        actions: TelaClientes.getActionButtons(context,
            callback: () => setState(() {})),
      ),
      body: RefreshIndicator(
        onRefresh: () async => search(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 6.0),
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
                              search();
                            }
                          },
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                search();
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
              ListView.builder(
                physics: const ClampingScrollPhysics(),
                shrinkWrap: true,
                itemCount: clientes.length,
                itemBuilder: (BuildContext context, int index) {
                  final curCliente = clientes[index];
                  return TileCliente(
                    cliente: curCliente,
                    onClick: () {
                      Navigator.of(context).pop(curCliente);
                    },
                  );
                },
              ),
              onLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : TextButton(
                      onPressed: () {
                        setState(() {
                          onLoading = true;
                          limit += 100;
                          Future.delayed(
                            const Duration(milliseconds: 250),
                            () {
                              search();
                            },
                          );
                        });
                      },
                      child: const Text('Carregar Mais'),
                    )
            ],
          ),
        ),
      ),
    );
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
      search();
    } catch (e) {
      printDebug(e.toString());
    }
  }
}
