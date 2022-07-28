//TODO: Mudar para statefull e permitir uso do update
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forca_de_vendas/api/common/custom_widgets/custom_icons.dart';
import 'package:forca_de_vendas/api/helpers/brasil_formatter.dart';

import '../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../api/common/custom_widgets/icon_dynamic.dart';
import '../../../../api/models/configuracao/app_system.dart';
import '../../../models/database_objects/cliente.dart';

class TileCliente extends StatelessWidget {
  // final Function? onPressMethod;

  final Cliente cliente;

  static int countIcon = 0;

  final Function? onClick;

  const TileCliente({Key? key, required this.cliente, required this.onClick})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appSystem = AppSystem.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: TextButton(
        onPressed: () {
          if (onClick != null) {
            onClick!();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: Row(
            children: [
              ///Ícone
              Flexible(
                flex: 1,
                child: Stack(
                  children: [
                    IconDynamic(
                      primary: CupertinoIcons.person_fill,
                      secondary: CupertinoIcons.person,
                      size: (40 + appSystem.getIconScale()),
                    ),
                    if (cliente.idSync == null)
                      const IconStatus(statusIconType: StatusIconTypes.warning),
                  ],
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              Flexible(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(child: TextTitle(
                            '${cliente.idSync ?? '-'} ${cliente.nome ?? ''}')),
                        if (cliente.toSync)
                          const IconStatus(
                              statusIconType: StatusIconTypes.sync),
                      ],
                    ),
                    TextNormal(cliente.apelido ?? ''),
                    TextNormal(
                      formatCpfCnpj(cliente.cpfcnpj),
                    ),
                    if (cliente.clienteTipo != null)
                      TextSpamable(textList: [
                        const TextNormal(
                          'Canal: ',
                        ),
                        TextTitle(
                          '${cliente.clienteTipo}',
                        ),
                      ])
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
