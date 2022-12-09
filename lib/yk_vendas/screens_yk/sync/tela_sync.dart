import 'package:flutter/material.dart';

import 'sync_download_viewer.dart';
import 'sync_loader_viwer.dart';

class TelaSync extends StatefulWidget {
  const TelaSync({Key? key, required this.onFinish}) : super(key: key);

  final Function onFinish;

  @override
  State<TelaSync> createState() => _TelaSyncState();
}

class _TelaSyncState extends State<TelaSync> {
  bool downloading = true;

  final downloader = GlobalKey<SyncDownloaderViewerState>();

  @override
  Widget build(BuildContext context) {
    Widget child = Container();

    if (downloading) {
      child = SyncDownloaderViewer(
        key: downloader,
        onFinish: () {
          setState(() {
            downloading = false;
          });
        },
      );
    } else {


      child = SyncLoaderViewer(
        onFinish: () {
          widget.onFinish();
        },
      );
    }

    return MaterialApp(
      // textDirection: TextDirection.ltr,
      home: Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text('Sincronizando'),
          ),
        ),
        body: Center(
          child: child,
        ),
      ),
    );
  }
}
