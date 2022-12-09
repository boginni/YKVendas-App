import 'package:flutter/material.dart';

import '../../../../api/common/components/list_scrollable.dart';
import '../../../../api/common/custom_tiles/default_tiles/tile_spaced_text.dart';
import '../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../api/common/form_field/formulario.dart';
import '../../../../api/models/system_database/system_config.dart';

class TileSystemConfig extends StatefulWidget {
  final Function(String x) onChance;

  const TileSystemConfig(
      {Key? key, required this.systemConfig, required this.onChance})
      : super(key: key);

  final SystemConfig systemConfig;

  @override
  State<StatefulWidget> createState() => _TileSystemConfigState();
}

class _TileSystemConfigState extends State<TileSystemConfig> {
  int? getSubdivision() {
    if (widget.systemConfig.tipo == 6) {
      return null;
    }
    double x = widget.systemConfig.max! - widget.systemConfig.min!;
    return x.round();
  }

  @override
  Widget build(BuildContext context) {
    late final Widget child;
    double? douValue = double.tryParse(widget.systemConfig.valor);

    switch (widget.systemConfig.tipo) {
      case 3:
        child = FormSwitchButton(
          startValue: widget.systemConfig.valor == '1' ? true : false,
          title: widget.systemConfig.nome,
          onChange: (bool value) {
            widget.systemConfig.valor = value ? '1' : '0';
            setState(() {});
            widget.onChance(value ? '1' : '0');
          },
        );
        break;
      case 5:
      case 6:
        child = ListViewNested(
          children: [
            TextTitle(widget.systemConfig.nome),
            Slider(
              value: douValue!,
              onChanged: (newRating) {
                String newVar = newRating.round().toString();

                setState(() {
                  widget.systemConfig.valor = newVar;
                });
              },
              divisions: getSubdivision(),
              label: douValue.round().toString(),
              min: widget.systemConfig.min!,
              max: widget.systemConfig.max!,
            ),
          ],
        );
        break;
      default:
        child = TileSpacedWidget(
          widget.systemConfig.nome,
          child: SizedBox(
            width: 70,
            child: TextFormField(
              initialValue: widget.systemConfig.valor,
              onChanged: (x) {
                widget.systemConfig.valor = x;
                widget.onChance(x);
              },
            ),
          ),
        );
        break;
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
