import 'package:flutter/material.dart';

import '../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../api/models/configuracao/app_system.dart';
import '../../../../api/models/interface/queue_action.dart';
import '../../../common/custom_tiles/object_tiles/tile_produto.dart';
import '../../../models/configuracao/app_ambiente.dart';
import '../../../models/configuracao/app_user.dart';
import '../../../models/database_objects/produto.dart';
import '../../../models/database_objects/totais_pedido.dart';
import '../base/custom_drawer.dart';
import '../dashboard/components/container_loading.dart';

class TelaProdutos extends StatefulWidget {
  static const routeName = '/telaAdicionarItem';

  const TelaProdutos({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TelaProdutosState();
}

extension Numeric on String {
  bool get isNumeric => num.tryParse(this) != null ? true : false;
}

class _TelaProdutosState extends State<TelaProdutos> {
  TextEditingController controllerPesquisa = TextEditingController();

  bool reloadTotais = true;
  TotaisPedido? totaisPedido;
  List<ProdutoListNormal> listProdutos = [];
  bool mostrarPesquisa = true;
  bool btnLoading = false;

  final ScrollController _scrollController = ScrollController();

  late final AppSystem appSystem;
  late final AppUser appUser;
  late final AppAmbiente appAmbiente;

  @override
  void initState() {
    super.initState();
    appSystem = AppSystem.of(context);
    appUser = AppUser.of(context);
    appAmbiente = AppAmbiente.of(context);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getList(AppAmbiente.of(context).limitarResultados);
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
      limitar: limitar,
      limit: limit,
    ).then((value) {
      setState(() {
        listProdutos = value;
        btnLoading = false;
        onLoading = false;
        if (value.isNotEmpty) {
          Future.delayed(const Duration(seconds: 1)).then((value) {
            QueueAction.doLoop();
          });
        } else {
          QueueAction.clearListeners();
        }
      });
    });
  }

  bool onLoading = true;
  int limit = 12;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos '),
        centerTitle: false,
      ),
      drawer: const CustomDrawer(),
      body: onLoading
          ? const ContainerLoading()
          : RefreshIndicator(
              onRefresh: () =>
                  getList(AppAmbiente.of(context).limitarResultados),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                children: [
                  if (mostrarPesquisa)
                    Column(
                      children: [
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
                                    hintText: "ID ou Nome do Produto",
                                  ),
                                  style: textNormalStyle(appSystem),
                                  onChanged: (x) {
                                    if (appSystem.usarPesquisaDinamica) {
                                      limit = 12;
                                      getList(appAmbiente.limitarResultados);
                                    }
                                  },
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    limit = 12;
                                    getList(appAmbiente.limitarResultados);
                                  },
                                  child: const TextTitle('Pesquisar'),
                                )
                              ],
                            ),
                          ),
                        ),
                        const Divider()
                      ],
                    ),
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
                                getList(true);
                              },
                            );
                          },
                          child: const Text('Carregar Mais'),
                        )
                ],
              ),
            ),
    );
  }
}
