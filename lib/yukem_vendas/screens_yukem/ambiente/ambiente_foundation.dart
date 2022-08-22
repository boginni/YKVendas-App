import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:forca_de_vendas/yukem_vendas/models/configuracao/app_user.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/clientes/tela_buscar_cliente.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/comodato/tela_comodato.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/encerramento/tela_encerramento_dia.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/titulos/tela_titulos_vencidos.dart';
import 'package:provider/provider.dart';

import '../../../api/common/custom_widgets/custom_text.dart';
import '../../../api/models/configuracao/app_system.dart';
import '../../../api/screens/support/screen_loading.dart';
import '../../models/configuracao/app_ambiente.dart';
import '../../models/database_objects/rota.dart';
import 'base/menu_principal.dart';
import 'clientes/novo_cliente.dart';
import 'produtos/tela_novo_produto.dart';
import 'produtos/tela_view_produto.dart';
import 'visita/tela_pedido/tela_adicionar_item.dart';
import 'visita/tela_pedido/tela_item_do_pedido.dart';
import 'visita/tela_pedido/tela_tabela_de_preco.dart';
import 'visita/tela_visita.dart';
import 'visita/tela_visita/chegada_cliente.dart';
import 'visita/tela_visita/tela_importar_produtos.dart';
import 'visita/tela_visita/tela_pedido.dart';
import 'visita/tela_visita/tela_visita_realizada.dart';
import 'visita/tela_visita/tela_visualizacao_visita.dart';

class AmbienteFoundation extends StatefulWidget {
  const AmbienteFoundation({Key? key}) : super(key: key);

  @override
  State<AmbienteFoundation> createState() => _AmbienteFoundationState();
}

class _AmbienteFoundationState extends State<AmbienteFoundation> {
  AppAmbiente? appAmbiente;
  Rota? ultimaRota;

  tryGetApp() async {
    appAmbiente = AppAmbiente.fromMap(
        await AppAmbiente.getAppAmbiente(AppUser.of(context).vendedorAtual));
    ultimaRota = await getUltimaRota();

    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      tryGetApp();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = AppSystem.of(context).appTheme;

    if (appAmbiente == null) {
      return const ScreenLoading(
        children: [
          TextTitle(
            'Iniciando Ambiente',
          ),
          Text('Isso não deve demorar'),
        ],
      );
    }

    return MultiProvider(
      providers: [
        Provider<Rota>(
          create: (_) => ultimaRota!,
        ),
        Provider<AppAmbiente>(
          create: (_) => appAmbiente!,
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('pt', 'BR'),
        ],
        // locale: const Locale('pt'),

        debugShowCheckedModeBanner: true,
        title: "Forca de vendas",
        theme: ThemeData(
          primaryColor: appTheme.primaryColor,
          scaffoldBackgroundColor: appTheme.secondaryColor,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          primaryIconTheme:
              const IconThemeData(color: Colors.black, opacity: 255),
          appBarTheme: AppBarTheme(
            elevation: 1,
            backgroundColor: appTheme.primaryColor,
            // iconTheme: const IconThemeData(color: Colors.black),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              primary: Colors.white,
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: ElevatedButton.styleFrom(
              primary: Colors.white,
            ),
          ),
        ),
        routes: {
          TelaVisita.routeName: (context) => const TelaVisita(),
          TelaChegadaCliente.routeName: (context) => const TelaChegadaCliente(),
          TelaPedido.routeName: (context) => const TelaPedido(),
          TelaTabelaPreco.routeName: (context) => const TelaTabelaPreco(),
          TelaVisitaRealizada.routeName: (context) =>
              const TelaVisitaRealizada(),
          TelaItemPedido.routeName: (context) => const TelaItemPedido(),
          TelaVisualizacaoVisita.routeName: (context) =>
              TelaVisualizacaoVisita(),
          TelaNovoProduto.routeName: (context) => const TelaNovoProduto(),
          TelaNovoCliente.routeName: (context) => const TelaNovoCliente(),
          TelaAdicionarItem.routeName: (context) => const TelaAdicionarItem(),
          MenuPrincipal.routeName: (context) => const MenuPrincipal(),
          TelaImportarProdutos.routeName: (context) =>
              const TelaImportarProdutos(),
          TelaBuscarCliente.routeName: (context) => const TelaBuscarCliente(),
          TelaComodato.routeName: (context) => const TelaComodato(),
          TelaTitulos.routeName: (context) => const TelaTitulos(),
          TelaEncarramentoDia.routeName: (context) =>
              const TelaEncarramentoDia(),
        },
        // initialRoute: TelaNovoCliente.routeName,
        // initialRoute: BaseAmbiente.routeName,
        onGenerateRoute: (settings) {
          return MaterialPageRoute(builder: (_) => const MenuPrincipal());
        },
      ),
    );
  }
}
