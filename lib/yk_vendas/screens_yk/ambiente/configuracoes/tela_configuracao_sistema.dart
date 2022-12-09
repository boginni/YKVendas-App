import 'package:flutter/material.dart';
import 'package:share/share.dart';

import '../../../../api/common/components/mostrar_confirmacao.dart';
import '../../../../api/common/custom_widgets/custom_buttons.dart';
import '../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../api/common/custom_widgets/floating_bar.dart';
import '../../../../api/models/configuracao/app_system.dart';
import '../../../../api/models/system_database/system_config.dart';
import '../../../../api/models/system_database/system_database.dart';
import '../../../common/custom_tiles/object_tiles/tile_system_config.dart';
import '../../../models/file/file_manager.dart';

class TelaConfiguracoesSistema extends StatefulWidget {
  static const String routeName = 'configuracoesSistema';

  const TelaConfiguracoesSistema({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TelaConfiguracoesSistemaState();
}

class _TelaConfiguracoesSistemaState extends State<TelaConfiguracoesSistema> {
  List<SystemConfig> list = [];

  final server = TextEditingController();
  final door = TextEditingController();
  bool editado = false;

  final controller = TextEditingController();

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
        leading: BackButton(onPressed: () {
          if (editado) {
            mostrarCaixaConfirmacao(context,
                    title: "Sair sem salvar?",
                    content: "As alterações serão descartadas")
                .then((value) {
              if (value) {
                Navigator.of(context).pop();
              }
            });
          } else {
            Navigator.of(context).pop();
          }
        }),
      ),
      // drawer: const CustomDrawer(),
      body: BodyFloatingBar(
        child: ListView(
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Column(
                  children: [
                    const TextTitle('Compartilhar banco'),
                    TextField(
                      controller: controller,
                      decoration: const InputDecoration(hintText: 'Nome do ambiente'),
                    ),
                    TextButton(
                        onPressed: () async {
                          final filePath = await FilePath.getDatabase(controller.text);
                          Share.shareFiles([filePath], text: 'banco de dados');
                          DatabaseSystem.getDatabase();
                        },
                        child: const Text('Enviar')),
                  ],
                ),
              ),
            ),
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

                  return ListView.builder(
                    itemCount: list.length,
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemBuilder: (BuildContext context, int i) {
                      return TileSystemConfig(
                        systemConfig: list[i],
                        onChance: (b) {
                          list[i].valor = b;
                          editado = true;
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
