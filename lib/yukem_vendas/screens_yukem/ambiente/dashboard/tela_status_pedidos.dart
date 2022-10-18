import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:forca_de_vendas/api/common/custom_tiles/default_tiles/tile_spaced_text.dart';

import '../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../api/common/custom_widgets/popupmenu_item_tile.dart';
import '../../../../api/common/formatter/date_time_formatter.dart';
import '../../../models/configuracao/app_user.dart';
import '../../../models/internet/internet.dart';
import '../base/custom_drawer.dart';
import '../base/moddel_screen.dart';

class TelaStatusPedido extends ModdelScreen {
  //TODO: Implementação de ScreenID para configurar a exibição de telas
  final int screenId = 0;

  const TelaStatusPedido({Key? key}) : super(key: key);

  @override
  Widget getCustomScreen(BuildContext context) {
    return _Tela();
  }
}

class _Tela extends StatefulWidget {
  const _Tela({Key? key}) : super(key: key);

  @override
  State<_Tela> createState() => _TelaState();
}

class _TelaState extends State<_Tela> {
  Map<String, dynamic> result = {};
  bool isLoading = true;
  bool onP = false;

  late DateTime curDate;

  DateTimeRange? rangeDate;

  loadData(DateTime? selectedTime) {
    selectedTime ??= curDate;

    final time = DateFormatter.databaseDate.format(selectedTime);
    curDate = selectedTime;

    // final time = '2022-08-04';

    final body = {
      "id_vendedor": AppUser.of(context).vendedorAtual,
      // "id_vendedor": 4502,
      // "id_vendedor": 7,
      "data_inicio": time,
      "data_fim": time
    };

    Internet.serverPost('dash/status/pedido/', context: context, body: body)
        .then((value) {
      if (value.statusCode != 200) {
        return;
      }

      setState(() {
        isLoading = false;
        result = const JsonDecoder().convert(value.body);
      });
    });
  }

  loadP() {
    onP = true;

    final body = {
      "id_vendedor": AppUser.of(context).vendedorAtual,
      // "id_vendedor": 4502,
      // "id_vendedor": 7,
      "data_inicio": DateFormatter.databaseDate.format(rangeDate!.start),
      "data_fim": DateFormatter.databaseDate.format(rangeDate!.end)
    };

    Internet.serverPost('dash/status/pedido/', context: context, body: body)
        .then((value) {
      if (value.statusCode != 200) {
        return;
      }

      setState(() {
        isLoading = false;
        result = const JsonDecoder().convert(value.body);
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      loadData(DateTime.now());
    });
  }

  Widget _popupTelaStatus() {
    return PopupMenuButton<int>(
      onSelected: (int i) {
        if (i == 1) {
          showDateRangePicker(
              context: context,
              firstDate: DateTime.now().add(Duration(days: -90)),
              lastDate: DateTime.now(),
              builder: (BuildContext context, Widget? child) {
                return Theme(
                  data: ThemeData.light().copyWith(
                    //Header background color
                    primaryColor: Colors.blue,
                    //Background color
                    scaffoldBackgroundColor: Colors.grey[50],
                    //Divider color
                    dividerColor: Colors.grey,
                    //Non selected days of the month color
                    textTheme: TextTheme(
                      bodyText2: TextStyle(color: Colors.black),
                    ),
                    colorScheme: ColorScheme.fromSwatch().copyWith(
                      //Selected dates background color
                      primary: Colors.blue,
                      //Month title and week days color
                      onSurface: Colors.black,
                      //Header elements and selected dates text color
                      //onPrimary: Colors.white,
                    ),
                  ),
                  child: child!,
                );
              }).then((value) {
            if (value != null) {
              rangeDate = value;
              loadP();
            }
          });
        }
      },
      itemBuilder: (context) => [
        TilePopupMenuItem(
          value: 1,
          icon: Icons.search,
          title: 'Periodo',
        ),
      ],
      child: const Padding(
        padding: EdgeInsets.only(right: 20),
        child: Icon(
          Icons.more_vert_outlined,
          size: 26.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final carregando = Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              TextNormal('Carregando Dados'),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos'),
        actions: [_popupTelaStatus()],
      ),
      drawer: const CustomDrawer(),
      body: isLoading
          ? carregando
          : RefreshIndicator(
              onRefresh: () async {
                if (onP) {
                  loadP();
                } else {
                  loadData(null);
                }
              },
              child: ListContainer(
                result: result,
                onChangeDate: (DateTime newDate) {
                  setState(() {
                    isLoading = true;
                    loadData(newDate);
                  });
                },
                onPeriodo: onP,
                range: rangeDate,
                selectedDate: curDate,
              ),
            ),
    );
  }
}

class TilePedido extends StatelessWidget {
  const TilePedido({Key? key, required this.item}) : super(key: key);

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final cab = item['cab'];
    final det = item['det'] as List<dynamic>;

    bool salvo = cab[4] != 'SALVO';

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextNormal(cab[4]),
                    TextNormal(cab[3]),
                  ],
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              if (salvo)
                Flexible(
                  flex: 1,
                  child: TextNormal(
                    TextDinheiroReal.format(
                      double.parse(
                        (cab[5]).toString(),
                      ),
                    ),
                  ),
                ),

              //
            ],
          ),
          children: salvo
              ? [
                  TextNormal(cab[6] ?? ''),
                  const SizedBox(
                    height: 8,
                  ),
                  ListView.builder(
                      shrinkWrap: true,
                      itemCount: det.length,
                      itemBuilder: (context, index) {
                        return TilePedidoItem(
                          item: det[index],
                        );
                      }),
                ]
              : [
                  const TextNormal(
                      'Itens e outras informações só estarão disponíveis após entrar para faturamento')
                ],
        ),
      ),
    );
  }
}

class TilePedidoItem extends StatelessWidget {
  const TilePedidoItem({Key? key, required this.item}) : super(key: key);

  final List<dynamic> item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextNormal(item[5]),
                  TextNormal(item[6].toString()),
                ],
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Flexible(
              flex: 1,
              child: TextNormal(
                TextDinheiroReal.format(
                  double.parse(
                    item[7].toString(),
                  ),
                ),
              ),
            ),

            //
          ],
        ),
      ),
    );
  }
}

class DatePickerTile extends StatefulWidget {
  const DatePickerTile({
    Key? key,
    required this.minDate,
    required this.maxDate,
    required this.startingDate,
    required this.onChange,
  }) : super(key: key);

  final DateTime minDate;
  final DateTime maxDate;
  final DateTime startingDate;

  final Function(DateTime newDate) onChange;

  @override
  State<DatePickerTile> createState() => _DatePickerTileState();
}

class _DatePickerTileState extends State<DatePickerTile> {
  late DateTime currentDate;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentDate = widget.startingDate;
  }

  @override
  Widget build(BuildContext context) {
    change(int days) {
      final dt = Duration(days: days);

      final newDate = currentDate.add(Duration(days: days));

      if (newDate.isAfter(widget.minDate) && newDate.isBefore(widget.maxDate)) {
        setState(() {
          currentDate = newDate;
          widget.onChange(newDate);
        });
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextButton(
                onPressed: () {
                  change(-1);
                },
                child: const TextTitle('Anterior')),
          ),
          Expanded(
            flex: 3,
            child: Align(
                alignment: Alignment.center,
                child: TextBigTitle(
                    DateFormatter.normalDataResumido.format(currentDate))),
          ),
          Expanded(
            flex: 2,
            child: TextButton(
                onPressed: () {
                  change(1);
                },
                child: const TextTitle('Próximo')),
          ),
        ],
      ),
    );
  }
}

class ListContainer extends StatelessWidget {
  const ListContainer(
      {Key? key,
      required this.result,
      required this.onChangeDate,
      required this.onPeriodo,
      this.range,
      required this.selectedDate})
      : super(key: key);

  final Map<String, dynamic> result;

  final Function(DateTime newDate) onChangeDate;

  final bool onPeriodo;
  final DateTimeRange? range;
  final DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    final itens = (result['rows'] ?? []) as List<dynamic>;
    final total =
        (result['totais'] ?? <String, dynamic>{}) as Map<String, dynamic>;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Column(
              children: [
                !onPeriodo
                    ? DatePickerTile(
                        startingDate: selectedDate,
                        maxDate: DateTime.now(),
                        minDate: DateTime.now().add(const Duration(days: -30)),
                        onChange: onChangeDate,
                      )
                    : TextNormal(
                        '${DateFormatter.normalDataResumido.format(range!.start)} - ${DateFormatter.normalDataResumido.format(range!.end)}'),
                TileSpacedText('Pedidos', total['pedidos'].toString()),
                TileSpacedText('Peso', total['peso'].toString()),
                TileSpacedText(
                    'Total',
                    TextDinheiroReal.format(
                        double.parse(total['total'].toString()))),
                const SizedBox(
                  height: 8,
                ),
                TileSpacedText('Data', total['date'].toString()),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          itemCount: itens.length,
          itemBuilder: (context, index) {
            final item = itens[index];
            return TilePedido(item: item);
          },
        )
      ],
    );
  }
}
