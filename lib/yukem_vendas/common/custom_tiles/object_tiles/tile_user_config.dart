import 'package:flutter/material.dart';

import '../../../../api/common/custom_tiles/default_tiles/tile_spaced_text.dart';
import '../../../../api/common/form_field/formulario.dart';
import '../../../models/database_objects/conf_ambiente.dart';

class TileUserConfig extends StatefulWidget {
  final Function(String x) onChance;

  const TileUserConfig(
      {Key? key, required this.userConfig, required this.onChance})
      : super(key: key);

  final UserConfig userConfig;

  @override
  State<StatefulWidget> createState() => _TileUserConfigState();
}

class _TileUserConfigState extends State<TileUserConfig> {
  @override
  Widget build(BuildContext context) {
    late final Widget child;

    if (widget.userConfig.tipo == 3) {
      child = FormSwitchButton(
        startValue: widget.userConfig.valor == '1' ? true : false,
        title: widget.userConfig.nome,
        onChange: (bool value) {
          widget.userConfig.valor = value ? '1' : '0';
          widget.onChance(value ? '1' : '0');
        },
      );
    } else {
      child = TileSpacedWidget(
        widget.userConfig.nome,
        child: SizedBox(
          width: 70,
          child: TextFormField(
            initialValue: widget.userConfig.valor,
            onChanged: (x) {
              widget.userConfig.valor = x;
              widget.onChance(x);
            },
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: child,
      ),
    );
  }
}
