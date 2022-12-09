import 'package:flutter/material.dart';

import '../../../../../api/common/components/list_scrollable.dart';
import '../../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../../api/common/form_field/formulario.dart';
import '../../../../models/database_objects/dados_entrega.dart';

class ContainerDadosEntrega extends StatefulWidget {
  static const routeName = '/TelaDadosEntrega';

  final int idVisita;
  final Function() onUpdate;

  final DadosEntrega? dados;

  const ContainerDadosEntrega({
    Key? key,
    required this.idVisita,
    required this.onUpdate,
    required this.dados,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ContainerDadosEntregaState();
}



class _ContainerDadosEntregaState extends State<ContainerDadosEntrega> {
  DateTime? dataEntrega;
  bool restricao = false;
  final obsController = TextEditingController();
  final descController = TextEditingController();
  bool toLoad = true;

  @override
  Widget build(BuildContext context) {
    if (widget.dados != null) {
      dataEntrega = widget.dados!.data;
      restricao = widget.dados!.restricao;
      obsController.text = widget.dados!.obs;
      descController.text = widget.dados!.detalheRestricao;
    }

    update() {
      widget.onUpdate();
    }


    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListViewNested(
          children: <Widget>[
            const TextTitle('Data de Entrega'),
            FormDatePicker(
              lastDate: DateTime.now().add(const Duration(days: 360)),
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              startingDate: dataEntrega,
              then: (DateTime? date) {
                dataEntrega = date;
                widget.dados!.data = dataEntrega;
                update();
              },
            ),
            FormSwitchButton(
              title: 'Restrição de Horário: ',
              startValue: restricao,
              onChange: (b) {
                restricao = b;

                if (widget.dados != null) {
                  widget.dados!.restricao = b;
                }

                setState(() {});
              },
            ),
            if (restricao) const TextTitle('Descrição da Restrição'),
            if (restricao)
              TextFormField(
                controller: descController,
                onChanged: (txt) {
                  if (widget.dados != null) {
                    widget.dados!.detalheRestricao = txt;
                  }
                },
              ),
            const TextTitle('Observações'),
            TextFormField(
              controller: obsController,
              onChanged: (txt) {
                if (widget.dados != null) {
                  widget.dados!.obs = txt;
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
