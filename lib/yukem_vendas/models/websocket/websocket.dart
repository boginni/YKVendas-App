import 'package:flutter/cupertino.dart';
import 'package:forca_de_vendas/yukem_vendas/models/database/database_ambiente.dart';

import '../../../api/common/components/mostrar_confirmacao.dart';
import '../../../api/models/interface/realtime_sync.dart';
import '../../screens_yukem/sync/sync_loader.dart';
import '../../screens_yukem/sync/sync_request.dart';
import '../../screens_yukem/yukem_foundation.dart';
import '../configuracao/app_user.dart';
import '../file/file_manager.dart';

class WebsockeEvent {
  static updateDatabaseEvent(
      BuildContext context, List<dynamic> triggerList) async {
    for (final String evn in triggerList) {
      final mapL = await DatabaseAmbiente.select('SYS_EVENTS',
          where: 'NOME = ?', whereArgs: [evn]);

      await _updateDatabaseEventHandler(context, evn, () {
        RealTimeSync.postEvent([mapL[0]['ID']]);
      });
    }
  }

  static _updateDatabaseEventHandler(
      BuildContext context, String evn, Function() callBack) async {
    switch (evn) {
      case 'MOB_CONF_AMBIENTE_UPDATE':
        mostrarCaixaConfirmacao(context,
                mostrarCancelar: false,
                title: "Atualização de parametros",
                content:
                    "O operador do sistema fez alteração nos parâmetros de funcionalidade do app, será necessário sincronizar novamente")
            .then((value) {
          YokemFoundation.performYukemRestart(context, toSync: true);
        });
        break;
      default:
        final res = await DatabaseAmbiente.select('VW_SYS_DB_UPDATE',
            where: 'NOME = ?', whereArgs: [evn]);

        final appUser = AppUser.of(context);
        final downloader = SyncRequest(SyncRequest.emptyListener);

        for (final row in res) {
          downloader.addItem(row['NOME_ARQUIVO'], row['DATA_LAST_UPDATE']);
        }

        await downloader.download(appUser, onFinished: (err) async {
          if (err != null) {
            return;
          }

          final loader = SyncLoader(SyncLoader.emptyListener,
              await FilePath.getSyncFilePath(appUser.ambiente));

          loader.unPack();

          await loader.syncAll();

          callBack();
        });

        break;
    }
  }
}
