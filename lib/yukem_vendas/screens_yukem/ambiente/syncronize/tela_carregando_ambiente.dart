import 'package:flutter/material.dart';
import '../../../../api/common/components/list_scrollable.dart';
import '../../../../api/common/custom_widgets/custom_icons.dart';
import '../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../api/models/system_database/system_database.dart';
import '../../../models/configuracao/app_user.dart';
import '../../../models/internet/sync_dados.dart';
import '../../yukem_foundation.dart';

class TelaSyncAmbiente extends StatefulWidget {
  //TODO: Implementação de ScreenID para configurar a exibição de telas

  final int screenId = 0;

  const TelaSyncAmbiente({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TelaSyncAmbienteState();
}

class _TelaSyncAmbienteState extends State<TelaSyncAmbiente> {
  bool canImp = true;
  bool onSync = false;
  bool onError = false;
  double progress = 0;

  String? loadingMessage;
  String errorMessage = "";

  double mainPrg = 0;
  double curPrg = 0;

  @override
  Widget build(BuildContext context) {

    setAmbienteToSync() async {
      await DatabaseSystem.update('TB_AMBIENTES', {'TO_SYNC': 0},
          where: 'NOME = ?', whereArgs: [AppUser.of(context).ambiente]);
    }

    importTick(String table, double x, double y, bool b) {
      mainPrg = x;
      curPrg = y;

      if (b) {
        setState(() {
          loadingMessage = table;
        });
      }
    }

    importFinish() {
      mainPrg = 0;
      curPrg = 0;

      setAmbienteToSync();

      YokemFoundation.performYukemRestart(context, app: true);

      // setState(() {
      //   onSync = false;
      //   loadingMessage = null;
      // });
    }

    bool onFail(e) {
      setState(() {
        // onSync = false;
        // errorMessage = e.toString();
        // onError = true;
      });

      return true;
    }

    Future syncronize() async {
      // await


      onSync = true;
      loadingMessage = 'Iniciando';
      importarTudo(
          context: context,
          onTick: importTick,
          onSucces: importFinish,
          forcar: true,
          onFail: onFail);
    }

    syncronize();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sincronização'),
      ),
      body: Center(
        child: ListView(
          children: [
            if (loadingMessage != null && !onError)
              Card(
                child: ListViewNested(children: [
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                  Center(
                    child: TextTitle(loadingMessage!),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: ListViewNested(children: [
                      Center(
                        child: LinearProgressIndicator(value: mainPrg),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Center(
                        child: LinearProgressIndicator(value: curPrg),
                      )
                    ]),
                  )
                ]),
              ),
            if (onError)
              Card(
                child: ListViewNested(children: [
                  const Center(
                    child: IconBig(Icons.error),
                  ),
                  Center(
                    child: TextTitle(errorMessage),
                  ),
                ]),
              ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> list = [];
}
