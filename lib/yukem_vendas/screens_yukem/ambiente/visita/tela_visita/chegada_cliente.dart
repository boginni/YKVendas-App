import 'package:flutter/material.dart';
import 'package:forca_de_vendas/api/common/custom_widgets/custom_text.dart';
import 'package:forca_de_vendas/api/common/formatter/date_time_formatter.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/titulos/tela_titulos_vencidos.dart';

import '../../../../../api/common/components/list_scrollable.dart';
import '../../../../../api/common/custom_tiles/default_tiles/tile_text.dart';
import '../../../../../api/common/custom_widgets/custom_buttons.dart';
import '../../../../../api/common/custom_widgets/floating_bar.dart';
import '../../../../models/configuracao/app_ambiente.dart';
import '../../../../models/database_objects/chegada_cliente.dart';
import '../../../../models/database_objects/visita.dart';
import '../../comodato/tela_comodato.dart';
import '../tela_pedido/container_dados_cliente.dart';

class TelaChegadaCliente extends StatelessWidget {
  static const routeName = '/chegadaCliente';

  const TelaChegadaCliente({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final visita = ModalRoute.of(context)!.settings.arguments as Visita;
    final x = ChegadaCliente(visita.id);

    final appAmbiente = AppAmbiente.of(context);

    saveVisita() async {
      await x.salvar();
      Navigator.of(context).pop(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chegada no Cliente'),
        centerTitle: true,
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pop(context);
          },
        ),
      ),
      body: BodyFloatingBar(
        barChildrens: [ButtonSalvar(enabled: true, onPressed: saveVisita)],
        child: ListView(
          children: [
            Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ContainerDadosClienteOld(
                  idVisita: visita.id,
                  visita: visita,
                  update: () {},
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListViewNested(
                  children: <Widget>[
                    TileText(
                      title: 'Hora',
                      value: DateFormatter.normalHoraMinuto2.format(x.chegada),
                    ),
                    const Text('Resumo Financeiro do Cliente'),
                    if (appAmbiente.usarLimiteCredito)
                      TileText(
                        title: 'Limite de Credito',
                        value: x.limiteCredito.toString(),
                      ),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: TextButton(
                child: const TextTitle('Comodatos'),
                onPressed: () {
                  Navigator.of(context).pushNamed(TelaComodato.routeName,
                      arguments: visita.idPessoaSync);
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: TextButton(
                child: const TextTitle('Títulos em aberto'),
                onPressed: () {
                  Navigator.of(context).pushNamed(TelaTitulos.routeName,
                      arguments: visita.idPessoaSync);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
