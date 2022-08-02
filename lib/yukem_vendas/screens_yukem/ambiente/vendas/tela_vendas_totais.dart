import 'package:flutter/material.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/base/moddel_screen.dart';

import '../../../../api/common/components/list_scrollable.dart';
import '../../../../api/common/custom_widgets/custom_text.dart';
import '../../../common/chart/chart_cliente.dart';
import '../../../models/configuracao/app_user.dart';
import '../../../models/database_objects/comissao.dart';
import '../base/custom_drawer.dart';

class TelaVendasTotais extends ModdelScreen {
  //TODO: Implementação de ScreenID para configurar a exibição de telas
  final int screenId = 0;

  const TelaVendasTotais({Key? key}) : super(key: key);

  @override
  Widget getCustomScreen(BuildContext context) {
    return const xTelaVendasTotais();
  }
}

class xTelaVendasTotais extends StatefulWidget {
  //TODO: Implementação de ScreenID para configurar a exibição de telas
  final int screenId = 0;

  const xTelaVendasTotais({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TelaVendasTotaisState();
}

class _TelaVendasTotaisState extends State<xTelaVendasTotais> {
  // final _controllerPesquisa = TextEditingController();

  bool toSearch = true;

  DateTime? dataVenda;

  List<ComissaoMes> listMes = [];

  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    // QueryFilter getQuery() {
    //   String x = _controllerPesquisa.text;
    //
    //   bool y = isNumeric(x);
    //
    //   return QueryFilter(args: {
    //     y ? Venda.dbIdPessoa : Venda.dbNome: y ? intValue(x) : x,
    //     Venda.dbData: dataVenda != null
    //         ? DateFormat('dd-MM-yyyy').format(dataVenda!)
    //         : '',
    //   });
    // }

    Size size = MediaQuery.of(context).size;

    int idVendedor = AppUser.of(context).vendedorAtual;

    double width, height;

    width = size.width * 0.75;
    height = size.height * 0.40;

    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text('Vendas totais'),
      ),
      body: FutureBuilder(
        future: getListComissaoMes(idVendedor),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.data != null) {
            listMes = snapshot.data;
          }

          return ListView(
            shrinkWrap: true,
            controller: _scrollController,
            children: [
              // Card(
              //   child: Padding(
              //     padding: const EdgeInsets.all(8.0),
              //     child: SizedBox(
              //         height: height,
              //         width: width,
              //         child:
              //             HorizontalBarLabelChart.comissaoMes(listMes, true)),
              //   ),
              // ),

              if (listMes.isNotEmpty)
                _Detalhes(
                  idVendedor: idVendedor,
                  scrollController: _scrollController,
                  listMes: listMes,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Detalhes extends StatefulWidget {
  final ScrollController scrollController;

  final int idVendedor;

  final List<ComissaoMes> listMes;

  const _Detalhes(
      {Key? key,
      required this.scrollController,
      required this.idVendedor,
      required this.listMes})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _DetalhesState();
}

class _DetalhesState extends State<_Detalhes> {
  List<Comissao> list = [];
  int? curMes;

  @override
  Widget build(BuildContext context) {
    curMes ??= widget.listMes.length - 1;

    ComissaoMes mesAtual = widget.listMes[curMes!];

    setMes(int i) {
      setState(() {
        curMes = i;
      });
    }

    bool canSetMes(int i) {
      bool b = !(i > widget.listMes.length - 1 || i <= 0);
      return b;
    }

    return ListViewNested(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: TextButton(
                    onPressed: canSetMes(curMes! - 1)
                        ? () => setMes(curMes! - 1)
                        : null,
                    child: const TextTitle('Anterior')),
              ),
              Expanded(
                flex: 3,
                child: Align(
                    alignment: Alignment.center,
                    child: TextBigTitle(mesAtual.mes)),
              ),
              Expanded(
                flex: 2,
                child: TextButton(
                    onPressed: canSetMes(curMes! + 1)
                        ? () => setMes(curMes! + 1)
                        : null,
                    child: const TextTitle('Próximo')),
              ),
            ],
          ),
        ),
        FutureBuilder(
          future: getListComissao(widget.idVendedor, mes: mesAtual),
          builder:
              (BuildContext context, AsyncSnapshot<List<Comissao>> snapshot) {
            list = snapshot.data ?? [];

            return ListViewScrollable(
              maxCount: list.length,
              scrollController: widget.scrollController,
              itemBuilder: (BuildContext context, int i) {
                final item = list[i];
                return Card(
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                              flex: 3, child: TextNormal(item.nomeCliente)),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                TextDinheiroReal(valor: item.valorTotal),
                                TextNormal(item.getData())
                              ],
                            ),
                          ),
                        ],
                      )),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

// TODO: Criar filtros de pesquisa
// Card(
//   child: Padding(
//     padding: const EdgeInsets.all(8.0),
//     child: ListViewNested(
//       children: [
//         const TextTitle('Data da Venda'),
//         Row(
//           children: [
//             Expanded(
//               child: FormDatePicker(
//                 then: (x) {
//                   if (x != null) {
//                     dataVenda = x;
//                   }
//                   setState(() {});
//                 },
//                 initialDate:
//                     dataVenda != null ? dataVenda! : DateTime.now(),
//                 firstDate:
//                     DateTime.now().add(const Duration(days: -360)),
//                 lastDate: DateTime.now(),
//                 hint: 'Data de venda',
//               ),
//             ),
//             ButtonIcon(
//                 icon: Icons.clear,
//                 onPressed: () {
//                   dataVenda = null;
//                   setState(() {});
//                 })
//           ],
//         ),
//         const TextTitle('Pesquisa'),
//         TextFormField(
//           controller: _controllerPesquisa,
//           decoration: const InputDecoration(
//               hintText: 'ID Pessoa ou Nome Pessoa'),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             setState(() {
//               toSearch = true;
//             });
//           },
//           child: const TextNormal('Pesquisasr'),
//         ),
//       ],
//     ),
//   ),
// ),
