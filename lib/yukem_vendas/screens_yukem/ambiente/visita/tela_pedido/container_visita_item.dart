import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forca_de_vendas/api/common/components/list_scrollable.dart';
import 'package:forca_de_vendas/api/common/form_field/formulario.dart';
import 'package:forca_de_vendas/api/common/formatter/arredondamento.dart';
import 'package:forca_de_vendas/yukem_vendas/models/database_objects/item_visita.dart';

import '../../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../../api/common/debugger.dart';
import '../../../../../api/models/configuracao/app_system.dart';
import '../../../../models/configuracao/app_ambiente.dart';
import '../../../../models/configuracao/app_user.dart';
import 'campos_desconto/desconto_pct.dart';
import 'campos_desconto/desconto_valor.dart';
import 'campos_desconto/valor_und.dart';
import 'container_detalhes.dart';
import 'container_pedido.dart';

class ContainerVisitaItem extends StatefulWidget {
  const ContainerVisitaItem({Key? key, required this.item}) : super(key: key);

  final ProdutoItemVisita item;

  @override
  State<ContainerVisitaItem> createState() => _ContainerVisitaItemState();
}

class _ContainerVisitaItemState extends State<ContainerVisitaItem> {
  final controllerQtd = TextEditingController();

  final keyDescValor = GlobalKey<CampoDescontoValorState>();
  final keyDescPct = GlobalKey<CampoDescontoPorcentagemState>();
  final keyDetalhes = GlobalKey<ContainerDetalhesVisitaItemState>();
  final keyPedido = GlobalKey<ContainerPedidoState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controllerQtd.text = widget.item.quantidade.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final appAmbiente = AppAmbiente.of(context);
    final appUser = AppUser.of(context);
    final appSystem = AppSystem.of(context);

    update() {
      setState(() {});
      if(keyDescValor.currentState != null){
        keyDescValor.currentState!.updateValor();
      }
    }

    liteUpdate() {
      widget.item.setDesconto(widget.item.descontoPct ?? 0);

      keyDescPct.currentState!.updatePct();
      keyDescValor.currentState!.updateValor();
      keyDetalhes.currentState!.setState(() {});
      keyPedido.currentState!.setState(() {});
    }

    updateQuantidade(text) {
      int? x = int.tryParse(text);

      if (x != null) {
        widget.item.quantidade = x.toDouble();
      } else {
        widget.item.quantidade = 0;
      }

      widget.item.setDesconto(widget.item.descontoPct ?? 0);
      double? precoQtd = widget.item.getPrecoQtd();

      if (precoQtd != null) {
        widget.item.valorUnitario = precoQtd;
      }

      update();
    }

    return ListViewNested(children: [
      ContainerPedido(
        key: keyPedido,
        item: widget.item,
      ),
      if (appAmbiente.usarBrinde)
        FormSwitchButton(
            title: 'Brinde',
            startValue: widget.item.brinde,
            onChange: (b) {
              widget.item.brinde = b;
              setState(() {});
            }),
      const TextTitle("Quantidade"),
      TextFormField(
        controller: controllerQtd,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          fillColor: Colors.white,
          filled: true,
        ),
        onTap: () => controllerQtd.selection = TextSelection(
            baseOffset: 0, extentOffset: controllerQtd.value.text.length),
        style: textNormalStyle(appSystem),

        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: (text) {
          updateQuantidade(text);
          // update(qtd: true);
        },
        validator: (value) {
          double x = widget.item.getQuantidadeProdutoAtual();

          if (value!.isEmpty || x <= 0) {
            return 'Informe a quantidade';
          }

          if (widget.item.estoque != null &&
              appAmbiente.calcularEstoque &&
              x > widget.item.estoque! &&
              !(widget.item.faturamento &&
                  appAmbiente.usarFaturamentoComoOrcamento &&
                  appAmbiente.adicionarProdutoNegativoOrcamento)) {
            return 'Valor informado excede o limite do estoque!';
          }

          if (widget.item.getTotalDescontoPctPedido() >
                  widget.item.descontoMaxProduto &&
              !appAmbiente.usarDescontoVendedorItem &&
              appAmbiente.usarDescontoMax) {
            return 'Adicionar esse item fará ultrapassar o desconto Máximo';
          }

          if (widget.item.getTotalDescontoPctPedido() >
                  widget.item.descontoMaxVendedor &&
              appAmbiente.usarDescontoVendedorItem &&
              appAmbiente.usarDescontoMax) {
            return 'Adicionar esse item fará ultrapassar o desconto Máximo';
          }

          return null;
        },

        // inputFormatters: [
        //   FilteringTextInputFormatter(RegExp(r'[\d]+'),
        //       allow: true),
        // ]
      ),
      if (!widget.item.brinde)
        ListViewNested(children: [
          //
          // ================ PRECO UNITÁRIO
          CampoValorUnd(
            onChanged: (x) {
              widget.item.valorUnitario = x;

              liteUpdate();
            },
            item: widget.item,
          ),

          // ================ DESCONTO EM PORCENTAGEM
          if (appAmbiente.usarDescontoBaixo && appAmbiente.usarDescontoItem)
            CampoDescontoPorcentagem(
              key: keyDescPct,
              item: widget.item,
              enabled: appAmbiente.descontoPct,
              onLoseFocus: () {
                // widget
                // widget.item.descontoPct =
                //     arredondaPorcentagem(widget.item.descontoPct ?? 0);
                widget.item.recalcDesconto();
                keyDescPct.currentState!.updatePct();
              },
              onChanged: (String? text) {
                try {
                  double pct = double.parse(text!);
                  pct = arredondaPorcentagem(pct);
                  widget.item.setDesconto(pct / 100.0);
                  keyDescValor.currentState!.updateValor();
                  keyPedido.currentState!.setState(() {});
                  updateDetalhes();
                  // setState(() {});
                } catch (e) {}
              },
              validator: () {
                // if (getProduto().getTotalLiquido() <= 0) {
                //   return "Desconto Inválido";
                // }

                // if (getProduto().getDescontoPorcentagem() >
                //     getProduto().descontoMaximo) {
                //   return "Desconto maior que o limite permitido!";
                // }

                return null;
              },
            ),

          // ================ DESCONTO EM VALOR
          if (appAmbiente.usarDescontoBaixo && appAmbiente.usarDescontoItem)
            CampoDescontoValor(
              key: keyDescValor,
              item: widget.item,
              enabled: appAmbiente.descontoValor,
              onLoseFocus: () {
                keyDescValor.currentState!.updateValor();
              },
              onChanged: (text) {
                double x = double.tryParse(text ?? '') ?? 0;

                x = arredondarValor(x);

                widget.item.descontoValor = x;
                printDebug( widget.item.descontoValor.toString());

                widget.item.recalcDesconto();
                keyDescPct.currentState!.updatePct();
                keyPedido.currentState!.setState(() {});
                updateDetalhes();
              },
              validator: (value) {
                // if (value!.isEmpty) {
                //   //   return 'Não pode ser vazio';
                //   // }
                //   if (getProduto().getTotalLiquido() <= 0) {
                //     return "Desconto Inválido";
                //   }
                //   if (getProduto().getDescontoPorcentagem() >
                //       getProduto().descontoMaximo) {
                //     return "Desconto maior que o limite permitido!";
                //   }
                //   return null;
                // }
              },
            ),

          ContainerDetalhesVisitaItem(
            key: keyDetalhes,
            item: widget.item,
          )
        ]),
    ]);
  }

  void updateDetalhes() {
    keyDetalhes.currentState!.setState(() {});
  }
}
