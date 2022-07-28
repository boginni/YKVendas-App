import 'package:flutter/material.dart';
import 'package:forca_de_vendas/yukem_vendas/models/configuracao/app_user.dart';
import 'package:forca_de_vendas/yukem_vendas/models/internet/sync_manager.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/base/moddel_screen.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/clientes/container_cliente_selector.dart';

import '../../../../api/common/debugger.dart';
import '../../../models/internet/sync_cliente.dart';
import '../base/custom_drawer.dart';
import 'novo_cliente.dart';

class TelaClientes extends ModdelScreen {
  const TelaClientes({Key? key}) : super(key: key);

  static List<Widget> getActionButtons(BuildContext context,
      {required Function callback}) {
    return <Widget>[
      /**
       * Add Cliente
       */
      Padding(
        padding: const EdgeInsets.only(right: 20),
        child: InkWell(
          onTap: () {
            Navigator.of(context)
                .pushNamed(TelaNovoCliente.routeName)
                .then((value) {
              callback();
              SyncClientes.syncClientes(context).then((value) => callback());
            });
          },
          child: const Icon(Icons.person_add_outlined),
        ),
      ),
      /**
       * Syncronizar
       */
      Padding(
        padding: const EdgeInsets.only(right: 20),
        child: InkWell(
          onTap: () {
            SyncHandler.sincronizar(show: true, context: context)
                .then((value) => callback());
          },
          child: const Icon(Icons.sync),
        ),
      )
    ];
  }

  @override
  Widget getCustomScreen(BuildContext context) {
    return const xTelaClientes();
  }
}

class xTelaClientes extends StatefulWidget {
  const xTelaClientes({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TelaClientesState();
}

class _TelaClientesState extends State<xTelaClientes> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        actions: TelaClientes.getActionButtons(context,
            callback: () => setState(() {})),
      ),
      drawer: const CustomDrawer(),
      body: ContainerClienteSelector(
        idVendedor: AppUser.of(context).vendedorAtual,
        onPressed: (cliente) {
          Navigator.of(context)
              .pushNamed(TelaNovoCliente.routeName, arguments: cliente.id)
              .then((value) {
            if (value == true) {
              setState(() {
                try {
                  SyncClientes.syncClientes(context).then((value) {
                    if (value) {
                      setState(() {});
                    }
                  });
                } catch (e) {
                  printDebug(e.toString());
                }
              });
            }

            // setState(() {});
          });
        },
      ),
    );
  }
}
