import 'package:flutter/material.dart';
import 'package:forca_de_vendas/api/common/debugger.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/sync/sync_request.dart';
import 'package:ionicons/ionicons.dart';

import '../../app_foundation.dart';
import '../../models/configuracao/app_user.dart';

class SyncDownloaderViewer extends StatefulWidget {
  const SyncDownloaderViewer({Key? key, required this.onFinish})
      : super(key: key);

  final Function onFinish;

  @override
  State<SyncDownloaderViewer> createState() => SyncDownloaderViewerState();
}

class SyncDownloaderViewerState extends State<SyncDownloaderViewer>
    implements SyncRequestListener {
  late SyncRequest sync;

  download() async {
    if (sync.isDownloading) {
      printDebug('já está baixando');
      return;
    }
    cor = null;
    sync = SyncRequest(this);
    // sync.fullRotas();
    if (AppUser.of(context).fullsync) {
      sync.fullViews();
      AppUser.of(context).fullsync = false;
    } else {
      await sync.lastUpdate();
    }

    sync.download(AppUser.of(context));
  }

  @override
  void initState() {
    super.initState();

    sync = SyncRequest(this);
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      download();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: AlignmentDirectional.center,
          children: [
            const Icon(
              Ionicons.server,
              size: 40,
            ),
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: sync.isDownloading ? sync.getProgress() : null,
                strokeWidth: sync.isDownloading ? 18 : 8,
                color: sync.isDownloading ? cor : Colors.grey,
                // valueColor: cor,
              ),
            )
          ],
        ),
        const SizedBox(
          height: 12,
        ),
        if (sync.preparando) const Text('Aguardando Resposta do servidor'),
        if (sync.isDownloading)
          Text(
              '${sync.getCurrentSizeMb().toStringAsFixed(2)} / ${sync.getTotalSizeMb().toStringAsFixed(2)}'),
        TextButton(
          onPressed: () {
            close();
          },
          child: const Text('Cancelar'),
        )
      ],
    );
  }

  close() {
    try {
      sync.client!.close();
      Application.logout(context);
    } catch (e) {
      onError(e);
    }
  }

  Color? cor;

  @override
  void onError(Object e) {
    setState(() {
      cor = Colors.red;
    });
  }

  @override
  void onFinish(List<int> bytes) {
    widget.onFinish();
  }

  @override
  void onPreServerResponse() {
    setState(() {});
  }

  @override
  void onProgress() {
    setState(() {});
  }

  @override
  void onServerResponse() {
    setState(() {});
  }
}
