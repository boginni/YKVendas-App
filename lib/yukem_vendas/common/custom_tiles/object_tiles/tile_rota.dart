import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../api/common/custom_widgets/icon_dynamic.dart';
import '../../../../api/models/configuracao/app_system.dart';
import '../../../models/database_objects/rota.dart';

///Mostra a rota e ao clicar, Salva a rota no Banco
class TileRota extends StatelessWidget {
  const TileRota(this.rota, this.onPressed, {Key? key}) : super(key: key);
  final Rota rota;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    AppSystem appConfig = AppSystem.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: TextButton(
        onPressed: rota.disp ? onPressed : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              /// Ícone
              Flexible(
                flex: 1,
                child: IconDynamic(
                  primary: CupertinoIcons.map,
                  secondary: CupertinoIcons.map_fill,
                  size: (32 + appConfig.getIconScale()),
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              Expanded(
                flex: 4,
                child: TextTitle(
                  rota.nome!,
                ),
              ),

              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextNormal(rota.clientes.toString()),
                    const SizedBox(
                      width: 2,
                    ),
                    const Icon(Icons.people),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
