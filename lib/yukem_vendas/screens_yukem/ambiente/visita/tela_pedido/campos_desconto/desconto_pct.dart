import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../../api/common/components/list_scrollable.dart';
import '../../../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../../../api/models/configuracao/app_system.dart';
import '../../../../../models/configuracao/app_ambiente.dart';
import '../../../../../models/database_objects/item_visita.dart';

class CampoDescontoPorcentagem extends StatefulWidget {
  final bool enabled;

  const CampoDescontoPorcentagem(
      {Key? key,
      required this.onChanged,
      required this.item,
      required this.validator,
      required this.enabled, required this.onLoseFocus})
      : super(key: key);

  final Function(String? text) onChanged;
  final ProdutoItemVisita item;
  final Function validator;
  final Function() onLoseFocus;

  @override
  State<StatefulWidget> createState() => CampoDescontoPorcentagemState();
}

class CampoDescontoPorcentagemState extends State<CampoDescontoPorcentagem> {
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    updatePct();
  }

  void updatePct() {
    double x = (widget.item.descontoPct ?? 0) * 100;
    controller.text = x.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final appAmbiente = AppAmbiente.of(context);
    final appSystem = AppSystem.of(context);


    return ListViewNested(children: [
      const TextTitle("Desconto %"),
      Focus(
        onFocusChange: (hasFocous) {
          if (!hasFocous) {
            updatePct();
            widget.onLoseFocus();
          }
        },
        child: TextFormField(
          readOnly: !widget.enabled,
          autovalidateMode: AutovalidateMode.always,
          controller: controller,
          keyboardType: TextInputType.number,
          onTap: () => controller.selection = TextSelection(
              baseOffset: 0, extentOffset: controller.value.text.length),
          // decoration: const InputDecoration(
          //   fillColor: Colors.white,
          //   filled: true,
          // ),
          style: textNormalStyle(appSystem),
          onChanged: (x) {
            widget.onChanged(x);
          },

          // onChanged: (text) {
          //   double x = parse(controllerDescPorcentagem);
          //
          //   double val = getProduto().getTotalBruto() *
          //   (x / 100.0);
          //
          //   controllerDescValor.text = val.toStringAsFixed(2);
          //
          //   update(pct: false);
          // },

          validator: (text) {
            widget.validator();

            double x = double.tryParse(text ?? '') ?? 0;

            if (text == null || text.isEmpty) {
              return 'Informe o Valor';
            }

            if (widget.item.getTotalLiquido() <= 0) {
              return "Desconto Inválido!";
            }

            if ((widget.item.descontoPct ?? 0) > widget.item.descontoMaxProduto &&
                !appAmbiente.usarDescontoVendedorItem) {
              return "Desconto maior que o limite por produto!";
            }

            if ((widget.item.descontoPct ?? 0) >
                    widget.item.descontoMaxVendedor &&
                appAmbiente.usarDescontoVendedorItem) {
              return "Desconto maior que o limite por vendedor!";
            }

            // printDebug('error');
          },

          // validator: (value) {
          //   if (getProduto().getTotalLiquido() <= 0) {
          //     return "Desconto Inválido";
          //   }
          //
          //   if (getProduto().getDescontoPorcentagem() > getProduto().descontoMaximo) {
          //     return "Desconto maior que o limite permitido!";
          //   }
          //   return null;
          // },

          inputFormatters: [
            // FilteringTextInputFormatter.digitsOnly,
            FilteringTextInputFormatter(RegExp(r'[\d.]+'), allow: true),
          ],
        ),
      ),
    ]);
  }
}
