import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../api/common/components/list_scrollable.dart';
import '../../../../../api/common/custom_tiles/default_tiles/tile_spaced_text.dart';
import '../../../../../api/common/custom_tiles/default_tiles/tile_topico.dart';
import '../../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../../api/common/debugger.dart';
import '../../../../../api/common/form_field/database_fields.dart';
import '../../../../../api/common/form_field/formulario.dart';
import '../../../../../api/common/formatter/arredondamento.dart';
import '../../../../models/configuracao/app_ambiente.dart';
import '../../../../models/configuracao/app_user.dart';
import '../../../../models/database/database_ambiente.dart';
import '../../../../models/database_objects/pedido.dart';
import '../modulo/info_itens.dart';

class ContainerTotaisPedido extends StatefulWidget {
  const ContainerTotaisPedido({
    Key? key,
    required this.pedido,
  }) : super(key: key);

  final Pedido pedido;

  @override
  State<StatefulWidget> createState() => _ContainerTotaisPedidoState();
}

class _ContainerTotaisPedidoState extends State<ContainerTotaisPedido> {
  double descontoMax = 0;

  final detalhesKey = GlobalKey();

  TextEditingController obsNf = TextEditingController();

  final _conDescPct = TextEditingController();
  final _conDescValor = TextEditingController();

  InfoItens? infoItens;

  double _desconto(double desconto) {
    double x =
        1 - ((infoItens!.TOTAL_BRUTO - desconto) / infoItens!.TOTAL_BRUTO);

    x = arredondaFracao(x);
    return x;
  }

  String _descontoPct(double desconto) {
    return arredondaPorcentagem(_desconto(desconto) * 100).toString();
  }

  double _descontoValor() {
    double value =
    double.parse(_conDescValor.text.isEmpty ? '0' : _conDescValor.text);

    value = arredondarValor(value);

    return value;
  }

  double _descontoPorcentagem() {
    double value =
    double.parse(_conDescValor.text.isEmpty ? '0' : _conDescValor.text);

    value = arredondarValor(value);

    value = _desconto(value);

    return value;
  }

  @override
  void initState() {
    obsNf.text = widget.pedido.moduloTotais.obsNf;

    _conDescPct.text = '';
    _conDescValor.text = '';
  }

  int xs = 0;

  void update() async {
    await widget.pedido.moduloTotais
        .updateDescontoProduto(_descontoPorcentagem(), _descontoValor());
    try {
      widget.pedido.update();

      detalhesKey.currentState!.setState(() {});
    } catch (e) {
      printDebug('Erro on container totais');
    }
  }

  bool localState = true;

  @override
  Widget build(BuildContext context) {
    final appAmbiente = AppAmbiente.of(context);
    final appUser = AppUser.of(context);

    FocusNode nodeLoseFocous = FocusNode();

    // saveTotais() async {
    //   widget.totais.obsNF = obsNf.text;
    //
    //   if (widget.totais.obsNF.isEmpty) {
    //     widget.totais.obsNF = ' ';
    //   }
    //
    //   if (formaPagamento != null) {
    //     widget.totais.idFormaPagamento = formaPagamento!.id;
    //   }
    //
    //   widget.totais.idVendedor = appUser.vendedorAtual;
    //
    //   await widget.totais.salvar().then((value) {
    //     if (appAmbiente.usarDescontoItem) {
    //       return;
    //     }
    //
    //     widget.totais.updateDescontoProduto();
    //   });
    //
    //   toLoad = false;
    //
    //   detalhesKey.currentState!.setState(() {});
    //
    //   widget.onUpdate();
    // }

    nodeLoseFocous.addListener(() {
      if (!nodeLoseFocous.hasFocus) {
        // saveTotais();
      }
    });



    return FutureBuilder(
        future: InfoItens.getFromId(widget.pedido.moduloTotais.idVisita),
        builder: (BuildContext context, AsyncSnapshot<InfoItens?> snapshot) {
          infoItens = snapshot.data;

          if (snapshot.hasError) {
            printDebug(snapshot.error.toString());
          }

          if (infoItens == null) {
            return Container();
          }

          _conDescPct.text = _descontoPct(infoItens!.TOTAL_DESCONTO_VALOR);
          _conDescValor.text =
              arredondarValorStr(infoItens!.TOTAL_DESCONTO_VALOR);

          return Card(
            child: ListViewNested(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListViewNested(
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const TextTitle('Forma de Pagamento'),
                            if (widget.pedido.cliente.idFormaPg == null)
                              Column(
                                children: const [
                                  TextNormal(
                                      'Não possue forma de pagamento padrão'),
                                  SizedBox(
                                    height: 8,
                                  ),
                                ],
                              ),
                            Row(
                              children: [
                                Expanded(
                                  child: Builder(
                                    builder: (context) {
                                      String args = 'USA_MOBILE = 1';
                                      List<dynamic> param = [];

                                      if (appAmbiente.mostrarFormaPgCliente) {
                                        args +=
                                        ' OR ID = ${widget.pedido.cliente
                                            .idFormaPg}';
                                      }

                                      return DropdownSaved(
                                        DropdownSaved.formaPagamento,
                                        where: args,
                                        whereArgs: param,
                                        editable:
                                        appAmbiente.usarFormaPagamento &&
                                            !widget.pedido.moduloTotais
                                                .viewOnly,
                                        value: widget.pedido.moduloTotais
                                            .idFormaPagamento,
                                        onChange: (item) {
                                          update() {
                                            if (item != null) {
                                              final id =
                                                  FormaPagamento(item).id;

                                              widget.pedido.moduloTotais
                                                  .setFormaPagamento(id).then((
                                                  value) {
                                                setState(() {

                                                });
                                              });

                                              if (appAmbiente.ranquearFormaPg) {
                                                DatabaseAmbiente.execute(
                                                    'update TB_FORMA_PAGAMENTO set USOS = USOS + 1 where ID = ${id}');
                                              }
                                            }
                                          }

                                          if (!widget.pedido.moduloTotais
                                              .viewOnly) update();
                                        },
                                      );
                                    },
                                  ),
                                ),
                                // if(appAmbiente.futurePermitirFormaPgNula)
                                const SizedBox(
                                  width: 8,
                                ),
                                // if(appAmbiente.futurePermitirFormaPgNula)
                                CloseButton(
                                  onPressed: () {
                                    widget.pedido.moduloTotais
                                        .setFormaPagamento(null).then((
                                        value) {
                                      setState(() {

                                      });
                                    });
                                  },
                                )
                              ],
                            ),
                            if (appAmbiente.usarBotaoComNota &&
                                !widget.pedido.moduloTotais.viewOnly)
                              FormSwitchButton(
                                title: 'Com nota fiscal: ',
                                startValue: widget.pedido.moduloTotais.comNota,
                                onChange: (b) {
                                  widget.pedido.moduloTotais.setComNota(b);
                                },
                              ),
                          ]),
                      const TextTitle('Observação'),
                      Focus(
                        onFocusChange: (hasFocous) {
                          if (!hasFocous) {
                            widget.pedido.moduloTotais.setObsNf(obsNf.text);
                          }
                        },
                        child: TextFormField(
                          readOnly: widget.pedido.moduloTotais.viewOnly,
                          controller: obsNf,
                          onChanged: (x) {
                            widget.pedido.moduloTotais.obsNf = x;
                            // if (!widget.totais.viewOnly) saveTotais();
                          },
                        ),
                      ),
                      if (appAmbiente.usarDescontoBaixo &&
                          appAmbiente.usarDescontoTotal)
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const TextTitle("Desconto %"),
                              Focus(
                                onFocusChange: (hasFocous) {
                                  if (!hasFocous) {
                                    // _conDescPct.text = _descontoPct();
                                    // saveTotais();
                                    // widget.totais.updateDescontoProduto(pct, total);

                                    _conDescPct.text = arredondaFracao(
                                        _descontoPorcentagem() * 100)
                                        .toString();

                                    update();
                                  }
                                },
                                child: TextFormField(
                                  controller: _conDescPct,
                                  readOnly: widget.pedido.moduloTotais.viewOnly,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    fillColor: Colors.white,
                                    filled: true,
                                  ),
                                  style: const TextStyle(fontSize: 22),
                                  onTap: () =>
                                  _conDescPct.selection =
                                      TextSelection(
                                          baseOffset: 0,
                                          extentOffset:
                                          _conDescPct.value.text.length),
                                  onChanged: (text) {
                                    double x =
                                        double.tryParse(_conDescPct.text) ?? 0;

                                    x = arredondaFracao(x) / 100;

                                    _conDescValor.text = arredondarValor(
                                        infoItens!.TOTAL_BRUTO * x)
                                        .toString();

                                    // double x = double.parse(
                                    //         text.isEmpty ? '0' : text) /
                                    //     100.0;
                                    //
                                    // x = arredondaFracao(x);
                                    //
                                    // double desconto = arredondarValor(
                                    //     widget.totais.totalBruto * x);
                                    //
                                    // //
                                    // _conDescValor.text = desconto.toString();
                                    //
                                    // widget.totais.descontoValor = desconto;
                                  },
                                  autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                                  // autovalidateMode: AutovalidateMode.onUserInteraction,
                                  validator: (value) {
                                    double x = double.parse(
                                        _conDescPct.text.isEmpty
                                            ? '0'
                                            : _conDescPct.text) /
                                        100.0;

                                    if (!appAmbiente.usarDescontoMax) {
                                      return null;
                                    }

                                    if (widget.pedido.descontoMax == null) {
                                      return "Aguarde o calculo de desconto";
                                    }

                                    if (x > widget.pedido.descontoMax) {
                                      return "Desconto Acima do limite";
                                    }
                                  },
                                  inputFormatters: [
                                    // FilteringTextInputFormatter.digitsOnly,
                                    FilteringTextInputFormatter(
                                        RegExp(r'[\d.]+'),
                                        allow: true),
                                  ],
                                ),
                              ),
                            ]),
                      if (appAmbiente.usarDescontoBaixo &&
                          appAmbiente.usarDescontoTotal)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const TextTitle("Desconto R\$"),
                            Focus(
                              onFocusChange: (hasFocus) {
                                if (!hasFocus) {
                                  _conDescValor.text =
                                      _descontoValor().toString();

                                  update();
                                }
                                // _conDescValor.text =
                                //     arredondarValor(widget.totais.descontoValor)
                                //         .toString();
                                // saveTotais();
                              },
                              child: TextFormField(
                                readOnly: widget.pedido.moduloTotais.viewOnly,
                                controller: _conDescValor,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                ),
                                style: const TextStyle(fontSize: 22),
                                onTap: () =>
                                _conDescValor.selection =
                                    TextSelection(
                                        baseOffset: 0,
                                        extentOffset:
                                        _conDescValor.value.text.length),
                                onChanged: (text) {
                                  double value = _descontoValor();

                                  double x =
                                  arredondaFracao(_desconto(value) * 100);

                                  _conDescPct.text = x.toString();

                                  // _conDescValor.text = arredondarValor(
                                  //     infoItens!.TOTAL_BRUTO * x);
                                  //
                                  // widget.totais.descontoValor =
                                  //     arredondarValor(x);

                                  //
                                  // _conDescPct.text = _descontoPct();

                                  // widget.totais.descontoValor = arredondarValor(widget.totais.totalBruto * _desconto());
                                  // saveTotais();
                                },
                                // validator: (value) {
                                //       double.parse(_descontoPct()) > descontoMax!) {
                                //     return 'Desconto acima do valor máximo';
                                //   }
                                //   return null;
                                // },
                                inputFormatters: [
                                  FilteringTextInputFormatter(RegExp(r'[\d.]+'),
                                      allow: true),
                                ],
                              ),
                            ),
                          ],
                        ),
                      TileSpacedText('Desconto maximo:',
                          "${arredondaPorcentagem(
                              widget.pedido.descontoMax * 100)}%"),
                      _Detalhes(
                        widget.pedido.moduloTotais.idVisita,
                        key: detalhesKey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
}

class _Detalhes extends StatefulWidget {
  const _Detalhes(this.idVisita, {Key? key}) : super(key: key);

  final int idVisita;

  @override
  State<_Detalhes> createState() => _DetalhesState();
}

class _DetalhesState extends State<_Detalhes> {
  InfoItens? infoItens;

  @override
  Widget build(BuildContext context) {
    // final appAmbiente = AppAmbiente.of(context);

    double _getTotalLiquido() {
      return infoItens!.TOTAL_LIQ;
    }

    double _getTotalBruto() {
      return infoItens!.TOTAL_BRUTO;
    }

    double _getTotalDesconto() {
      return infoItens!.TOTAL_DESCONTO_VALOR;
    }

    return FutureBuilder(
      future: InfoItens.getFromId(widget.idVisita),
      builder: (BuildContext context, AsyncSnapshot<InfoItens?> snapshot) {
        if (snapshot.data != null) {
          infoItens = snapshot.data;
        }

        if (infoItens != null) {
          return ListViewNested(children: [
            // if (appAmbiente.usarAssinatura)
            //   const TileText(
            //     title: 'Assinatura',
            //     value: 'Not Implemented',
            //   ),

            // if (widget.visita.limiteCredito != null)
            //   ListViewNested(children: [
            //     if (_getTotalLiquido() > widget.visita.limiteCredito!)
            //       const TextNormal('Pedido acima do limite de crédido'),
            //     TileSpacedText('Limite de Crédido:',
            //         TextDinheiroReal.format(widget.visita.limiteCredito!)),
            //   ]),

            // if (widget.visita.titulosVencendo != null)
            //   TileSpacedText('Títulos a vencer:',
            //       TextDinheiroReal.format(widget.visita.titulosVencendo!)),

            // const TileTopico('Produtos'),
            // TileSpacedText('Total de Itens:', widget.totais.itens.toString()),
            // TileSpacedText(
            //     'Total em Quantidade:', widget.totais.quantidade.toString()),

            const TileTopico('Totais'),
            TileSpacedText(
                'Total Bruto:', TextDinheiroReal.format(_getTotalBruto())),
            TileSpacedText('Total Desconto:',
                TextDinheiroReal.format(_getTotalDesconto())),
            TileSpacedText(
                'Total Liquido:', TextDinheiroReal.format(_getTotalLiquido())),
            const SizedBox(
              height: 12,
            ),
          ]);
        }

        return Container();
      },
    );
  }
}

class FormaPagamento {
  final int id;
  final String? nome;

  FormaPagamento(this.id, {this.nome});
}
