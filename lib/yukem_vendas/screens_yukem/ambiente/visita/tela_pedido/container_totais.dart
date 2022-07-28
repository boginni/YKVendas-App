import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forca_de_vendas/api/common/formatter/arredondamento.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../../api/common/components/list_scrollable.dart';
import '../../../../../api/common/custom_tiles/default_tiles/tile_spaced_text.dart';
import '../../../../../api/common/custom_tiles/default_tiles/tile_topico.dart';
import '../../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../../api/common/debugger.dart';
import '../../../../../api/common/form_field/database_fields.dart';
import '../../../../../api/common/form_field/formulario.dart';
import '../../../../models/configuracao/app_ambiente.dart';
import '../../../../models/configuracao/app_user.dart';
import '../../../../models/database/database_ambiente.dart';
import '../../../../models/database_objects/totais_pedido.dart';
import '../../../../models/database_objects/visita.dart';

class ContainerTotaisPedido extends StatefulWidget {
  static const routeName = '/telaTotaisPedido';
  final Visita visita;
  final Function onUpdate;

  const ContainerTotaisPedido(
      {Key? key, required this.visita, required this.onUpdate})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ContainerTotaisPedidoState();
}

class _ContainerTotaisPedidoState extends State<ContainerTotaisPedido> {
  double descontoMax = 0;

  @override
  Widget build(BuildContext context) {
    final appAmbiente = AppAmbiente.of(context);
    final appUser = AppUser.of(context);

    Future<TotaisPedido> setup() async {
      TotaisPedido totais =
          await TotaisPedido.getTotaisPedido(widget.visita.id) as TotaisPedido;

      if (totais.idFormaPagamento == null && !appAmbiente.usarFormaPagamento) {
        setFormaPagamento(widget.visita.id, appAmbiente.formaPagamentoPadrao);
        totais = await TotaisPedido.getTotaisPedido(widget.visita.id)
            as TotaisPedido;
      }

      final maps = await DatabaseAmbiente.select('TB_VENDEDOR',
          where: 'ID = ?', whereArgs: [appUser.vendedorAtual]);

      if(maps.isNotEmpty){
        descontoMax = maps[0]['DESCONTO_MAXIMO'];
      }

      return totais;
    }

    // obsNf.text = totais.obsNF;
    // _conDescPct.text = _descontoPct();
    // _conDescValor.text = totais.descontoValor.toStringAsFixed(2);

    ///TODO: REMOVER CHAMADA DE DATABASE EM TELA
    // final maps = await DatabaseAmbiente.select('TB_VENDEDOR',
    //     where: 'ID = ?', whereArgs: [appUser.vendedorAtual]);
    // if (totais.idFormaPagamento != null) {
    //   formaPagamento = FormaPagamento(totais.idFormaPagamento!);
    // }
    // // descontoMax = maps[0]['DESCONTO_MAXIMO'];

    return FutureBuilder(
      future: setup(),
      builder: (BuildContext context, AsyncSnapshot<TotaisPedido> snapshot) {
        if (snapshot.data == null) {
          if (snapshot.hasError) {
            printDebug(snapshot.error.toString());
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return _FormTotais(
          totais: snapshot.data!,
          visita: widget.visita,
          descontoMax: descontoMax,
          onUpdate: widget.onUpdate,
        );
      },
    );
  }
}

class FormaPagamento {
  final int id;
  final String? nome;

  FormaPagamento(this.id, {this.nome});
}

class _FormTotais extends StatefulWidget {
  const _FormTotais(
      {Key? key,
      required this.totais,
      required this.visita,
      required this.descontoMax,
      required this.onUpdate})
      : super(key: key);

  final TotaisPedido totais;
  final Visita visita;
  final double descontoMax;
  final Function onUpdate;

  @override
  State<_FormTotais> createState() => _FormTotaisState();
}

class _FormTotaisState extends State<_FormTotais> {
  FormaPagamento? formaPagamento;

  TextEditingController obsNf = TextEditingController();

  final _conDescPct = TextEditingController();
  final _conDescValor = TextEditingController();

  bool toLoad = false;

  double _desconto() {
    double x = 1 -
        ((widget.totais.totalBruto - widget.totais.descontoValor) /
            widget.totais.totalBruto);

    x = arredondaFracao(x);

    return x;
  }

  String _descontoPct() {
    return arredondaPorcentagem(_desconto() * 100).toString();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (!toLoad) {
      toLoad = true;
      return;
    }

    // if (totais.idFormaPagamento != null) {
    //   formaPagamento = FormaPagamento(totais.idFormaPagamento!);
    // }
    //
  }

  @override
  Widget build(BuildContext context) {
    final appAmbiente = AppAmbiente.of(context);
    final appUser = AppUser.of(context);

    obsNf.text = widget.totais.obsNF;

    _conDescPct.text = _descontoPct();
    _conDescValor.text =
        arredondarValor(widget.totais.descontoValor).toString();

    if (!appAmbiente.usarFormaPagamento) {
      formaPagamento = FormaPagamento(appAmbiente.formaPagamentoPadrao);
    }

    FocusNode nodeLoseFocous = FocusNode();

    saveTotais() async {
      widget.totais.obsNF = obsNf.text;

      if (widget.totais.obsNF.isEmpty) {
        widget.totais.obsNF = ' ';
      }

      if (formaPagamento != null) {
        widget.totais.idFormaPagamento = formaPagamento!.id;
      }

      widget.totais.idVendedor = appUser.vendedorAtual;

      await widget.totais.salvar().then((value) {
        if (appAmbiente.usarDescontoItem) {
          return;
        }

        widget.totais.updateDescontoProduto();
      });

      toLoad = false;

      detalhesKey.currentState!.setState(() {});

      widget.onUpdate();
    }

    nodeLoseFocous.addListener(() {
      if (!nodeLoseFocous.hasFocus) {
        saveTotais();
      }
    });

    return Card(
      child: ListViewNested(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListViewNested(
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const TextTitle('Forma de Pagamento'),
                  DropdownSaved(
                    DropdownSaved.formaPagamento,
                    where: 'USA_MOBILE = ?',
                    whereArgs: [1],
                    editable: appAmbiente.usarFormaPagamento &&
                        !widget.visita.viewOnly(),
                    onChange: (item) {
                      update() {
                        if (item != null) {
                          formaPagamento = FormaPagamento(item);
                        }

                        saveTotais();
                      }

                      if (!widget.visita.viewOnly()) update();
                    },
                    startValue: widget.totais.idFormaPagamento,
                  ),
                  if (appAmbiente.usarBotaoComNota && !widget.visita.viewOnly())
                    FormSwitchButton(
                      title: 'Com nota fiscal: ',
                      startValue: widget.totais.comNota,
                      onChange: (b) {
                        widget.totais.comNota = b;

                        saveTotais();
                      },
                    ),
                ]),
                const TextTitle('Observação'),
                TextFormField(
                  enabled: !widget.visita.viewOnly(),
                  controller: obsNf,
                  onChanged: (x) {
                    if (!widget.visita.viewOnly()) saveTotais();
                  },
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
                              _conDescPct.text = _descontoPct();
                              saveTotais();
                            }
                          },
                          child: TextFormField(
                            controller: _conDescPct,
                            readOnly: widget.visita.viewOnly(),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                            ),
                            style: const TextStyle(fontSize: 22),
                            onTap: () => _conDescPct.selection = TextSelection(
                                baseOffset: 0,
                                extentOffset: _conDescPct.value.text.length),
                            onChanged: (text) {
                              double x =
                                  double.parse(text.isEmpty ? '0' : text) /
                                      100.0;

                              x = arredondaFracao(x);

                              double desconto =
                                  arredondarValor(widget.totais.totalBruto * x);
                              //
                              _conDescValor.text = desconto.toString();

                              widget.totais.descontoValor = desconto;
                              saveTotais();
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            // autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              double x = double.parse(_conDescPct.text.isEmpty
                                      ? '0'
                                      : _conDescPct.text) /
                                  100.0;
                              // printDebug("${x} > $descontoMax");
                              if (!appAmbiente.usarDescontoMax) {
                                return null;
                              }
                              // if (widget.descontoMax == null) {
                              //   return "Aguarde o calculo de desconto";
                              // }

                              if (x > widget.descontoMax) {
                                return "Desconto Acima do limite";
                              }
                            },
                            inputFormatters: [
                              // FilteringTextInputFormatter.digitsOnly,
                              FilteringTextInputFormatter(RegExp(r'[\d.]+'),
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
                          _conDescValor.text =
                              arredondarValor(widget.totais.descontoValor)
                                  .toString();
                          saveTotais();
                        },
                        child: TextFormField(
                          readOnly: widget.visita.viewOnly(),
                          controller: _conDescValor,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                          ),
                          style: const TextStyle(fontSize: 22),
                          onTap: () => _conDescValor.selection = TextSelection(
                              baseOffset: 0,
                              extentOffset: _conDescValor.value.text.length),
                          onChanged: (text) {
                            var x = double.parse(
                                _conDescValor.text.isEmpty ? '0' : text);

                            widget.totais.descontoValor = arredondarValor(x);
                            _conDescPct.text = _descontoPct();

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

                _Detalhes(
                  // key: detalhesKey,
                  totais: widget.totais,
                  visita: widget.visita,
                ),
                // TileSpacedText('Desconto maximo:',
                //     "${arredondaPorcentagem(widget.descontoMax * 100)}%"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  final detalhesKey = GlobalKey();
}

class _Detalhes extends StatefulWidget {
  const _Detalhes({
    Key? key,
    required this.totais,
    required this.visita,
  }) : super(key: key);

  final TotaisPedido totais;
  final Visita visita;

  @override
  State<_Detalhes> createState() => _DetalhesState();
}

class _DetalhesState extends State<_Detalhes> {
  @override
  Widget build(BuildContext context) {
    final appAmbiente = AppAmbiente.of(context);

    double _getTotalLiquido() {
      return widget.totais.totalBruto - widget.totais.descontoValor;
    }

    double _getTotalBruto() {
      return widget.totais.totalBruto;
    }

    double _getTotalDesconto() {
      return widget.totais.totalDesconto;
    }

    return ListViewNested(children: [
      // if (appAmbiente.usarAssinatura)
      //   const TileText(
      //     title: 'Assinatura',
      //     value: 'Not Implemented',
      //   ),
      if (widget.visita.limiteCredito != null)
        ListViewNested(children: [
          if (_getTotalLiquido() > widget.visita.limiteCredito!)
            const TextNormal('Pedido acima do limite de crédido'),
          TileSpacedText('Limite de Crédido:',
              TextDinheiroReal.format(widget.visita.limiteCredito!)),
        ]),
      if (widget.visita.titulosVencendo != null)
        TileSpacedText('Títulos a vencer:',
            TextDinheiroReal.format(widget.visita.titulosVencendo!)),
      const TileTopico('Produtos'),
      TileSpacedText('Total de Itens:', widget.totais.itens.toString()),
      TileSpacedText(
          'Total em Quantidade:', widget.totais.quantidade.toString()),
      const TileTopico('Totais'),
      TileSpacedText('Total Bruto:', TextDinheiroReal.format(_getTotalBruto())),
      TileSpacedText(
          'Total Desconto:', TextDinheiroReal.format(_getTotalDesconto())),
      TileSpacedText(
          'Total Liquido:', TextDinheiroReal.format(_getTotalLiquido())),
      const SizedBox(
        height: 12,
      ),
    ]);
  }
}

Future<void> setFormaPagamento(final int idVisita, final int idForma) async {
  try {
    final db = await DatabaseAmbiente.getDatabase();
    await db.insert(
      'TB_VISITA_TOTAIS',
      {'ID_VISITA': idVisita, 'ID_FORMA_PAGAMENTO': idForma},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  } catch (e) {
    printDebug(e.toString());
  }
}
