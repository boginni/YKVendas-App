import 'dart:io';

import 'package:flutter/material.dart';
import 'package:forca_de_vendas/api/models/page_manager.dart';
import 'package:forca_de_vendas/yukem_vendas/models/configuracao/app_user.dart';
import 'package:forca_de_vendas/yukem_vendas/models/file/file_manager.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/dashboard/tela_status_pedidos.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/faturamento/tela_faturamento.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/teste/tela_gerador_vendas.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/vendas/tela_vendas.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/vendas/tela_vendas_totais.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../../api/common/debugger.dart';
import '../../../models/configuracao/app_ambiente.dart';
import '../../../models/internet/internet.dart';
import '../../../models/websocket/websocket.dart';
import '../../../models/websocket/websocket_handler.dart';
import '../clientes/tela_clientes.dart';
import '../configuracoes/tela_configuracoes_user.dart';
import '../consultas/tela_consultas.dart';
import '../dashboard/tela_critica.dart';
import '../dashboard/tela_metas.dart';
import '../produtos/tela_produtos.dart';
import '../rotas/tela_rotas.dart';
import '../vendas/tela_comissao.dart';
import '../visita/tela_principal.dart';
import '../visita_agenda/tela_incluir_visita_na_agenda.dart';

class MenuPrincipal extends StatefulWidget {
  static const routeName = '/base';

  const MenuPrincipal({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BaseSreenState();

  static reloadAmbiente(BuildContext context) {}
}

class _BaseSreenState extends State<MenuPrincipal>
    implements WebsocketEventListener {
  /// Duplicado com o Yukem vendas por haver necessidade de fechar o socket antes de sair

  WebSocketHandler ws = WebSocketHandler();

  @override
  void dispose() {
    super.dispose();
    ws.end();
    WebsocketEventListener.removeListener(this);
  }

  @override
  void initState() {
    super.initState();
    final ambiente = AppUser.of(context).ambiente;
    ws.ambiente = ambiente;
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      ws.init();
      downloadLogo(ambiente);
    });
    WebsocketEventListener.addListener(this);
  }

  @override
  void onGenericEvent(List event) {
    WebsockeEvent.updateDatabaseEvent(context, event);
  }

  @override
  void onChangeStatus(bool online) {}

  downloadLogo(String ambiente) async {
    final filePath = await FilePath.getLogoFilePath(ambiente);
    File imgFile = File(filePath);

    if (!(imgFile.existsSync() && imgFile.lengthSync() > 200)) {
      try {
        final response = await http.get(
          Uri.parse('${Internet.getHttpServer()}/image/$ambiente/logo.png'),
          headers: {
            'Accept-Encoding': 'gzip, deflate, br',
            'Connection': 'keep-alive'
          },
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 404 || response.bodyBytes.isEmpty) {
          return;
        }

        FileManager.writeFile(filePath, response.bodyBytes);

        printDebug('logo baixada');
      } catch (e) {
        printDebug('Não foi possível baixar a logo');
      }
    }
  }

  final PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final appAmbiente = AppAmbiente.of(context);

    return MultiProvider(
      providers: [
        Provider(
          create: (BuildContext context) =>
              PageManager(pageController: pageController),
        ),
        Provider(create: (BuildContext context) => ws),
      ],
      child: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // TelaGerarVendas(),
          // const Teste(),
          if (appAmbiente.usarRota) const TelaPrincipal(),
          if (appAmbiente.usarFaturamento) const TelaFaturamento(),
          if (appAmbiente.usarComissao) const TelaComissao(),
          if (appAmbiente.usarVendasTotais) const TelaVendasTotais(),
          const TelaVisitaConcluida(),
          const TelaCritica(),
          // const TelaMetas(),
          const TelaStatusPedido(),
          // if (appAmbiente.usarEncerramentoDia) const TelaEncarramentoDia(),
          if (appAmbiente.usarConsultas) const TelaConsultas(),

          if (appAmbiente.usarCadastroCliente) const TelaClientes(),
          const TelaProdutos(),
          if (appAmbiente.usarRota) const TelaRotas(),
          // const TelaConsultas(),
          if (appAmbiente.usarRota && appAmbiente.usarIncluirVisitaAgenda)
            const TelaIncluirVisita(),
          // const TelaTestJson(),
          // const TelaSincronizacao(),
          const TelaConfiguracoesUser(),
          // const LoginScreen(),
        ],
      ),
    );
  }
}
