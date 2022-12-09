import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../../api/common/components/list_scrollable.dart';
import '../../../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../../../api/models/configuracao/app_system.dart';
import '../../../../../models/configuracao/app_ambiente.dart';
import '../../../../../models/database_objects/item_visita.dart';

class CampoValorUnd extends StatefulWidget {
  const CampoValorUnd({Key? key, required this.onChanged, required this.item})
      : super(key: key);

  final Function(double x) onChanged;
  final ProdutoItemVisita item;

  @override
  State<StatefulWidget> createState() => CampoValorUndState();
}

class CampoValorUndState extends State<CampoValorUnd> {
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  initValorUnt() {
    late double valor;
    widget.item.valorUnitario = widget.item.getPrecoPadrao();
    valor = widget.item.valorUnitario!;
    controller.text = valor.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final appAmbiente = AppAmbiente.of(context);
    final appSystem = AppSystem.of(context);

    initValorUnt();

    return ListViewNested(children: [
      const TextTitle("Valor Unitário"),
      if ((double.tryParse(controller.text) ?? 0.0) <= 0.0)
        Text(
          'Não é possível fazer venda com valor unitário menor ou igual a 0',
          style: textNormalStyle(appSystem, color: Colors.red),
        ),
      TextFormField(
        readOnly: !(appAmbiente.alterarPrecoUndBaixo || appAmbiente.alterarPrecoUndCima),

        controller: controller,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onTap: () => controller.selection = TextSelection(
            baseOffset: 0, extentOffset: controller.value.text.length),
        keyboardType: TextInputType.number,
        // decoration: const InputDecoration(
        //   fillColor: Colors.white,
        //   filled: true,
        // ),
        style: textNormalStyle(appSystem),
        onChanged: (text) {
          double? x = double.tryParse(text);

          if(x != null){
            widget.onChanged(x);
          }

        },
        validator: (value) {


          late double x;

          try {
            x = double.parse(value ?? '');
          } catch(e){
            return 'Valor inválido';
          }


          if (!appAmbiente.alterarPrecoUndBaixo && x < widget.item.getPrecoTabela()) {
            return 'Não é permitido abaixar o preço unitário';
          }

          if (!appAmbiente.alterarPrecoUndCima &&
              x > widget.item.getPrecoTabela()) {
            return 'Não é permitido aumentar o preço unitário';
          }

        },
        inputFormatters: [
          FilteringTextInputFormatter(RegExp(r'[\d.]+'), allow: true),
        ],
      ),
    ]);
  }
}
