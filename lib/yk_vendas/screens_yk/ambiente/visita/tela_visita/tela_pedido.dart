import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../../api/common/debugger.dart';
import '../../../../../api/screens/support/screen_loading.dart';
import '../../../../models/database_objects/pedido.dart';
import '../../../../models/database_objects/visita.dart';
import '../container/container_pedido.dart';

class TelaPedido extends StatefulWidget {
  static const routeName = '/pedido';

  const TelaPedido({Key? key}) : super(key: key);

  static performHotReload(BuildContext context,
      {bool app = false, bool toSync = false}) {
    final _TelaPedidoState? state =
        context.findAncestorStateOfType<_TelaPedidoState>();

    if (state != null) {
      state.performHotRestart();
    }
  }

  @override
  State<StatefulWidget> createState() => _TelaPedidoState();
}

class _TelaPedidoState extends State {
  Key keyPedido = UniqueKey();

  void performHotRestart() {
    setState(() {
      keyPedido = UniqueKey();
    });
  }

  Visita? visita;

  // TotaisPedido? totaisPedido;

  bool toSetup = true;

  late final int idVisita;
  Pedido? pedido;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      idVisita = ModalRoute.of(context)!.settings.arguments as int;
      reload();
    });
  }

  reload() async {
    Pedido.getPedido(idVisita, context).then((value) {
      setState(() {
        pedido = value;
      });
    }).onError((error, stackTrace) {
      printDebug(stackTrace);
      throw Exception(error);
    });
  }

  @override
  Widget build(BuildContext context) {

    if (pedido != null) {
      return ContainerPedido(
        pedido: pedido!,
        onUpdate: () {
          reload();
        },
      );
    }



    return  const ScreenLoading(
      back: true,
      children: [
        TextNormal('Carregando Pedido'),
      ],
    );
  }
}
