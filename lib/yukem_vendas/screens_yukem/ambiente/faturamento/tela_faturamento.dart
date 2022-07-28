import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forca_de_vendas/api/models/configuracao/app_system.dart';
import 'package:forca_de_vendas/yukem_vendas/models/configuracao/app_ambiente.dart';
import 'package:forca_de_vendas/yukem_vendas/models/configuracao/app_user.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/base/moddel_screen.dart';

import '../../../../api/common/components/list_scrollable.dart';
import '../../../../api/common/custom_widgets/custom_buttons.dart';
import '../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../api/common/form_field/formulario.dart';
import '../../../../api/common/formatter/date_time_formatter.dart';
import '../../../common/custom_tiles/object_tiles/tile_visita.dart';
import '../../../models/database_objects/db_visita_agenda.dart';
import '../../../models/database_objects/visita.dart';
import '../../../models/internet/sync_manager.dart';
import '../base/custom_drawer.dart';
import '../visita/tela_visita/tela_pedido.dart';

class TelaFaturamento extends ModdelScreen {
  const TelaFaturamento({Key? key}) : super(key: key);

  @override
  Widget getCustomScreen(BuildContext context) {
    return const xTelaFaturamento();
  }
}

class xTelaFaturamento extends StatefulWidget {
  const xTelaFaturamento({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TelaFaturamentoState();
  }
}

class _TelaFaturamentoState extends State<xTelaFaturamento> {
  List<Visita> visitas = [];
  final ScrollController _scrollController = ScrollController();
  final _pesquisaController = TextEditingController();
  DateTime? dataVisita = DateTime.now();

  bool pesquisar = false;

  late final AppSystem appSystem;
  late final AppAmbiente appAmbiente;
  late final AppUser appUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    appSystem = AppSystem.of(context);
    appAmbiente = AppAmbiente.of(context);
    appUser = AppUser.of(context);
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      updateAndSearch();
    });
  }

  Future updateAndSearch() async {
    setup().then((value) {
      setState(() {
        visitas = value;
      });
    });
  }

  adicionar() {
    insertVisitaAgenda(0, 0,
            faturamento: true, idVendedor: appUser.vendedorAtual)
        .then(
      (value) {
        Navigator.of(context)
            .pushNamed(getRedirectRouteName(), arguments: value)
            .then(
          (value) {
            updateAndSearch().then(
              (value) {
                SyncHandler.sincronizar(show: false, context: context)
                    .then((value) => updateAndSearch());
              },
            );
          },
        );
      },
    );
  }

  String getRedirectRouteName() {
    String r = TelaPedido.routeName;
    return r;
  }

  Future<List<Visita>> setup() async {
    final field =
        appAmbiente.buscaClientId ? 'ID_PESSOA_SYNC =' : 'CPF_CNPJ like';

    final filter = '(NOME like ? or APELIDO like ? or $field ?)';

    String args = 'ID_ROTA = ? and TIPO = ?';

    List<dynamic> param = [0, 0];

    if (dataVisita != null) {
      args += ' and CRIACAO like ?';
      param.add('${DateFormatter.databaseDate.format(dataVisita!)}%');
    }

    String x = _pesquisaController.text;
    if (x.isNotEmpty) {
      args += ' and $filter';

      param.add('%$x%');
      param.add('%$x%');
      param.add(appAmbiente.buscaClientId ? x : '%$x%');
    }

    if (!(appAmbiente.usarFirma &&
            appUser.vendedorAtual == appAmbiente.firma) &&
        appAmbiente.usarFiltroClienteVendedor) {
      args += ' and ID_VENDEDOR = ? ';
      param.add(appUser.vendedorAtual);
    }

    return Visita.getListVisitas2(args, param);
  }

  @override
  Widget build(BuildContext context) {
    String field = appAmbiente.buscaClientId ? 'Id' : ' CPF/CNPJ';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Faturamento'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: InkWell(
              onTap: () => adicionar(),
              child: const Icon(Icons.add, size: 26.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: InkWell(
              onTap: () {
                setState(() {
                  pesquisar = !pesquisar;
                });
              },
              child: const Icon(Icons.search, size: 26.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: InkWell(
              onTap: () {
                SyncHandler.sincronizar(show: true, context: context)
                    .then((value) => updateAndSearch());
              },
              child: const Icon(Icons.sync, size: 26.0),
            ),
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: ListView(
        shrinkWrap: true,
        children: [
          if (pesquisar)
            Card(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListViewNested(children: [
                  /// Filtros
                  const SizedBox(
                    height: 16,
                  ),
                  const TextTitle('Data da Visita'),
                  Row(
                    children: [
                      Expanded(
                        child: FormDatePicker(
                            initialDate: DateTime.now(),
                            firstDate:
                                DateTime.now().add(const Duration(days: -30)),
                            lastDate: DateTime.now(),
                            startingDate: dataVisita,
                            then: (DateTime? date) {
                              if (date != null) {
                                dataVisita = date;
                                if (appSystem.usarPesquisaDinamica) {
                                  updateAndSearch();
                                }
                              }
                            },
                            hint: 'Data da Visita'),
                      ),
                      ButtonIcon(
                        onPressed: () {
                          dataVisita = null;
                          if (appSystem.usarPesquisaDinamica) {
                            updateAndSearch();
                          }
                        },
                        icon: CupertinoIcons.clear_circled_solid,
                      ),
                    ],
                  ),
                  const TextTitle('Pesquisar'),
                  TextFormField(
                    controller: _pesquisaController,
                    onChanged: (x) {
                      if (appSystem.usarPesquisaDinamica) {
                        updateAndSearch();
                      }
                    },
                    decoration:
                        InputDecoration(hintText: 'Nome, Apelido ou $field'),
                  ),

                  ElevatedButton(
                      onPressed: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        // mostrarPesquisa = false;
                        updateAndSearch();
                      },
                      child: const TextNormal("Pesquisar")),
                ]),
              ),
            ),
          ListView.builder(
            itemCount: visitas.length,
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              final item = visitas[index];
              return TileVisita(
                visita: item,
                redirect: getRedirectRouteName(),
                afterUpdate: (visita) {
                  setState(() {
                    visitas[index] = visita;
                    SyncHandler.sincronizar(context: context).then((value) {
                      updateAndSearch();
                    });
                  });
                },
                onPressed: () {
                  return false;
                },
                afterRemove: () {
                  updateAndSearch();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
