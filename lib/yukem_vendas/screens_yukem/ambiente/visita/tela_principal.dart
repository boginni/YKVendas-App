import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forca_de_vendas/api/common/components/mostrar_confirmacao.dart';
import 'package:forca_de_vendas/api/common/formatter/date_time_formatter.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/encerramento/tela_encerramento_dia.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/visita/tela_visita.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/visita/tela_visita/tela_pedido.dart';
import 'package:provider/provider.dart';

import '../../../../api/common/components/checkbox.dart';
import '../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../api/common/custom_widgets/floating_bar.dart';
import '../../../../api/common/custom_widgets/popupmenu_item_tile.dart';
import '../../../../api/models/configuracao/app_system.dart';
import '../../../common/custom_tiles/object_tiles/tile_visita.dart';
import '../../../models/configuracao/app_ambiente.dart';
import '../../../models/configuracao/app_user.dart';
import '../../../models/database_objects/rota.dart';
import '../../../models/database_objects/visita.dart';
import '../../../models/internet/sync_manager.dart';
import '../base/custom_drawer.dart';
import '../base/moddel_screen.dart';

/*
TODO:
ESSA TELA PRECISA DE UMA REFATORAÇÃO NUCLEAR

 */

//TODO converter para Stateful Widget
class TelaPrincipal extends ModdelScreen {
  const TelaPrincipal({Key? key}) : super(key: key);

  @override
  Widget getCustomScreen(BuildContext context) {
    return _Form();
  }
}

class _Form extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FormState();
}

class _FormState extends State<_Form> {
  List<Visita> visitas = [];
  final ScrollController _scrollController = ScrollController();

  bool mostrarPesquisa = false;
  bool pesquisaSimples = true;

  final _pesquisaController = TextEditingController();

  DateTime? dataVisita = DateTime.now();

  Map<String, dynamic> filtros = {};

  List<CheckBoxItem> listSituacao = [];
  List<CheckBoxItem> listStatus = [];

  bool onTop = true;
  bool onFrist = true;

  late final Rota rota;

  late final AppSystem appSystem;
  late final AppAmbiente appAmbiente;
  late final AppUser appUser;

  @override
  void initState() {
    super.initState();
    rota = context.read<Rota>();
    appSystem = AppSystem.of(context);
    appAmbiente = AppAmbiente.of(context);
    appUser = AppUser.of(context);

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      Visita.criarNovasVisitas(
        DateTime.now(),
        rota.id ?? 0,
        appUser.vendedorAtual,
        appAmbiente,
      ).then((value) => updateAndSearch());
    });
  }

  Future updateAndSearch() async {
    setup().then((value) {
      setState(() {
        visitas = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    String getRedirectRouteName() {
      String r = appAmbiente.usarChegadaCliente
          ? TelaVisita.routeName
          : TelaPedido.routeName;

      return r;
    }

    bool toShow(Visita v) {
      switch (v.getStatus()) {
        case VisitaStatus.aberto:
        case VisitaStatus.edicao:
          return true;
        case VisitaStatus.concluida:
          return appAmbiente.mostrarVisitaConcluida && !encerramentoDia;
        case VisitaStatus.cancelada:
          return appAmbiente.mostrarVisitaCancelada && !encerramentoDia;
        case VisitaStatus.expirada:
          return appAmbiente.mostrarVisitaExpirada;
      }
    }

    Widget _popupMenu() {
      return PopupMenuButton<int>(
        onSelected: (int i) {
          if (i == 3) {
            SyncHandler.sincronizar(show: true, context: context);
          }
        },
        itemBuilder: (context) => [
          TilePopupMenuItem(
              value: 1,
              icon: Icons.search,
              title: 'Pesquisar',
              onPressed: () {
                mostrarPesquisa = !mostrarPesquisa;
                pesquisaSimples = true;
                setState(() {});
              }),
          if (appAmbiente.usarEncerramentoDia)
            TilePopupMenuItem(
                value: 2,
                icon: Icons.calendar_today_outlined,
                title: 'Encerramento do Dia',
                onPressed: () {
                  setState(() {
                    encerramentoDia = !encerramentoDia;
                    if (!encerramentoDia) {
                      selecionados = {};
                    }
                  });
                }),
          TilePopupMenuItem(
              value: 3,
              icon: Icons.sync,
              title: 'Sincronizar',
              onPressed: () {}),
        ],
        child: const Padding(
          padding: EdgeInsets.only(right: 20),
          child: Icon(
            Icons.more_vert_outlined,
            size: 26.0,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: (mostrarPesquisa && pesquisaSimples)
            ? Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: TextField(
                        controller: _pesquisaController,
                        onChanged: (s) {
                          if (appSystem.usarPesquisaDinamica) {
                            updateAndSearch();
                          }
                        }),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Flexible(
                    flex: 1,
                    child: InkWell(
                      child: const Icon(Icons.search),
                      onTap: () {
                        updateAndSearch();
                      },
                    ),
                  )
                ],
              )
            : Text(
                rota.nome == '' ? 'Selecione uma rota' : "Rota: " + rota.nome!),
        actions: <Widget>[
          _popupMenu(),
        ],
      ),
      drawer: const CustomDrawer(),
      body: BodyFloatingBar(
          barChildrens: [
            if (encerramentoDia)
              TextButton(
                  onPressed: () {
                    for (final item in visitas) {
                      selecionados[item.id] = item;
                    }
                    setState(() {});
                  },
                  child: const TextNormal('Selecionar todos')),
            if (encerramentoDia)
              TextButton(
                  onPressed: () {
                    if (selecionados.isEmpty) {
                      mostrarCaixaConfirmacao(context,
                          mostrarCancelar: false,
                          title: 'Selecione os clientes',
                          content:
                              'Precisa selecionar pelo menos um cliente para fazer o cancelamento');
                      return;
                    }
                    Navigator.of(context)
                        .pushNamed(TelaEncarramentoDia.routeName,
                            arguments: selecionados)
                        .then((value) {
                      if (value == true) {
                        selecionados.clear();
                        encerramentoDia = false;
                        updateAndSearch();
                      }
                    });
                  },
                  child: const TextNormal('Cancelar visitas'))
          ],
          child: ListView.builder(
            itemCount: visitas.length,
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              final item = visitas[index];
              final key = GlobalKey();
              return TileVisita(
                key: key,
                visita: item,
                encerramentoDia: encerramentoDia,
                selected: selecionados[item.id] != null,
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
                  if (!encerramentoDia) {
                    return false;
                  }

                  final exists = selecionados[item.id] != null;

                  if (exists) {
                    selecionados.remove(item.id);
                    return false;
                  } else {
                    selecionados.addAll({item.id: item});
                    return true;
                  }
                },
              );
            },
          )),
    );
  }

  /// Inicia a tela e faz pesquisas
  Future<List<Visita>> setup() async {
    if (listSituacao.isEmpty) {
      listSituacao += await checkBoxFrom(
          tableName: 'TB_VISITA_STATUS', defaultChecked: true);
    }

    if (listStatus.isEmpty) {
      listStatus
          .add(CheckBoxItem(texto: 'Sincronizado', checked: true, value: '1'));
      listStatus.add(CheckBoxItem(texto: 'Local', checked: true, value: '0'));
    }

    final field =
        appAmbiente.buscaClientId ? 'ID_PESSOA_SYNC =' : 'CPF_CNPJ like';

    final filter = '(NOME like ? or APELIDO like ? or $field ?)';

    String args =
        'ID_ROTA = ? and CLIENTE_STATUS = ? and TIPO = ? and CRIACAO like ?';

    List<dynamic> param = [
      rota.id,
      1,
      1,
      '${DateFormatter.databaseDate.format(dataVisita!)}%'
    ];
    String x = _pesquisaController.text;
    if (x.isNotEmpty) {
      args += ' and ${filter}';

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

  Map<int, Visita> selecionados = {};
  bool encerramentoDia = false;
}
