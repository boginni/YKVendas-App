import 'package:flutter/material.dart';

import '../../../api/common/components/list_scrollable.dart';
import '../../../api/common/custom_widgets/custom_text.dart';
import '../../../api/common/debugger.dart';
import '../../../api/models/system_database/system_database.dart';
import '../../models/configuracao/app_user.dart';
import '../../models/database/db_backup.dart';
import '../../models/file/file_manager.dart';
import 'sync_loader.dart';

class SyncLoaderViewer extends StatefulWidget {
  const SyncLoaderViewer({Key? key, required this.onFinish}) : super(key: key);

  final Function onFinish;

  @override
  State<SyncLoaderViewer> createState() => _SyncLoaderViewerState();
}

class _SyncLoaderViewerState extends State<SyncLoaderViewer>
    implements SyncLoaderListener {
  SyncLoader? sync;
  String loadingMessage = '';
  double progress = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      load();
    });
  }

  String? error;

  void load() async {
    final ambiente = AppUser.of(context).ambiente;

    // await DatabaseSystem.update('TB_AMBIENTES', {'TO_SYNC': 1},
    //     where: 'NOME = ?', whereArgs: [ambiente]);

    final filePath = await FilePath.getSyncFilePath(ambiente);

    setState(() {
      try {
        sync = SyncLoader(this, filePath).unPack();
      } catch (e) {
        error = "Arquivo de Sincronização é inválido";
        printDebug(e);
      }
    });

    if(error != null){
      SyncLoader(this, filePath).unPack();
    }

    sync!.syncAll().then((value) async {
      setState(() {
        DatabaseSystem.insert('TB_AMBIENTES',
            {'TO_SYNC': 0, 'NOME': AppUser.of(context).ambiente});
      });

      DatabaseBackup.restoreBackup().then((value) {
        widget.onFinish();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Text(error!);
    }

    if (sync == null) {
      return const Text('Descompactando');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListViewNested(children: [
        // Center(
        //   child: CircularProgressIndicator(),
        // ),
        Center(
          child: TextTitle(loadingMessage),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ListViewNested(
            children: [
              Center(
                child: LinearProgressIndicator(value: progress),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  @override
  onError(Object e) {
    printDebug(e);
  }

  @override
  onProgress(String table, int current, int total) {
    setState(() {
      loadingMessage = table;
      progress = current / total;
    });
  }
}
