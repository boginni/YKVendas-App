import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../api/common/components/mostrar_confirmacao.dart';
import '../../../../api/models/page_manager.dart';

/// Usada como template para criação de novas telas que são navegaveis pelo custom drawer
abstract class ModdelScreen extends StatelessWidget {
  const ModdelScreen({Key? key}) : super(key: key);

  /// Funciona exatamente como um build
  Widget getCustomScreen(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => onWillPop(context),
      child: getCustomScreen(context),
    );
  }


  Future<bool> onWillPop(BuildContext context) async {
    if (!context.read<PageManager>().previousPage()) {
      return await mostrarCaixaConfirmacao(context, title: 'Deseja Sair do app?');
    }
    return false;
  }

}
