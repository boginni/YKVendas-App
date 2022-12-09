import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../api/common/components/barra_progresso.dart';
import '../../../../../api/common/components/mostrar_confirmacao.dart';
import '../../../../../api/common/custom_widgets/custom_buttons.dart';
import '../../../../../api/common/custom_widgets/custom_icons.dart';
import '../../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../../api/common/custom_widgets/popupmenu_item_tile.dart';
import '../../../../../api/common/debugger.dart';
import '../../../../app_foundation.dart';
import '../../../../common/custom_tiles/object_tiles/tile_add_produtos.dart';
import '../../../../models/configuracao/app_ambiente.dart';
import '../../../../models/database_objects/pedido.dart';
import '../../../../models/database_objects/produtos_list_item.dart';
import '../../../../models/database_objects/totais_pedido.dart';
import '../../../../models/database_objects/visita.dart';
import '../../../../models/pdf/pdf_pedido.dart';
import '../../../remake/util/tela_importar_produtos.dart';
import '../../comodato/tela_comodato.dart';
import '../../titulos/tela_titulos_vencidos.dart';
import '../tela_pedido/container_dados_cliente.dart';
import '../tela_pedido/container_tabela_precos.dart';
import '../tela_pedido/tela_adicionar_item.dart';
import '../tela_visita/tela_pedido.dart';
import 'container_totais.dart';

class ContainerPedido extends StatefulWidget {
  final Pedido pedido;
  final Function() onUpdate;

  const ContainerPedido(
      {Key? key, required this.pedido, required this.onUpdate})
      : super(key: key);

  @override
  State<ContainerPedido> createState() => _ContainerPedidoState();
}

class _ContainerPedidoState extends State<ContainerPedido> {
  Visita getVisita() {
    return widget.pedido.visita;
  }

  updateVisita() {
    widget.onUpdate();
  }

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appAmbiente = AppAmbiente.of(context);

    widget.pedido.update = () {
      addProdutosKey.currentState!.setState(() {});
    };

    ///Redireciona para rota alvo, depois faz update
    redirect(String route, {List<dynamic>? customArg}) async {
      Navigator.of(context)
          .pushNamed(route, arguments: customArg ?? widget.pedido.visita.id)
          .then((value) {
        updateVisita();
      });
    }

    salvar() {
      if (!formKey.currentState!.validate()) {
        mostrarCaixaConfirmacao(context,
            mostrarCancelar: false, title: 'Corrija os campos inválidos');
        return;
      }

      save() {
        if (getVisita().idPessoa == 0) {
          mostrarCaixaConfirmacao(context,
              title: 'Cliente inválido',
              content: 'Não é permitido fazer venda nesse cliente',
              mostrarCancelar: false);

          return;
        }

        TotaisPedido.getTotaisPedido(widget.pedido.visita.id).then((value) {
          mostrarSalvar() {
            mostrarCaixaConfirmacao(context,
                    title: 'Deseja salvar o pedido?',
                    content:
                        "Após salvar, haverá uma sincronização automática em segundo plano")
                .then((value) {
              if (!value) {
                return;
              }

              widget.pedido.salvarDados().then((value) {
                // syncronizeEverything(context: context).then((value) {});
                Navigator.of(context).pop();
              });
            });
          }

          if (value == null) {
            mostrarCaixaConfirmacao(context,
                title: 'Precisa adicionar Itens',
                content:
                    'Não foi selecionado nem um item, clique em "Itens do pedido" para escolher produtos ',
                mostrarCancelar: false);
            return;
          }

          if (value.idFormaPagamento == null) {
            if (appAmbiente.permitirFormaPgNula) {
              mostrarCaixaConfirmacao(context,
                      title: 'Sem forma de pagamento',
                      content:
                          'Não foi selecionado uma forma de pagamento, deseja Continuar?')
                  .then((value) {
                if (value) {
                  mostrarSalvar();
                }
              });
              return;
            }

            mostrarCaixaConfirmacao(context,
                title: 'Forma de pagamento é obrigatória',
                content:
                    'É necessário ter uma forma de pagamento para poder salvar',
                mostrarCancelar: false);
            return;
          }

          mostrarSalvar();
        });
      }

      if (appAmbiente.calcularEstoque) {
        int idVisita = widget.pedido.visita.id;
        validarItens(idVisita).then((value) {
          if (value) {
            save();
          } else {
            mostrarCaixaConfirmacao(context,
                title: 'Verifique os produtos',
                content:
                    'Um ou mais produtos estão com quantidade acima do estoque atual.',
                mostrarCancelar: false);
          }
        });
      } else {
        save();
      }
    }

    limpar() async {
      mostrarCaixaConfirmacao(context,
              title: 'Deseja realmente limpar?',
              content: 'Todos os dados serão apagados')
          .then((value) {
        if (value) {
          widget.pedido.limparDados();
          Navigator.of(context).pop();
        }
      });
    }

    Widget _popupMenu() {
      final controller = TextEditingController();

      return PopupMenuButton<int>(
        padding: const EdgeInsets.all(0.0),
        onSelected: (x) {
          switch (x) {
            case 1:
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const TextTitle('Compartilhar Pedido'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (AppAmbiente.of(context)
                                  .usarFaturamentoComoOrcamento &&
                              getVisita().faturamento)
                            Flexible(
                              flex: 1,
                              child: Container(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const TextTitle('Nome do cliente'),
                                    Flexible(
                                        child: TextField(
                                      controller: controller,
                                    )),
                                    const SizedBox(
                                      height: 16,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          const TextTitle('Selecione o Formato'),
                          Flexible(
                            flex: 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    final key =
                                        await mostrarBarraProgressoCircular(
                                            context);

                                    gerarRelatorio(getVisita().id,
                                            formato: true,
                                            pessoaNome: controller.text)
                                        .then((value) {
                                      key.currentState!.finish();
                                    }).catchError((value) {
                                      printDebug(value);
                                      key.currentState!.setError('Error', '');
                                    });
                                  },
                                  child: const IconBig(Icons.picture_as_pdf),
                                ),
                                InkWell(
                                  onTap: () async {
                                    final key =
                                        await mostrarBarraProgressoCircular(
                                            context);
                                    gerarRelatorio(getVisita().id,
                                            formato: false)
                                        .then((value) {
                                      key.currentState!.finish();
                                    }).catchError((value) {
                                      printDebug(value);
                                      key.currentState!.setError('Error', '');
                                    });
                                  },
                                  child: const IconBig(Icons.image),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  });
              break;
            case 2:
              Application.navigate(
                context,
                TelaHistoricoPedidos(
                  idPessoa: getVisita().idPessoaSync,
                  idVisita: getVisita().id,
                ),
              ).then((value) {
                updateVisita();
              });
              break;
            case 3:
              if (getVisita().idPessoaSync != null) {
                Application.navigate(
                  context,
                  TelaTitulos(
                    idPessoaSync: getVisita().idPessoaSync!,
                  ),
                );
              }
              break;
            case 4:
              Application.navigate(
                context,
                TelaComodato(
                  idPessoaSync: getVisita().idPessoaSync,
                ),
              );
              break;
            case 5:
              TelaPedido.performHotReload(context);
              break;
          }
        },
        itemBuilder: (context) => [
          TilePopupMenuItem(
            value: 1,
            icon: Icons.share,
            title: 'Compartilhar',
          ),
          TilePopupMenuItem(
            value: 2,
            icon: CupertinoIcons.clock,
            title: 'Historico de pedidos',
          ),
          TilePopupMenuItem(
            value: 3,
            icon: Icons.attach_money,
            title: 'Títulos em aberto',
          ),
          TilePopupMenuItem(
            value: 4,
            icon: CupertinoIcons.cube_box,
            title: 'Comodatos',
          ),
          TilePopupMenuItem(
            value: 5,
            icon: Icons.sync,
            title: 'Atualizar Tela',
          ),
        ],
        child: const Padding(
          padding: EdgeInsets.only(right: 20),
          child: Icon(
            Icons.more_vert_outlined,
            size: 26.0,
          ),
        ),
      );
    }

    return Form(
      key: formKey,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tela Pedido'),
          centerTitle: true,
          leading: BackButton(
            onPressed: () {
              Navigator.of(context).pop(context);
            },
          ),
          actions: [
            _popupMenu(),
          ],
        ),
        bottomNavigationBar: Container(
          color: Theme.of(context).primaryColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ButtonLimpar(enabled: true, onPressed: limpar),
                ButtonSalvar(
                  enabled: !(appAmbiente.usarFaturamentoComoOrcamento &&
                      getVisita().faturamento),
                  onPressed: salvar,
                )
              ],
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            TelaPedido.performHotReload(context);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              ContainerDadosCliente(
                idVisita: getVisita().id,
                pedido: widget.pedido,
                update: () async {
                  updateVisita();
                },
              ),
              if (appAmbiente.usarTabela || appAmbiente.mostrarTabela)
                ContainerTabelaPrecos(
                  visita: getVisita(),
                  onChange: (int? i) {
                    updateVisita();
                  },
                ),
              TileAddProdutosButton(
                getVisita().id,
                key: addProdutosKey,
                concluida: getVisita().itensConcluida,
                enabled: true,
                onPressed: () => redirect(TelaAdicionarItem.routeName).then(
                  (value) {
                    setState(() {});
                  },
                ),
                afterClickItem: () {
                  setState(
                    () {
                      updateVisita();
                    },
                  );
                },
              ),

              // if (appAmbiente.usarDadosEntrega)
              //   ContainerDadosEntrega(
              //     idVisita: getVisita().id,
              //     onUpdate: () {
              //       updateVisita();
              //     },
              //     dados: widget.pedido.dadosEntrega,
              //   ),

              ContainerTotaisPedido(pedido: widget.pedido),
              // if (getVisita().itensConcluida)
              //   ContainerTotaisPedido(
              //     visita: getVisita(),
              //     onUpdate: () =>  addProdutosKey.currentState!.setState(() {}),
              //   ),
            ],
          ),
        ),
      ),
    );
  }

  final addProdutosKey = GlobalKey();
}
