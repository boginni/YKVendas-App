import 'package:flutter/material.dart';

import '../../../../api/common/components/list_scrollable.dart';
import '../../../../api/common/custom_tiles/default_tiles/tile_spaced_text.dart';
import '../../../../api/common/custom_widgets/custom_buttons.dart';
import '../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../api/common/form_field/formulario.dart';
import '../../../../api/common/formatter/arredondamento.dart';
import '../../../../api/common/formatter/date_time_formatter.dart';
import '../../../../api/models/database_objects/query_filter.dart';
import '../../../common/custom_tiles/object_tiles/tile_venda.dart';
import '../../../models/database_objects/vendas.dart';
import '../base/custom_drawer.dart';
import '../base/moddel_screen.dart';

class TelaVisitaConcluida extends ModdelScreen {
  //TODO: Implementação de ScreenID para configurar a exibição de telas
  final int screenId = 0;

  const TelaVisitaConcluida({Key? key}) : super(key: key);

  @override
  Widget getCustomScreen(BuildContext context) {
    return xTelaVisitaConcluida();
  }
}

class xTelaVisitaConcluida extends StatefulWidget {
  //TODO: Implementação de ScreenID para configurar a exibição de telas
  final int screenId = 0;

  const xTelaVisitaConcluida({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TelaVisitaConcluidaState();
}

class _TelaVisitaConcluidaState extends State<xTelaVisitaConcluida> {
  final _controllerPesquisa = TextEditingController();

  bool toSearch = true;

  DateTime? dataVenda = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    QueryFilter getQuery() {
      String x = _controllerPesquisa.text;

      bool y = isNumeric(x);

      return QueryFilter(args: {
        y ? Venda.dbIdPessoa : Venda.dbNome: y ? intValue(x) : x,
        Venda.dbData: dataVenda != null ? DateFormatter.databaseDate.format(dataVenda!) : '',
      });
    }

    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text('Visitas Finalizadas'),
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListViewNested(
                children: [
                  const TextTitle('Data da Venda'),
                  Row(
                    children: [
                      Expanded(
                        child: FormDatePicker(
                          then: (x) {
                            if (x != null) {
                              dataVenda = x;
                            }
                            setState(() {});
                          },
                          initialDate:
                              dataVenda != null ? dataVenda! : DateTime.now(),
                          firstDate:
                              DateTime.now().add(const Duration(days: -360)),
                          lastDate: DateTime.now(),
                          startingDate: dataVenda,
                          hint: 'Data de venda',
                        ),
                      ),
                      ButtonIcon(
                          icon: Icons.clear,
                          onPressed: () {
                            dataVenda = null;
                            setState(() {});
                          })
                    ],
                  ),
                  const TextTitle('Pesquisa'),
                  TextFormField(
                    controller: _controllerPesquisa,
                    decoration: const InputDecoration(
                        hintText: 'ID Pessoa ou Nome Pessoa'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        toSearch = true;
                      });
                    },
                    child: const TextNormal('Pesquisar'),
                  ),
                ],
              ),
            ),
          ),
          FutureBuilder(
            future: getListVendas(queryFilter: getQuery()),
            builder:
                (BuildContext context, AsyncSnapshot<List<Venda>> snapshot) {
              toSearch = false;
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final list = snapshot.data as List<Venda>;

              double sum = 0;

              list.forEach((element) {
                sum += element.totalLiq;
              });

              return Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Column(
                        children: [
                          TileSpacedText('Pedidos', '${list.length}'),
                          TileSpacedText('Total Liquido',
                              'R\$: ${arredondarValorStr(sum)}'),
                        ],
                      ),
                    ),
                  ),
                  Row(children: [
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: list.length,
                        itemBuilder: (BuildContext context, int i) {
                          return TileVenda(list[i]);
                        },
                      ),
                    ),
                  ])
                ],
              );
            },
          )
        ],
      ),
    );
  }
}
