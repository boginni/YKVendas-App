import 'package:flutter/material.dart';

import '../../../../api/common/components/mostrar_confirmacao.dart';
import '../../../../api/common/custom_widgets/custom_buttons.dart';
import '../../../../api/common/custom_widgets/floating_bar.dart';
import '../../../../api/models/configuracao/app_system.dart';
import '../../../../api/models/system_database/system_config.dart';
import '../../../common/custom_tiles/object_tiles/tile_system_config.dart';
import '../../../models/configuracao/app_user.dart';
import '../../yk_foundation.dart';
import '../base/custom_drawer.dart';
import '../base/moddel_screen.dart';

class TelaConfiguracoesUser extends ModdelScreen {
  const TelaConfiguracoesUser({Key? key}) : super(key: key);

  @override
  Widget getCustomScreen(BuildContext context) {
    return xTelaConfiguracoesUser();
  }
}

class xTelaConfiguracoesUser extends StatefulWidget {
  const xTelaConfiguracoesUser({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => TelaConfiguracoesUserState();
}

class TelaConfiguracoesUserState extends State<xTelaConfiguracoesUser> {
  List<SystemConfig> list = [];

  bool hasUpdate = false;

  bool editado = false;

  @override
  Widget build(BuildContext context) {
    salvarTudo() async {
      editado = false;
      for (final item in list) {
        await item.updateConfig();
      }
      AppSystem.of(context).update(await AppSystem.getAppMaps());
      setState(() {});
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        centerTitle: true,
      ),
      drawer: const CustomDrawer(),
      body: BodyFloatingBar(
        child: ListView(
          children: <Widget>[
            TextButton(
                onPressed: () {
                  mostrarCaixaConfirmacao(context, title: 'Ressincronização Completa?', content: 'Deseja mesmo baixar todos os dados novamente?').then((value) {
                    if (value) {
                      AppUser
                          .of(context)
                          .fullsync = true;
                      YKFoundation.performRestart(context, toSync: true);
                    }
                  });
                },
                child: const Text('Ressincronização completa')),
            Card(
              child: FutureBuilder(
                future: getSystemConfigList(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<SystemConfig>> snapshot) {
                  if (snapshot.data == null) {
                    return const SizedBox(
                      height: 64,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  list = snapshot.data!;

                  // printDebug(list.toString());

                  return ListView.builder(
                    itemCount: list.length,
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemBuilder: (BuildContext context, int i) {
                      return TileSystemConfig(
                        systemConfig: list[i],
                        onChance: (b) {
                          list[i].valor = b;
                        },
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(
              height: 64,
            ),
          ],
        ),
        barChildrens: //[ButtonSalvar(enabled: true, onPressed: savarTudo)]
        [
          ButtonSalvar(
              enabled: true,
              onPressed: () {
                salvarTudo();
                mostrarCaixaConfirmacao(context,
                    title: 'Configuração',
                    content: 'Salvo com sucesso!',
                    mostrarCancelar: false);
              })
        ],
      ),
    );
  }
}
