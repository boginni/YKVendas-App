import 'package:flutter/material.dart';
import '../base/custom_drawer.dart';
import '../base/moddel_screen.dart';

class TelaMensagens extends ModdelScreen {
  const TelaMensagens({Key? key}) : super(key: key);

  @override
  Widget getCustomScreen(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Mensagens'),
          centerTitle: true,
        ),
        drawer: const  CustomDrawer(),
        body: Container(
          color: Colors.white,
          child: const  Center(child: Text('Nenhuma Mensagem.')),
        ));
  }

}
