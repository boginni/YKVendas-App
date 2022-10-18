import 'package:flutter/material.dart';
import 'package:forca_de_vendas/yukem_vendas/app_foundation.dart';
import 'package:forca_de_vendas/yukem_vendas/models/configuracao/app_user.dart';
import 'package:forca_de_vendas/yukem_vendas/models/internet/sync_manager.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/clientes/container_cliente_selector.dart';

import '../../../../api/common/debugger.dart';
import '../../../models/internet/sync_cliente.dart';
import '../base/custom_drawer.dart';
import 'novo_cliente.dart';

class TelaClientes extends StatefulWidget {
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
  State<TelaClientes> createState() => _TelaClientesState();
}

class _TelaClientesState extends State<TelaClientes> {
  final key = GlobalKey<ContainerClienteSelectorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        actions: TelaClientes.getActionButtons(context,
            callback: () => setState(() {})),
      ),
      drawer: const CustomDrawer(),
      body: ContainerClienteSelector(
        key: key,
        idVendedor: AppUser.of(context).vendedorAtual,
        onPressed: (cliente) {
          Application.navigate(
            context,
            TelaNovoCliente(
              idPessoa: cliente.id,
            ),
          ).then((value) {
            try {
              if (value == true) {
                key.currentState!.getData();
              }

              SyncClientes.syncClientes(context).then((value) {
                if (value) {
                  key.currentState!.getData();
                }
              });
            } catch (e) {
              printDebug(e.toString());
            }

            if (value == true) {}
          });
        },
      ),
    );
  }
}
