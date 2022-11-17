import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forca_de_vendas/api/common/custom_widgets/custom_icons.dart';
import 'package:forca_de_vendas/yukem_vendas/models/configuracao/app_ambiente.dart';
import 'package:forca_de_vendas/yukem_vendas/models/database/database_ambiente.dart';
import 'package:forca_de_vendas/yukem_vendas/models/database_objects/visita.dart';

import '../../../../../api/common/components/mostrar_confirmacao.dart';
import '../../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../../api/common/form_field/database_fields.dart';
import '../../../../models/database_objects/tabela_precos.dart';

class ContainerTabelaPrecos extends StatefulWidget {
  final Visita visita;

  final Function(int? i) onChange;

  const ContainerTabelaPrecos({
    Key? key,
    required this.visita,
    required this.onChange,
  }) : super(key: key);

  static Future<bool> confirmarAlteracao(BuildContext context, idVisita) async {
    final value = await DatabaseAmbiente.select('VW_VISITA_INFO_ITENS',
        where: 'ID_VISITA = ?', whereArgs: [idVisita]);

    if (value.isNotEmpty && (value[0]['PRODUTOS'] ?? 0) > 0) {
      return await mostrarCaixaConfirmacao(
        context,
        title: 'Altrar Tabela de preços?',
        content: "Todos os produtos serao removidos",
      );
    } else {
      return true;
    }
  }

  @override
  State<StatefulWidget> createState() => _ContainerTabelaPrecosState();
}

class _ContainerTabelaPrecosState extends State<ContainerTabelaPrecos> {
  int? idTabela;
  int? lastPessoa;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getData();
    });
  }

  bool onLoading = true;

  getData() async {
    TabelaPreco.getIdTabela(widget.visita.id).then((value) {
      setState(() {
        idTabela = value;
        onLoading = false;
      });
    });
  }

  @override
  void didUpdateWidget(dynamic oldWidget) {
    getData();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final appAmbiente = AppAmbiente.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: onLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  const TextTitle('Tabela de Preços'),
                  Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: DropdownSaved(
                          DropdownSaved.tabelaPreco,
                          value: idTabela,
                          editable: appAmbiente.usarTabela,
                          onChange: (i) {
                            setTabela(i);
                          },
                        ),
                      ),
                      if (appAmbiente.usarTabela && idTabela != 0)
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

  setTabela(int? idTabela, {bool force = false}) async {
    if (await ContainerTabelaPrecos.confirmarAlteracao(
        context, widget.visita.id)) {
      TabelaPreco.insertTabelaPreco(widget.visita.id, idTabela).then((value) {
        widget.onChange(idTabela);
        this.idTabela = idTabela;
      });
    }
  }
}
