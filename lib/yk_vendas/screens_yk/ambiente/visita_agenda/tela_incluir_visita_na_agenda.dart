import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../api/common/components/mostrar_confirmacao.dart';
import '../../../../api/models/configuracao/app_system.dart';
import '../../../models/configuracao/app_ambiente.dart';
import '../../../models/configuracao/app_user.dart';
import '../../../models/database_objects/cliente.dart';
import '../../../models/database_objects/db_visita_agenda.dart';
import '../../../models/database_objects/rota.dart';
import '../base/custom_drawer.dart';
import '../base/moddel_screen.dart';
import '../clientes/container_cliente_selector.dart';
import '../visita/tela_visita.dart';
import '../visita/tela_visita/tela_pedido.dart';

class TelaIncluirVisita extends ModdelScreen {
  const TelaIncluirVisita({Key? key}) : super(key: key);

  @override
  Widget getCustomScreen(BuildContext context) {
    return const xTelaIncluirVisita();
  }
}

class xTelaIncluirVisita extends StatefulWidget {
  const xTelaIncluirVisita({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => TelaIncluirVisitaState();
}

class TelaIncluirVisitaState extends State<xTelaIncluirVisita> {
  final _scrollController = ScrollController();
  final controllerPesquisa = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final rota = context.read<Rota>();
    final appAmbiente = AppAmbiente.of(context);
    final appSystem = AppSystem.of(context);

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar nova Visita'),
      ),
      drawer: const CustomDrawer(),
      body: ContainerClienteSelector(
        idVendedor: AppUser.of(context).vendedorAtual,
        onPressed: (Cliente cliente) {
          mostrarCaixaConfirmacao(context).then((value) async {
            if (value) {
              String getRedirectRouteName() {
                String r = appAmbiente.usarChegadaCliente
                    ? TelaVisita.routeName
                    : TelaPedido.routeName;
                return r;
              }

              int id = await insertVisitaAgenda(cliente.id!, rota.id,
                  idVendedor: AppUser.of(context).vendedorAtual);

              Navigator.of(context)
                  .pushNamed(getRedirectRouteName(), arguments: id);
            }
          });
        },
      ),
    );
  }
}
