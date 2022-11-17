import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:forca_de_vendas/api/common/components/barra_progresso.dart';
import 'package:forca_de_vendas/api/models/interface/queue_action.dart';
import 'package:forca_de_vendas/api/models/interface/realtime_sync.dart';
import 'package:forca_de_vendas/yukem_vendas/models/database_objects/tabela_precos.dart';
import 'package:forca_de_vendas/yukem_vendas/models/pdf/catalogo/catalogo.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/dashboard/components/container_loading.dart';

import '../../../../../api/common/custom_widgets/custom_buttons.dart';
import '../../../../../api/common/custom_widgets/custom_icons.dart';
import '../../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../../api/common/debugger.dart';
import '../../../../../api/common/form_field/database_fields.dart';
import '../../../../../api/models/configuracao/app_system.dart';
import '../../../../common/custom_tiles/object_tiles/tile_produtos/tile_produto_item.dart';
import '../../../../models/database/database_ambiente.dart';
import '../../../../models/database/query_filter_produto.dart';
import '../../../../models/database_objects/produtos_list_item.dart';
import '../../../../models/database_objects/totais_pedido.dart';

class TelaAdicionarItem extends StatefulWidget {
  static const routeName = '/telaAdicionarItem';

  const TelaAdicionarItem({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TelaAdicionarItemState();
}

class _TelaAdicionarItemState extends State<TelaAdicionarItem>
    implements RealTimeSync {
  TextEditingController controllerPesquisa = TextEditingController();
  FiltrosProdutos? filtrosProdutos;
  bool toSearch = true;
  TotaisPedido? totaisPedido;
  List<ProdutoListItem> itens = [];
  final ScrollController _scrollController = ScrollController();
  bool mostrarPesquisa = true;

  /// TODO: Unificar com outra chamada
  int? idTabela;
  int? idVisita;
  String nomeTabela = '';
  bool finishBuild = false;
  bool onLoading = false;

  @override
  void initState() {
    super.initState();
    RealTimeSync.addListener(this);
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      idVisita = ModalRoute.of(context)!.settings.arguments as int;

      filtrosProdutos = FiltrosProdutos(idVisita!);

      idTabela = (await DatabaseAmbiente.select('TB_VISITA',
          where: 'ID = ?', whereArgs: [idVisita]))[0]['ID_TABELA'];

      nomeTabela = (await TabelaPreco.getTabelaPreco(idVisita!))!.nome!;

      TotaisPedido.getTotaisPedido(idVisita!).then((value) {
        setState(() {
          totaisPedido = value;
          finishBuild = true;
          getList();
        });
      });
    });
  }

  reloadTotais() {
    TotaisPedido.getTotaisPedido(idVisita!).then((value) {
      setState(() {
        totaisPedido = value;
      });
    });
  }

  Future<List<ProdutoListItem>> getListCatalogo() async {
    return await getProdutoList(idVisita!,
        idTabela: idTabela, filtros: filtrosProdutos!, limitar: false);
  }

  @override
  void dispose() {
    super.dispose();
    RealTimeSync.removeListener(this);
    QueueAction.clearListeners();
  }

  getList() {
    getProdutoList(idVisita!,
            idTabela: idTabela,
            filtros: filtrosProdutos!,
            limitar: true,
            limit: limiteResultados)
        .then(
      (value) {

        setState(() {
          itens = value;
          onLoading = false;
        });

        if (value.isNotEmpty) {
          Future.delayed(const Duration(seconds: 1)).then((value) {
            QueueAction.doLoop();
          });
        } else {
          QueueAction.clearListeners();
        }

      },
    );
  }

  int limiteResultados = 12;

  @override
  Widget build(BuildContext context) {
    AppSystem appSystem = AppSystem.of(context);

    update() {
      filtrosProdutos!.limite = 15;
      filtrosProdutos!.pesquisa = controllerPesquisa.text;
      getList();
    }

    lerQRCode() async {
      FlutterBarcodeScanner.scanBarcode(
        "#FFFFFF",
        "Cancelar",
        false,
        ScanMode.BARCODE,
      ).then((value) {
        if (value == '-1') return;
        controllerPesquisa.text = value;
        update();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(nomeTabela),
        centerTitle: false,
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).maybePop(context);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: InkWell(
              onTap: () {
                final key = mostrarBarraProgressoCircular(context);
                Future.delayed(const Duration(milliseconds: 250)).then((value) {
                  getListCatalogo().then((list) {
                    gerarCatalogo(list)
                        .then((value) => key.currentState!.finish());
                  });
                });
              },
              child: const Icon(Icons.share, size: 26.0),
            ),
          ),
        ],
      ),
      body: finishBuild
          ? RefreshIndicator(
              onRefresh: () async {
                getList();
              },
              child: ListView(
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
                children: [
                  if (mostrarPesquisa)
                    Column(
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 6.0),
                            child: filtrosProdutos != null
                                ? Column(
                                    children: [
                                      const Align(
                                        alignment: Alignment.centerLeft,
                                        child: TextTitle('CATEGORIA'),
                                      ),
                                      ExpansionTile(
                                        maintainState: true,
                                        title: const Text('Categorias'),
                                        children: [
                                          TileCategoria(
                                            table: 'VW_CATEGORIA_DEPARTAMENTO',
                                            hint: 'Departamento',
                                            startValue:
                                                filtrosProdutos!.departamento,
                                            onChange: (int? i) {
                                              filtrosProdutos!.departamento = i;

                                              if (appSystem
                                                  .usarPesquisaDinamica) {
                                                update();
                                              }
                                            },
                                          ),
                                          TileCategoria(
                                            table: 'VW_CATEGORIA_GRUPO',
                                            hint: 'Grupo',
                                            startValue: filtrosProdutos!.grupo,
                                            onChange: (int? i) {
                                              filtrosProdutos!.grupo = i;
                                              if (appSystem
                                                  .usarPesquisaDinamica) {
                                                update();
                                              }
                                            },
                                          ),
                                          TileCategoria(
                                            table: 'VW_CATEGORIA_SUB_GRUPO',
                                            hint: 'SubGrupo',
                                            startValue:
                                                filtrosProdutos!.subgrupo,
                                            onChange: (int? i) {
                                              filtrosProdutos!.subgrupo = i;
                                              if (appSystem
                                                  .usarPesquisaDinamica) {
                                                update();
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 5,
                                            child: TextFormField(
                                              controller: controllerPesquisa,
                                              decoration: const InputDecoration(
                                                  fillColor: Colors.white,
                                                  filled: true,
                                                  hintText:
                                                      "ID, GTIN ou Nome do Produto"),
                                              style: textNormalStyle(appSystem),
                                              onChanged: (x) {
                                                if (appSystem
                                                    .usarPesquisaDinamica) {
                                                  update();
                                                }
                                              },
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: InkWell(
                                              onTap: () {
                                                lerQRCode();
                                                if (appSystem
                                                    .usarPesquisaDinamica) {
                                                  update();
                                                }
                                              },
                                              child: const IconSmall(
                                                  Icons.qr_code),
                                            ),
                                          )
                                        ],
                                      ),
                                      ButtonPesquisar(onPressed: () {
                                        limiteResultados = 12;
                                        update();
                                      })
                                    ],
                                  )
                                : Container(),
                          ),
                        ),
                      ],
                    ),
                  const Divider(),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: itens.length,
                    itemBuilder: (context, index) {
                      return TileItemPedido(
                        itens[index],
                        afterClick: (newItem) {
                          itens[index] = newItem;
                          reloadTotais();
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
                              limiteResultados += 100;
                              Future.delayed(
                                Duration(milliseconds: 250),
                                () {
                                  setState(() {
                                    onLoading = true;
                                    update();
                                  });
                                },
                              );
                            });
                          },
                          child: const Text('Carregar Mais'),
                        )
                ],
              ),
            )
          : const ContainerLoading(),
      bottomNavigationBar: finishBuild
          ? Container(
              color: Theme.of(context).primaryColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Builder(
                      builder: (context) {
                        double tot = 0;

                        if (totaisPedido != null) {
                          tot = totaisPedido!.totalLiquido;
                        }

                        return TextSpamable(
                          textList: [
                            const TextNormal('Total:'),
                            TextDinheiroReal(valor: tot)
                          ],
                        );

                      },
                    ),
                    ButtonSalvar(
                      enabled: true,
                      onPressed: () => Navigator.of(context).maybePop(context),
                    )
                  ],
                ),
              ),
            )
          : null,
    );
  }

  @override
  void onEvent(List<int> events) {
    bool toUp = false;

    for (final i in events) {
      if (i == 3) {
        toUp = true;
      }
    }

    if (!toUp) {
      return;
    }

    try {
      setState(() {
        toSearch = true;
      });
    } catch (e) {
      printDebug(e.toString());
    }
  }
}

class TileCategoria extends StatefulWidget {
  const TileCategoria(
      {Key? key,
      required this.table,
      required this.hint,
      this.startValue,
      required this.onChange})
      : super(key: key);

  final String table;
  final String hint;

  final int? startValue;

  final Function(int? i) onChange;

  @override
  State<TileCategoria> createState() => _TileCategoriaState();
}

class _TileCategoriaState extends State<TileCategoria> {
  int? init;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  bool toState = false;

  @override
  Widget build(BuildContext context) {
    if (!toState) {
      init = widget.startValue;
    }
    toState = false;

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          flex: 5,
          child: DropdownSaved(
            widget.table,
            value: init,
            onChange: (int? i) {
              if (i != null) {
                widget.onChange(i);
              }
            },
            hint: widget.hint,
          ),
        ),
        Flexible(
          flex: 1,
          child: ElevatedButton(
            onPressed: () {
              toState = true;
              init = null;
              widget.onChange(null);
              setState(() {});
            },
            child: const IconSmall(
              CupertinoIcons.clear_circled_solid,
            ),
          ),
        )
      ],
    );
  }
}
