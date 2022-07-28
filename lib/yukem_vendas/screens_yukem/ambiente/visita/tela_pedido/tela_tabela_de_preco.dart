import 'package:flutter/material.dart';

import '../../../../../api/common/custom_widgets/custom_buttons.dart';
import '../../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../../api/common/custom_widgets/floating_bar.dart';
import '../../../../../api/common/form_field/database_fields.dart';
import '../../../../models/database_objects/tabela_precos.dart';

class TelaTabelaPreco extends StatefulWidget {
  static const routeName = '/telaTabelaPreco';

  const TelaTabelaPreco({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => TelaTabelaPrecoState();
}

class TelaTabelaPrecoState extends State<TelaTabelaPreco> {
  TabelaPreco? tabela;

  @override
  Widget build(BuildContext context) {
    final int idVisita = ModalRoute.of(context)!.settings.arguments as int;

    saveTabela() async {
      await TabelaPreco.insertTabelaPreco(idVisita, tabela!.id);
      Navigator.of(context).pop(context);
    }

    setTabela(int? idTabela) async {
      if (idTabela == null) {
        return;
      }

      setState(() {
        tabela = TabelaPreco(idTabela);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabela de Preço'),
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pop(context);
          },
        ),
      ),
      body: FutureBuilder(
        future: TabelaPreco.getTabelaPreco(idVisita),
        builder: (BuildContext context, AsyncSnapshot<TabelaPreco?> snapshot) {
          tabela ??= snapshot.data;

          return BodyFloatingBar(
            barChildrens: [
              ButtonSalvar(enabled: tabela != null, onPressed: saveTabela)
            ],
            child: ListView(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 2.0),
                    child: Column(
                      children: [
                        const TextTitle('Selecione uma Tabela'),
                        DropdownSaved(
                          DropdownSaved.tabelaPreco,
                          startValue: tabela == null ? null : tabela!.id,
                          onChange: (i) => setTabela(i),
                          hint: 'Selecione uma Tabela',
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
