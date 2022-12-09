import 'package:flutter/material.dart';

import '../../../../../api/common/components/list_scrollable.dart';
import '../../../../../api/common/components/mostrar_confirmacao.dart';
import '../../../../../api/common/custom_tiles/default_tiles/tile_text.dart';
import '../../../../../api/common/custom_widgets/custom_buttons.dart';
import '../../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../../api/common/custom_widgets/floating_bar.dart';
import '../../../../../api/common/form_field/database_fields.dart';
import '../../../../models/configuracao/app_ambiente.dart';
import '../../../../models/database_objects/cancelamento_visita.dart';
import '../../../../models/database_objects/visita.dart';
class TelaVisitaRealizada extends StatelessWidget {
  const TelaVisitaRealizada({Key? key}) : super(key: key);

  static const routeName = '/visitaRealizada';

  @override
  Widget build(BuildContext context) {
    int idVisita = ModalRoute.of(context)!.settings.arguments as int;

    return FutureBuilder(
      future: CancelamentoVisita.getCancelamentoVisita(idVisita),
      builder:
          (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        CancelamentoVisita cancelamentoVisita = snapshot.data == null
            ? CancelamentoVisita(idVisita: idVisita)
            : snapshot.data!;

        return _Form(cancelamentoVisita);
      },
    );
  }
}

class _Form extends StatefulWidget {
  final CancelamentoVisita cancelamentoVisita;

  const _Form(this.cancelamentoVisita);

  @override
  State<StatefulWidget> createState() => _FormState();
}

class _FormState extends State<_Form> {
  final obs = TextEditingController();

  @override
  Widget build(BuildContext context) {

    final appAmbiente = AppAmbiente.of(context);

    obs.text = widget.cancelamentoVisita.observacao;

    salvar() async {
      bool result = await mostrarCaixaConfirmacao(context,
          content: 'Não irreversível, deseja continuar?');
      if (result) {
        await widget.cancelamentoVisita.salvar();
        Navigator.of(context).pop(true);
      }
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
              enabled: widget.cancelamentoVisita.idMotivo != null,
              onPressed: salvar)
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
                          widget.cancelamentoVisita.idMotivo = i;
                        });
                      },
                      value: widget.cancelamentoVisita.idMotivo,
                    ),
                    const TextTitle('Observação'),
                    TextFormField(
                      controller: obs,
                      onChanged: (text) {
                        widget.cancelamentoVisita.observacao = obs.text;
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
