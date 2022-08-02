import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/base/custom_drawer.dart';

import '../base/moddel_screen.dart';

class TelaCritica extends ModdelScreen {
  //TODO: Implementação de ScreenID para configurar a exibição de telas
  final int screenId = 0;

  const TelaCritica({Key? key}) : super(key: key);

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
