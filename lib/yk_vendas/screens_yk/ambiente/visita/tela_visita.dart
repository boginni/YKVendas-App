import 'package:flutter/material.dart';

import '../../../../api/common/custom_tiles/default_tiles/tile_buttom.dart';
import '../../../models/database_objects/visita.dart';
import 'tela_visita/chegada_cliente.dart';
import 'tela_visita/tela_pedido.dart';
import 'tela_visita/tela_visita_realizada.dart';

class TelaVisita extends StatefulWidget {
  static const routeName = '/telaVisita';

  const TelaVisita({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TelaVisitaState();
}

class _TelaVisitaState extends State<TelaVisita> {
  void update() async {
    setState(() {});
  }

  Visita? visita;
  late int idVisita;

  reloadVisita() {
    Visita.getVisita(idVisita).then((value) {
      setState(() {
        visita = value;
      });
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      idVisita = ModalRoute.of(context)!.settings.arguments as int;
      reloadVisita();
    });
  }

  @override
  Widget build(BuildContext context) {
    clickChegada(Visita visita) async {
      await Navigator.of(context)
          .pushNamed(TelaChegadaCliente.routeName, arguments: visita)
          .then((value) => reloadVisita());
    }

    Widget child = const Center(
      child: CircularProgressIndicator(),
    );

    if (visita != null) {
      child = ListView(
        children: [
          TileButton(
            title: 'Chegada no cliente',
            icon: Icons.gps_fixed_sharp,
            onPressMethod: () => clickChegada(visita!),
            isActive: !visita!.chegadaConcluida,
          ),
          TileButton(
            title: 'Pedido',
            icon: Icons.add_shopping_cart,
            onPressMethod: () {
              Navigator.of(context)
                  .pushNamed(TelaPedido.routeName, arguments: idVisita)
                  .then((value) async {
                visita = await Visita.getVisita(idVisita);

                if (visita!.getStatus() == VisitaStatus.concluida) {
                  Navigator.of(context).pop(context);
                }
              });
            },
            isActive: visita!.chegadaConcluida && visita!.situacao == 1,
          ),
          TileButton(
            title: 'Visita Realizada',
            icon: Icons.note_outlined,
            onPressMethod: () {
              Navigator.of(context)
                  .pushNamed(TelaVisitaRealizada.routeName, arguments: idVisita)
                  .then((value) {
                if (value == true) {
                  Navigator.of(context).pop();
                  return;
                }

                reloadVisita();
              });
            },
            isActive: visita!.chegadaConcluida && visita!.situacao == 1,
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(visita == null ? '' : visita!.nome),
        // TODO Mudar para visita
        centerTitle: true,
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pop(context);
          },
        ),
      ),
      body: child,
    );
  }
}
