import 'package:flutter/material.dart';
import 'package:forca_de_vendas/api/models/interface/queue_action.dart';
import 'package:forca_de_vendas/yukem_vendas/models/configuracao/app_ambiente.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/base/moddel_screen.dart';

import '../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../api/models/configuracao/app_system.dart';
import '../../../common/custom_tiles/object_tiles/tile_produto.dart';
import '../../../models/configuracao/app_user.dart';
import '../../../models/database_objects/produto.dart';
import '../../../models/database_objects/totais_pedido.dart';
import '../base/custom_drawer.dart';

class TelaProdutos extends ModdelScreen {
  static const routeName = '/telaAdicionarItem';

  const TelaProdutos({Key? key}) : super(key: key);

  @override
  Widget getCustomScreen(BuildContext context) {
    // TODO: implement getCustomScreen
    return xTelaProdutos();
  }
}

class xTelaProdutos extends StatefulWidget {
  const xTelaProdutos({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TelaProdutosState();
}

extension Numeric on String {
  bool get isNumeric => num.tryParse(this) != null ? true : false;
}

class _TelaProdutosState extends State<xTelaProdutos> {
  TextEditingController controllerPesquisa = TextEditingController();

  bool reloadTotais = true;
  TotaisPedido? totaisPedido;
  List<ProdutoListNormal> listProdutos = [];

  final ScrollController _scrollController = ScrollController();

  bool mostrarPesquisa = true;

  late final AppSystem appSystem;
  late final AppUser appUser;
  late final AppAmbiente appAmbiente;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    appSystem = AppSystem.of(context);
    appUser = AppUser.of(context);
    appAmbiente = AppAmbiente.of(context);

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      getList(appAmbiente.limitarResultados);
    });
  }

  Future getList(bool limitar) async {
    final x = controllerPesquisa.text;

    String args = '';
    List<dynamic> param = [];
    if (x.isNumeric) {
      args += 'ID_PRODUTO = ?';
      param.add(x);
    } else {
      args += 'NOME LIKE ?';
      param.add('%$x%');
    }

    ProdutoListNormal.getProdutos(
            where: '($args) AND STATUS = 1 AND MOBILE = 1',
            args: param,
            limit: limitar)
        .then((value) {
      setState(() {
        listProdutos = value;
        if (value.isNotEmpty) {
          // print('doing loop');
          Future.delayed(const Duration(seconds: 1)).then((value) {
            QueueAction.doLoop();
          });
        } else {
          QueueAction.clearListeners();
          // print('denied loop');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos '),
        centerTitle: false,
      ),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Column(
          children: [
            if (mostrarPesquisa)
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 6.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: controllerPesquisa,
                        decoration: const InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            hintText: "ID ou Nome do Produto"),
                        style: textNormalStyle(appSystem),
                        onChanged: (x) {
                          if (appSystem.usarPesquisaDinamica) {
                            getList(appAmbiente.limitarResultados);
                          }
                        },
                      ),
                      ElevatedButton(
                        onPressed: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          getList(appAmbiente.limitarResultados);
                        },
                        child: const TextTitle('Pesquisar'),
                      )
                    ],
                  ),
                ),
              ),
            if (appAmbiente.limitarResultados)
              const Center(
                  child: TextTitle('Limitando a no maximo 100 resultados')),
            if (mostrarPesquisa) const Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: listProdutos.length,
              itemBuilder: (context, index) {
                return TileProduto(
                  produto: listProdutos[index],
                  mostrarIcone: appAmbiente.mostrarFotoProduto,
                  ambiente: appUser.ambiente,
                  onUpdate: () {
                    setState(() {});
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
