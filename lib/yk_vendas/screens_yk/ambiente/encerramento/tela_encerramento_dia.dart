import 'package:flutter/material.dart';

import '../../../../api/common/components/barra_progresso.dart';
import '../../../../api/common/components/list_scrollable.dart';
import '../../../../api/common/components/mostrar_confirmacao.dart';
import '../../../../api/common/custom_tiles/default_tiles/tile_text.dart';
import '../../../../api/common/custom_widgets/custom_buttons.dart';
import '../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../api/common/custom_widgets/floating_bar.dart';
import '../../../../api/common/form_field/database_fields.dart';
import '../../../models/configuracao/app_ambiente.dart';
import '../../../models/database_objects/cancelamento_visita.dart';
import '../../../models/database_objects/visita.dart';

class TelaEncarramentoDia extends StatefulWidget {
  const TelaEncarramentoDia({Key? key}) : super(key: key);

  static const String routeName = 'encerramento';

  @override
  State<TelaEncarramentoDia> createState() => _TelaEncarramentoDiaState();
}

class _TelaEncarramentoDiaState extends State<TelaEncarramentoDia> {
  final obs = TextEditingController();
  late CancelamentoVisita cancelamentoVisita;

  @override
  void initState() {
    // TODO: implement initState
    cancelamentoVisita = CancelamentoVisita(idVisita: 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final visitas =
        ModalRoute.of(context)!.settings.arguments as Map<int, Visita>;
    final appAmbiente = AppAmbiente.of(context);

    // obs.text = widget.cancelamentoVisita.observacao;

    salvar() async {
      await mostrarCaixaConfirmacao(context,
              title: 'Cancelar Visitas',
              content: 'Isso é irreversível, deseja mesmo continuar?')
          .then((value) async {
        if (value) {
          final key = await mostrarBarraProgressoCircular(context);

          CancelamentoVisita.insertCancelamentos(visitas, cancelamentoVisita)
              .then((value) {
            key.currentState!.finish();
            Navigator.of(context).pop(true);
          });
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visita Realizada'),
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
      ),
      body: BodyFloatingBar(
        barChildrens: [
          ButtonSalvar(
              enabled: cancelamentoVisita.idMotivo != null, onPressed: salvar)
        ],
        child: ListView(
          children: [
            Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListViewNested(
                  children: <Widget>[
                    const TextTitle('Motivo do Cancelamento da Visita'),
                    DropdownSaved(
                      DropdownSaved.motivoCancelamento,
                      onChange: (i) {
                        setState(() {
                          cancelamentoVisita.idMotivo = i;
                        });
                      },
                      value: cancelamentoVisita.idMotivo,
                    ),
                    const TextTitle('Observação'),
                    TextFormField(
                      controller: obs,
                      onChanged: (text) {
                        cancelamentoVisita.observacao = obs.text;
                      },
                    ),
                    if (appAmbiente.usarFotoVisitaRealisada)
                      const TileText(
                        title: 'Foto',
                        value: 'Não implementado',
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
