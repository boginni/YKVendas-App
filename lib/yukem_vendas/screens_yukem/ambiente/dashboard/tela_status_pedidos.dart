import 'package:flutter/material.dart';
import 'package:forca_de_vendas/api/common/custom_tiles/default_tiles/tile_spaced_text.dart';
import 'package:forca_de_vendas/yukem_vendas/models/configuracao/app_user.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/dashboard/components/container_loading.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/dashboard/components/selecionar_periodo.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/dashboard/moddels/status_pedido.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/dashboard/tiles/tile_status_pedido.dart';

import '../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../api/common/formatter/date_time_formatter.dart';
import '../base/custom_drawer.dart';
import 'components/date_picker_slide.dart';

class TelaStatusPedido extends StatefulWidget {
  const TelaStatusPedido({Key? key}) : super(key: key);

  @override
  State<TelaStatusPedido> createState() => _TelaStatusPedidoState();
}

class _TelaStatusPedidoState extends State<TelaStatusPedido> {
  Map<String, dynamic> result = {};
  bool onLoading = true;
  bool onRange = false;

  late DateTime curDate;
  late DateTimeRange dateRange;

  @override
  void initState() {
    super.initState();
    setDate(DateTime.now());
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      loadData();
    });
  }

  setDate(DateTime time) {
    curDate = time;
    onRange = false;
    dateRange = DateTimeRange(start: time, end: time);
  }

  loadData({bool showReload = true}) {
    if (showReload) {
      setState(() {
        onLoading = true;
      });
    }

    StatusPedido.loadData(context, AppUser.of(context).vendedorAtual,
            dateRange.start, dateRange.end)
        .then((value) {
      setState(() {
        result = value;
        onLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormatter.normalDataResumido;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: InkWell(
              child: const Icon(
                Icons.search,
                size: 26.0,
              ),
              onTap: () {
                SelecionarPeriodo.showPicker(context).then((value) {
                  if (value != null) {
                    onRange = true;
                    dateRange = value;
                    loadData();
                  }
                });
              },
            ),
          )
        ],
      ),
      drawer: const CustomDrawer(),
      body: onLoading
          ? const ContainerLoading()
          : Builder(builder: (context) {
              final total = result['totais'];
              final itens = result['rows'];

              return RefreshIndicator(
                onRefresh: () async {
                  loadData(showReload: false);
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 12),
                        child: Column(
                          children: [
                            onRange
                                ? TextNormal(
                                    '${formatter.format(dateRange.start)} - ${formatter.format(dateRange.end)}')
                                : DatePickerSlide(
                                    startingDate: curDate,
                                    maxDate: DateTime.now(),
                                    minDate: DateTime.now()
                                        .add(const Duration(days: -30)),
                                    onChange: (newDate) {
                                      setState(() {
                                        setDate(newDate);
                                        loadData();
                                      });
                                    },
                                  ),
                            TileSpacedText(
                                'Pedidos', total['pedidos'].toString()),
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
                        return TileStatusPedido(item: item);
                      },
                    )
                  ],
                ),
              );
            }),
    );
  }
}
