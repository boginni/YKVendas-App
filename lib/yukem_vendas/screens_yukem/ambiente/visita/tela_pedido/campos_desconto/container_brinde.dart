import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forca_de_vendas/api/common/components/list_scrollable.dart';
import 'package:forca_de_vendas/yukem_vendas/models/database_objects/item_visita.dart';

import '../../../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../../../api/common/form_field/formulario.dart';
import '../../../../../../api/models/configuracao/app_system.dart';
import '../../../../../models/configuracao/app_ambiente.dart';

class ContainerBrinde extends StatefulWidget {
  final ProdutoItemVisita item;

  final Function callBack;

  const ContainerBrinde({Key? key, required this.item, required this.callBack})
      : super(key: key);

  @override
  State<ContainerBrinde> createState() => _ContainerBrindeState();
}

class _ContainerBrindeState extends State<ContainerBrinde> {
  final controller = TextEditingController();

  @override
  void initState() {
    // controller.text = widget.item.quantidadeBrinde.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final appAmbiente = AppAmbiente.of(context);
    final appSystem = AppSystem.of(context);

    return ListViewNested(
      children: [
        // FormSwitchButton(
        //     title: 'Brinde',
        //     startValue: widget.item.brinde,
        //     onChange: (b) {
        //       widget.item.brinde = b;
        //
        //       if (!b) {
        //         widget.item.apenasBride = false;
        //         widget.callBack();
        //         return;
        //       }
        //
        //       setState(() {});
        //     }),
        //
        // if (widget.item.brinde)
        //   ListViewNested(children: [
        //     FormSwitchButton(
        //         title: 'Apenas Brinde',
        //         startValue: widget.item.apenasBride,
        //         onChange: (b) {
        //           widget.item.apenasBride = b;
        //
        //           widget.callBack();
        //         }),
        //     const TextTitle("Quantidade"),
        //     TextFormField(
        //       controller: controller,
        //       keyboardType: TextInputType.number,
        //       decoration: const InputDecoration(
        //         fillColor: Colors.white,
        //         filled: true,
        //       ),
        //       // onTap: () => controllerQtd.selection = TextSelection(
        //       //     baseOffset: 0, extentOffset: controllerQtd.value.text.length),
        //       style: textNormalStyle(appSystem),
        //
        //       autovalidateMode: AutovalidateMode.onUserInteraction,
        //       onChanged: (text) {
        //         // updateQuantidade(text);
        //         // update(qtd: true);
        //       },
        //       validator: (value) {
        //         double x = widget.item.quantidade;
        //
        //         if (value!.isEmpty || x <= 0) {
        //           return 'Informe a quantidade';
        //         }
        //
        //         if (widget.item.estoque != null &&
        //             appAmbiente.calcularEstoque &&
        //             x > widget.item.estoque!) {
        //           return 'Valor informado excede o limite do estoque!';
        //         }
        //
        //         return null;
        //       },
        //
        //       // inputFormatters: [
        //       //   FilteringTextInputFormatter(RegExp(r'[\d]+'),
        //       //       allow: true),
        //       // ]
        //     ),
        //   ])
      ],
    );
  }
}
