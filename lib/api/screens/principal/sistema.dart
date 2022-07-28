import 'package:flutter/material.dart';
import 'package:forca_de_vendas/api/screens/support/screen_loading.dart';
import 'package:forca_de_vendas/yukem_vendas/models/database/database_update.dart';
import 'package:provider/provider.dart';

import '../../../yukem_vendas/app_foundation.dart';
import '../../models/configuracao/app_system.dart';
import '../../models/system_database/system_database.dart';

const String version = '0.1.1';

class Sistema extends StatefulWidget {
  const Sistema({Key? key}) : super(key: key);

  static performHotRestart(BuildContext context) {
    final _SistemaState? state =
        context.findAncestorStateOfType<_SistemaState>();

    if (state != null) {
      state.performHotRestart();
    }
  }

  @override
  State<StatefulWidget> createState() => _SistemaState();
}

class _SistemaState extends State<Sistema> {
  late Key keySistema;
  AppSystem? appSystem;

  void performHotRestart() {
    // init();
  }

  Future init() async {
    try {
      await updateSysDatabase();
      await DatabaseSystem.reloadDatabase();
      Future.delayed(const Duration(milliseconds: 250));
      final app = await AppSystem.getAppMaps();

      setState(() {
        keySistema = UniqueKey();
        appSystem = AppSystem.fromMap(app);
      });
    } catch (e) {}
  }

  @override
  initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      init();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (appSystem != null) {
      return Provider<AppSystem>(
        create: (_) => appSystem!,
        builder: (BuildContext context, Widget? widget) {
          return Container(
            key: keySistema,
            child: const Application(),
          );
        },
      );
    }

    return ScreenLoading(
      children: [
        Text('Inicializando sistema ${(appSystem ?? '').toString()}'),
      ],
    );
  }
}
