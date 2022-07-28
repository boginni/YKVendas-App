import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forca_de_vendas/yukem_vendas/models/database/db_backup.dart';
import 'package:forca_de_vendas/yukem_vendas/models/pdf/drawHeader.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_login/login_foundation.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/yukem_foundation.dart';

import 'models/configuracao/app_user.dart';
import 'models/database/database_ambiente.dart';

class Application extends StatefulWidget {
  const Application({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ApplicationState();

  static logIn(BuildContext context,
      {required String uuid,
      required int idVendedor,
      required String ambiente,
      required String vendedor,
      bool offline = false}) {
    final _ApplicationState? state =
        context.findAncestorStateOfType<_ApplicationState>();

    if (state != null) {
      state.iniciarAmbiente(
          ambiene: ambiente,
          uuid: uuid,
          idVendedor: idVendedor,
          vendedor: vendedor,
          offline: offline);
    }
  }

  static logout(BuildContext context) {
    final _ApplicationState? state =
        context.findAncestorStateOfType<_ApplicationState>();

    if (state != null) {
      state.logout();
    }
  }

  static  navigate(
      BuildContext context, Widget screen, {Function? callback}) async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => screen)).then((value) {
      if (callback != null) callback();
    });
  }
}

class _ApplicationState extends State<Application> {
  Key keyYukemVendas = UniqueKey();

  void performHotRestart() {
    setState(() {
      keyYukemVendas = UniqueKey();
    });
  }

  bool onLogin = true;
  AppUser? appUser;

  void logout() {
    onLogin = true;
    performHotRestart();
  }

  void iniciarAmbiente(
      {required String uuid,
      required int idVendedor,
      required String ambiene,
      required String vendedor,
      bool offline = false}) async {
    onLogin = false;

    Map<String, dynamic> maps = {
      "uuid": uuid,
      "idVendedor": idVendedor,
      "ambiente": ambiene,
      'vendedor': vendedor
    };

    DatabaseAmbiente.dbName = ambiene;
    DatabaseBackup.ambiente = ambiene;
    HeaderDrawer.ambiente = ambiene;

    appUser = AppUser.fromMaps(maps);
    appUser!.offline = offline;

    performHotRestart();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        Widget? child;
        child = onLogin
            ? const LoginFoundation()
            : YokemFoundation(
                appUser: appUser!,
              );

        return Container(
          key: keyYukemVendas,
          child: child,
        );
      },
    );
  }
}
