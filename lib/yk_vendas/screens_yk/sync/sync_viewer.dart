import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../api/common/components/list_scrollable.dart';
import '../../../api/common/components/mostrar_confirmacao.dart';
import '../../../api/common/custom_widgets/custom_text.dart';
import '../../app_foundation.dart';
import '../../models/database/database_update.dart';
import '../../models/database/db_backup.dart';
import '../../models/internet/sync_dados.dart';
import '../yk_foundation.dart';

class SyncViewer extends StatefulWidget {
  const SyncViewer({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SyncViewerState();
}

class SyncViewerState extends State<SyncViewer> {
  String loadingMessage = '';
  String errorMessage = "";

  double mainPrg = 0;
  double curPrg = 0;

  int attemps = 0;
  bool onError = false;
  bool onSync = false;

  bool started = false;
  bool finish = false;

  @override
  void initState() {
    super.initState();
    update() {
      try {
        setState(() {});
      } catch (e) {
        onSync = false;
      }
    }

    importTick(String table, double x, double y, bool b) {
      if (b) {
        onError = false;
        attemps = 0;
        curPrg = y;
      }
      mainPrg = x;

      loadingMessage = table;
      update();
    }

    importFinish() async {
      await DatabaseBackup.restoreBackup();

      onError = false;
      finish = true;
      mainPrg = 0;
      curPrg = 0;
      YKFoundation.performRestart(context, app: true);
      onSync = false;
      loadingMessage = '';
      // update();
    }

    bool onFail(e) {
      // printDebug('error');
      attemps++;

      onError = true;

      if (attemps >= 5) {
        onSync = false;
        Application.logout(context);
      }

      update();
      return onSync;
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      bool cancelado = false;

      if (!started) {
        started = true;
        onSync = true;
        onError = false;

        updateAmbienteDatabase(onSaveData: () async {
          bool value = await mostrarCaixaConfirmacao(context,
              title: 'AVISO IMPORTANTE',
              content:
                  'Você possue pedidos não sincronizados, não é recomendado atualizar app com vendas em aberto. deseja mesmo continuar?');
          cancelado = !value;
          return value;
        }).then((value) {
          if (value) {
            importarTudo(
                context: context,
                // forcar: true,
                onTick: importTick,
                onSucces: importFinish,
                onFail: onFail);
          } else {
            if (!cancelado) {
              mostrarCaixaConfirmacao(context,
                      mostrarCancelar: false,
                      title: 'Erro na criação de backup de dados',
                      content:
                          'Verifique se há espaço disponível ou entre em contato com o suporte')
                  .then((value) {
                Application.logout(context);
                return;
              });
            }
            Application.logout(context);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!finish) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ListViewNested(children: [
          const Center(
            child: CircularProgressIndicator(),
          ),
          Center(
            child: TextTitle(loadingMessage),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ListViewNested(
              children: [
                Center(
                  child: LinearProgressIndicator(value: mainPrg),
                ),
                const SizedBox(
                  height: 8,
                ),
                Center(
                  child: LinearProgressIndicator(
                    value: curPrg,
                    color: onError ? Colors.red : null,
                  ),
                )
              ],
            ),
          )
        ]),
      );
    }

    if (finish) {
      return const Center(
        child: TextNormal('Finalizado'),
      );
    }

    return const Center(
      child: TextNormal('?'),
    );
  }
}
