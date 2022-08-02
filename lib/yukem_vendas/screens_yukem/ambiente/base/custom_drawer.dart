// ignore_for_file: dead_code

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forca_de_vendas/yukem_vendas/models/configuracao/app_user.dart';
import 'package:forca_de_vendas/yukem_vendas/models/websocket/websocket_handler.dart';
import 'package:ionicons/ionicons.dart';

import '../../../app_foundation.dart';
import '../../../models/configuracao/app_ambiente.dart';
import '../../../models/database/database_update.dart';
import 'drawer_tile.dart';

int curId = 0;

int getNextId() {
  return curId++;
}

class CustomDrawer extends StatefulWidget {
  // final bool Function()? onChange = (){ return true;};

  const CustomDrawer({
    Key? key,
  }) : super(key: key); //this.onChanges

  @override
  State<StatefulWidget> createState() => CustomDrawerState();
}

class CustomDrawerState extends State<CustomDrawer>
    implements WebsocketEventListener {
  bool canImp = true;
  bool onSync = false;
  bool onError = false;
  double progress = 0;

  String onlineText = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WebsocketEventListener.addListener(this);
    onlineText = WebSocketHandler.of(context).online() ? 'Online' : 'Offline';
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    WebsocketEventListener.removeListener(this);
  }

  @override
  Widget build(BuildContext context) {
    final appAmbiente = AppAmbiente.of(context);
    final appUser = AppUser.of(context);

    bool logo = true;

    // Future syncronize() async{
    //   loadingMessage = 'Iniciando';
    //   await importarTudo(
    //       context: context,
    //       onTick: importTick,
    //       onSucces: importFinish,
    //       onFail: onFail);
    // }

    int i = 0;

    return Drawer(
      child: ListView(
        children: <Widget>[
          /// Implementar sistema pra mostrar logo customizada
          if (logo)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'Yukem Vendas',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    textAlign: TextAlign.left,
                  ),
                  Text(appUser.vendedor,
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.left),
                  Text(appVersion,
                      style: const TextStyle(fontSize: 12),
                      textAlign: TextAlign.left),
                  Text(onlineText, textAlign: TextAlign.left),
                ],
              ),
            ),
          if (logo) const Divider(color: Colors.grey),
          // DrawerTile(
          //   iconData: Icons.home,
          //   title: 'TESTE',
          //   page: i++,
          // ),



          DrawerTile(
            iconData: Icons.home,
            title: 'Teste',
            page: i++,
          ),

          if (appAmbiente.usarRota)
            DrawerTile(
              iconData: Icons.home,
              title: 'Visitas',
              page: i++,
            ),
          if (appAmbiente.usarFaturamento)
            DrawerTile(
              iconData: Icons.monetization_on,
              title: appAmbiente.usarFaturamentoComoOrcamento
                  ? 'Orçamento'
                  : 'Faturamento',
              page: i++,
            ),

          DrawerExpansionTile(
            iconData: Icons.bar_chart,
            title: 'Dashboard',
            children: [
              if (appAmbiente.usarComissao)
                DrawerTile(
                  iconData: Icons.attach_money,
                  title: 'Comissão',
                  page: i++,
                ),
              if (appAmbiente.usarVendasTotais)
                DrawerTile(
                  iconData: Icons.attach_money,
                  title: 'Vendas Totais',
                  page: i++,
                ),
              DrawerTile(
                iconData: Icons.shopping_cart_outlined,
                title: 'Visitas Finalizadas',
                page: i++,
              ),
              DrawerTile(
                iconData: Icons.pie_chart,
                title: 'Crítica Vendedor',
                page: i++,
              ),
              DrawerTile(
                iconData: Ionicons.bar_chart,
                title: 'Metas',
                page: i++,
              ),
              DrawerTile(
                iconData: CupertinoIcons.time,
                title: 'Status Pedido',
                page: i++,
              ),
            ],
            id: 0,
          ),

          const Divider(color: Colors.grey),
          if (appAmbiente.usarCadastroCliente)
            DrawerTile(
              iconData: Icons.people,
              title: 'Clientes',
              page: i++,
            ),
          DrawerTile(
            iconData: CupertinoIcons.cube_box,
            title: 'Produtos',
            page: i++,
          ),
          // const Divider(color: Colors.grey),

          // DrawerTile(
          //   iconData: Icons.message_outlined,
          //   title: 'Mensagens',
          //   page: i++,
          // ),

          // DrawerTile(
          //   iconData: Icons.map,
          //   title: 'Roteirizador',
          //   page: i++,
          // ),
          if (appAmbiente.usarRota)
            DrawerTile(
              iconData: Icons.map_outlined,
              title: 'Rotas',
              page: i++,
            ),
          // DrawerTile(
          //   iconData: Icons.search,
          //   title: 'Consultas',
          //   page: i++,
          // ),
          //
          //
          // DrawerTile(
          //   iconData: Icons.insert_chart_outlined,
          //   title: 'Painel de Gestão',
          //   page: i++,
          // ),
          //
          //
          // DrawerTile(
          //   iconData: Icons.bar_chart,
          //   title: 'Gráficos',
          //   page: i++,
          // ),

          // Incluir Visita na Agenda

          if (appAmbiente.usarRota && appAmbiente.usarIncluirVisitaAgenda)
            DrawerTile(
              iconData: Icons.person_add_outlined,
              title: 'Incluir Visita na Agenda',
              page: i++,
            ),
          const Divider(color: Colors.grey),

          // DrawerTile(
          //   iconData: Icons.star,
          //   title: 'Testes',
          //   page: i++,
          // ),

          // if (!onSync)
          //   DrawerTile(
          //     iconData: Icons.sync,
          //     title: 'Sincronização',
          //     page: i++,
          //     onPressed: () {
          //       {
          //         onError = false;
          //         onSync = true;
          //         importarTudo(
          //             context: context,
          //             // forcar: true,
          //             onTick: importTick,
          //             onSucces: importFinish,
          //             onFail: onFail);
          //         update();
          //       }
          //     },
          //   ),
          // if (onSync)
          //   SyncViewer(),
          DrawerTile(
            iconData: Icons.settings,
            title: 'Configurações',
            page: i++,
          ),
          const Divider(color: Colors.grey),
          DrawerTile(
            iconData: Icons.logout,
            title: 'Sair',
            page: i++,
            onPressed: () => Application.logout(context),
          ),
        ],
      ),
    );
  }

  @override
  void onChangeStatus(bool online) {
    setState(() {
      onlineText = online ? 'Online' : 'Offline';
    });
  }

  @override
  void onGenericEvent(List event) {
    // TODO: implement onGenericEvent
  }
}

bool showConsultas = false;
