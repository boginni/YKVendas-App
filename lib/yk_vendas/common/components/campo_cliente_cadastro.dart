import 'package:flutter/material.dart';

import '../../models/database_objects/config_campo.dart';

class CampoClienteCadastro extends StatelessWidget {
  const CampoClienteCadastro(
      {Key? key,
      required this.child,
      required this.editable,
      required this.config})
      : super(key: key);

  final Widget child;
  final bool editable;
  final ConfigCampo config;

  @override
  Widget build(BuildContext context) {
    if (!config.mostrar) {
      return Container();
    }

    return child;
  }
}
