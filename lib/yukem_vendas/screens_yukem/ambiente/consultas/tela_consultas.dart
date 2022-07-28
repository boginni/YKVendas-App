import 'package:flutter/material.dart';

import '../../../../api/common/form_field/formulario.dart';
import '../base/custom_drawer.dart';
import '../base/moddel_screen.dart';

class TelaConsultas extends ModdelScreen {
  const TelaConsultas({Key? key}) : super(key: key);

  @override
  Widget getCustomScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consultas')),
      drawer: const CustomDrawer(),
      backgroundColor: Colors.white,
      body: ListView(
        children: <Widget>[
          const Text('Visitas'),
          FormText(
            saveFunction: (_) {},
            title: 'Data Inicial',
            mandatoryField: true,
          ),
          FormText(
            saveFunction: (_) {},
            title: 'Data Final',
            mandatoryField: true,
          ),
          FormText(
            saveFunction: (_) {},
            title: 'Atividade',
            mandatoryField: true,
          ),
          FormText(
            saveFunction: (_) {},
            title: 'Cliente',
          ),
          FormText(
            saveFunction: (_) {},
            title: 'Observação',
          ),
        ],
      ),
    );
  }
}
