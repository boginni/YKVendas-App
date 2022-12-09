import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../../api/common/components/list_scrollable.dart';
import '../../../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../../../api/common/formatter/arredondamento.dart';
import '../../../../../../api/models/configuracao/app_system.dart';
import '../../../../../models/database_objects/item_visita.dart';

class CampoDescontoValor extends StatefulWidget {
  const CampoDescontoValor(
      {Key? key,
      required this.onChanged,
      required this.item,
      required this.validator,
      required this.enabled,
      required this.onLoseFocus})
      : super(key: key);

  final Function(String? x) onChanged;
  final ProdutoItemVisita item;
  final Function(String? value) validator;
  final bool enabled;

  final Function() onLoseFocus;

  @override
  State<StatefulWidget> createState() => CampoDescontoValorState();
}

class CampoDescontoValorState extends State<CampoDescontoValor> {
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    updateValor();
  }

  updateValor() {
    controller.text = arredondarValorStr(widget.item.descontoValor);
  }

  @override
  Widget build(BuildContext context) {
    final appSystem = AppSystem.of(context);
    return ListViewNested(children: [
      const TextTitle("Desconto R\$"),
      Focus(
        onFocusChange: (hasFocous) {
          if (!hasFocous) {
            widget.onLoseFocus();
          }
        },
        child: TextFormField(
          readOnly: !widget.enabled,
          controller: controller,
          autovalidateMode: AutovalidateMode.always,
          onTap: () => controller.selection = TextSelection(
              baseOffset: 0, extentOffset: controller.value.text.length),
          keyboardType: TextInputType.number,
          // decoration: const InputDecoration(
          //   fillColor: Colors.white,
          //   filled: true,
          // ),
          style: textNormalStyle(appSystem),

          onChanged: (x) {

            widget.onChanged(x);
          },

          validator: (String? value) {
            widget.validator(value);
            return null;
          },

          // validator: (value) {
          //   // if (value!.isEmpty) {
          //   //   return 'Não pode ser vazio';
          //   // }
          //
          //   if (getProduto().getTotalLiquido() <= 0) {
          //     return "Desconto Inválido";
          //   }
          //
          //   if (getProduto().getDescontoPorcentagem() >
          //       getProduto().descontoMaximo) {
          //     return "Desconto maior que o limite permitido!";
          //   }
          //
          //   return null;
          // },
          inputFormatters: [
            FilteringTextInputFormatter(RegExp(r'[\d.]+'), allow: true),
          ],
        ),
      ),
    ]);
  }
}
