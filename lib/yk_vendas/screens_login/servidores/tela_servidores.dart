import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../api/common/components/list_scrollable.dart';
import '../../../../api/common/custom_widgets/custom_buttons.dart';
import '../../../../api/common/custom_widgets/custom_icons.dart';
import '../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../api/common/custom_widgets/floating_bar.dart';
import '../../../../api/models/system_database/system_database.dart';
import '../../../api/common/components/mostrar_confirmacao.dart';
import '../../app_foundation.dart';
import '../../models/database_objects/conf_ambiente.dart';
import 'tela_buscar_servidores.dart';

class TelaServidores extends StatefulWidget {
  static const String routeName = 'telaServidores';

  const TelaServidores({
    Key? key,
    this.boolMostrarIp = true,
    required this.ambiente,
  }) : super(key: key);
  final bool boolMostrarIp;

  final String ambiente;

  @override
  State<StatefulWidget> createState() => _TelaServidoresState();
}

class _TelaServidoresState extends State<TelaServidores> {
  List<UserConfig> list = [];
  final apelido = TextEditingController();
  final server = TextEditingController();
  final door = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Servidores'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: InkWell(
              onTap: () {
                Application.navigate(
                  context,
                  TelaBuscarServidores(
                    ambiente: widget.ambiente,
                  ),
                  callback: () {
                    setState(() {});
                  },
                );
              },
              child: const Icon(Icons.search, size: 24),
            ),
          )
        ],
      ),
      // drawer: const CustomDrawer(),
      body: BodyFloatingBar(
        child: ListView(
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: ListViewNested(
                  children: [
                    const Center(child: TextTitle('Adicionar Servidor')),
                    // TextNormal(getServer()),
                    // const SizedBox(
                    //   height: 8,
                    // ),

                    TextFormField(
                      controller: apelido,
                      decoration: const InputDecoration(
                        hintText: ''
                            'Servidor principal',
                        label: TextTitle('Apelido'),
                      ),
                    ),
                    const SizedBox(
                      width: 6,
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
                                apelido.text = '';
                                server.text = '';
                                door.text = '';
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
                              onPressed: () async {
                                Map<String, dynamic> item = {
                                  'SERVIDOR': server.text,
                                  'PORTA': int.parse(door.text),
                                  'AMBIENTE': 'TESTE',
                                  'APELIDO': apelido.text,
                                  'TIPO': 'E'
                                };

                                DatabaseSystem.insert('TB_SERVIDOR', item,
                                    conflictAlgorithm:
                                        ConflictAlgorithm.replace);
                                mostrarCaixaConfirmacao(context,
                                    title: 'Servidor',
                                    content: 'Salvo com sucesso!',
                                    mostrarCancelar: false);
                                setState(() {});
                              }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: FutureBuilder(
                  future: getServidores(),
                  builder: (context,
                      AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                    List<Map<String, dynamic>> list = snapshot.data ?? [];

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: list.length,
                      itemBuilder: (BuildContext context, int index) {
                        final item = Map.of(list[index]);

                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 2, vertical: 2),
                          child: Card(
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 4,
                                ),
                                Expanded(
                                  flex: 5,
                                  child: TextButton(
                                    onPressed: () async {
                                      item['LAST_SERVER'] = 1;
                                      await DatabaseSystem.insert(
                                          'TB_SERVIDOR', item,
                                          conflictAlgorithm:
                                              ConflictAlgorithm.replace);

                                      setState(() {});
                                    },
                                    child: Row(
                                      children: [
                                        if (item['LAST_SERVER'] == 1)
                                          Row(
                                            children: const [
                                              IconSmall(Icons.done),
                                              SizedBox(
                                                width: 8,
                                              )
                                            ],
                                          ),
                                        Flexible(
                                            child: TextTitle(item['APELIDO'])),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  flex: 1,
                                  child: TextButton(
                                      onPressed: () {
                                        item['LAST_SERVER'] = 1;

                                        mostrarCaixaConfirmacao(context,
                                                title: 'Servidor',
                                                content:
                                                    'Deseja Realmente deletar? isso você ainda poderá adicionar depois')
                                            .then((value) {
                                          if (value) {
                                            DatabaseSystem.delete('TB_SERVIDOR',
                                                    where: 'ID_LOCAL = ?',
                                                    whereArgs: [item['ID_LOCAL']])
                                                .then(
                                                    (value) => setState(() {}));
                                          }
                                        });
                                      },
                                      child: const Center(
                                          child: IconSmall(Icons.remove))),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
            ),
          ],
        ),
        barChildrens: //[ButtonSalvar(enabled: true, onPressed: savarTudo)]
            const [],
      ),
    );
  }
}

Future<List<Map<String, dynamic>>> getServidores() async {
  try {
    final list = await DatabaseSystem.select('TB_SERVIDOR');

    return list;
  } catch (e) {
    return [];
  }
}
