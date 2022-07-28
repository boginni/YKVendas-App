import 'package:flutter/material.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/clientes/container_cliente_selector.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/clientes/tela_clientes.dart';

import '../../../models/configuracao/app_user.dart';
import '../../../models/database_objects/cliente.dart';
import '../../../models/internet/sync_cliente.dart';

class TelaBuscarCliente extends StatefulWidget {
  const TelaBuscarCliente({Key? key}) : super(key: key);
  static const routeName = 'TelaSelecionarCliente';

  @override
  State<StatefulWidget> createState() => _TelaBuscarClienteState();
}

class _TelaBuscarClienteState extends State<TelaBuscarCliente> {
  dynamic update(Object? value) {
    setState(() {});
    SyncClientes.syncClientes(context).then((value) {
      if (value) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    bool mostrarTodos = false;

    try {
      mostrarTodos =
          (ModalRoute.of(context)!.settings.arguments as List<bool>)[0];
    } catch (e) {}

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Clientes'),
        actions: TelaClientes.getActionButtons(context,
            callback: () => setState(() {})),
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: ContainerClienteSelector(
        idVendedor: mostrarTodos ? null : AppUser.of(context).vendedorAtual,
        onPressed: (Cliente cliente) {
          Navigator.of(context).pop(cliente.id);
        },
      ),
    );
  }
}
