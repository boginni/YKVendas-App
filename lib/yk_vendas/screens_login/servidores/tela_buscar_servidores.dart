import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../api/common/components/list_scrollable.dart';
import '../../../../api/common/custom_widgets/custom_buttons.dart';
import '../../../../api/common/custom_widgets/custom_icons.dart';
import '../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../api/common/custom_widgets/floating_bar.dart';
import '../../../../api/models/system_database/system_database.dart';
import '../../../api/common/components/mostrar_confirmacao.dart';
import '../../models/database_objects/conf_ambiente.dart';
import '../../models/internet/internet.dart';
import '../../models/internet/server_manager.dart';

class TelaBuscarServidores extends StatefulWidget {
  static const String routeName = 'buscarServidores';

  const TelaBuscarServidores({
    Key? key,
    this.boolMostrarIp = false,
    required this.ambiente,
  }) : super(key: key);

  final bool boolMostrarIp;

  final String ambiente;

  @override
  State<StatefulWidget> createState() => _TelaBuscarServidoresState();
}

class _TelaBuscarServidoresState extends State<TelaBuscarServidores> {
  List<UserConfig> list = [];

  final server = TextEditingController();
  final door = TextEditingController();

  final TextEditingController ambienteController = TextEditingController();

  @override
  void initState() {
    super.initState();

    ambienteController.text = widget.ambiente;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Servidores'),
        centerTitle: true,
      ),
      // drawer: const CustomDrawer(),
      body: BodyFloatingBar(
        child: ListView(
          children: <Widget>[
            if (widget.boolMostrarIp)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: ListViewNested(
                    children: [
                      const TextTitle('Servidor Atual:'),
                      TextNormal(Internet.getHttpServer()),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          Flexible(
                            flex: 4,
                            child: TextFormField(
                              controller: server,
                              decoration: const InputDecoration(
                                hintText: 'Ex: 192.168.1.1',
                                label: TextTitle('Servidor'),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Flexible(
                            flex: 1,
                            child: TextFormField(
                              controller: door,
                              decoration: const InputDecoration(
                                hintText: '9032',
                                label: TextTitle('Door'),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            flex: 2,
                            child: ButtonLimpar(
                                enabled: true,
                                onPressed: () {
                                  Internet.setDefault();

                                  setState(() {});
                                }),
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Flexible(
                            flex: 2,
                            child: ButtonSalvar(
                                enabled: true,
                                onPressed: () {
                                  Internet.setURl(
                                      server.text, door.text, door.text);
                                  setState(() {});
                                }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: ListViewNested(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 2, vertical: 2),
                      child: Row(
                        children: [
                          Expanded(
                              flex: 5,
                              child: TextFormField(
                                controller: ambienteController,
                              )),
                          Expanded(
                              flex: 1,
                              child: TextButton(
                                onPressed: () {
                                  setState(() {});
                                },
                                child: const IconNormal(Icons.search),
                              ))
                        ],
                      ),
                    ),
                  ),
                  FutureBuilder(
                      future: getServidoresInternet(ambienteController.text),
                      builder: (context,
                          AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                        List<Map<String, dynamic>> list = snapshot.data ?? [];

                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: list.length,
                          itemBuilder: (BuildContext context, int index) {
                            final item = list[index];

                            return Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 2, vertical: 2),
                              child: TextButton(
                                onPressed: () async {
                                  final db = await DatabaseSystem.getDatabase();
                                  await db.insert('TB_SERVIDOR', item,
                                      conflictAlgorithm:
                                          ConflictAlgorithm.replace);
                                  mostrarCaixaConfirmacao(context,
                                      title: 'Servidor',
                                      content: 'Selecionado com sucesso!',
                                      mostrarCancelar: false);
                                },
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextTitle(item['apelido']),
                                ),
                              ),
                            );
                          },
                        );
                      }),
                ],
              ),
            ),
          ],
        ),
        barChildrens: //[ButtonSalvar(enabled: true, onPressed: savarTudo)]
            [],
      ),
    );
  }
}
