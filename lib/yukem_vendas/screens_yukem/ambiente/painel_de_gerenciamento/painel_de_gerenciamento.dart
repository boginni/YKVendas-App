import 'package:flutter/material.dart';

import '../base/custom_drawer.dart';
import '../base/moddel_screen.dart';

class TelaPainelGerenciamento extends ModdelScreen {
  const TelaPainelGerenciamento({Key? key}) : super(key: key);

  @override
  Widget getCustomScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel de Gerenciamento'),
      ),
      backgroundColor: Colors.white,
      drawer: const CustomDrawer(),
      body: const Center(
        child: Text('Isso vai abrir uma guia no navegador'),
      ),
    );
  }
}
