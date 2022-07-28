import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:forca_de_vendas/api/common/custom_widgets/custom_icons.dart';
import 'package:forca_de_vendas/yukem_vendas/models/configuracao/app_ambiente.dart';
import 'package:forca_de_vendas/yukem_vendas/models/database/database_ambiente.dart';

import '../../../../../api/common/components/list_scrollable.dart';
import '../../../../../api/common/components/mostrar_confirmacao.dart';
import '../../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../../api/common/form_field/database_fields.dart';
import '../../../../models/database_objects/tabela_precos.dart';

class ContainerTabelaPrecos extends StatefulWidget {
  final int idVisita;

  final Function(int? i) onChange;

  const ContainerTabelaPrecos({
    Key? key,
    required this.idVisita,
    required this.onChange,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ContainerTabelaPrecosState();
}

class ContainerTabelaPrecosState extends State<ContainerTabelaPrecos> {
  int? idTabela;

  @override
  Widget build(BuildContext context) {
    final appAmbiente = AppAmbiente.of(context);

    setTabela(int? idTabela) async {
      setState(() {});

      savar() {
        TabelaPreco.insertTabelaPreco(widget.idVisita, idTabela);

        this.idTabela = idTabela;

        widget.onChange(idTabela);

        setState(() {});
      }

      DatabaseAmbiente.select('VW_VISITA_INFO_ITENS',
          where: 'ID_VISITA = ?', whereArgs: [widget.idVisita]).then((value) {
        if (value.isNotEmpty && (value[0]['PRODUTOS'] ?? 0) > 0) {
          mostrarCaixaConfirmacao(context,
                  title: 'Altrar Tabela de preços?',
                  content: "Todos os produtos serao removidos")
              .then((value) {
            if (value) {
              savar();
            }
          });
        } else {
          savar();
        }
      });
    }

    // printDebug("idtablea = $idTabela");
    return Card(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24, top: 4, right: 8, left: 8),
        child: ListViewNested(
          children: [
            const TextTitle('Tabela de Preços'),
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: FutureBuilder(
                    future: TabelaPreco.getIdTabela(widget.idVisita),
                    builder:
                        (BuildContext context, AsyncSnapshot<int?> snapshot) {

                      if (snapshot.data != null) {
                        idTabela = snapshot.data;
                      }

                      return DropdownSaved(
                        DropdownSaved.tabelaPreco,
                        startValue: idTabela ?? appAmbiente.tabelaPadrao,
                        editable: appAmbiente.usarTabela,
                        onChange: (i) {
                          setTabela(i);
                        },
                      );
                    },
                  ),
                ),
                if (appAmbiente.usarTabela && idTabela != null)
                  Expanded(
                    child: InkWell(
                      child: const IconSmall(Icons.close),
                      onTap: () {
                        setTabela(0);
                      },
                    ),
                  )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
