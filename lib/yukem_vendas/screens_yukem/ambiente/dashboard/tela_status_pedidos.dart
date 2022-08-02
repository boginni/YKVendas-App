import 'package:flutter/material.dart';

import '../base/custom_drawer.dart';
import '../base/moddel_screen.dart';

class TelaStatusPedido extends ModdelScreen {
  //TODO: Implementação de ScreenID para configurar a exibição de telas
  final int screenId = 0;

  const TelaStatusPedido({Key? key}) : super(key: key);

  @override
  Widget getCustomScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Critica'),
      ),
      drawer: CustomDrawer(),
      body: Container(),
    );
  }
}
