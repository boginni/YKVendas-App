import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yk_vendas/yk_vendas/screens_login/login_foundation.dart';

import '../api/app/app_connection.dart';
import '../api/app/app_theme.dart';
import 'models/configuracao/app_user.dart';
import 'models/database/database_ambiente.dart';
import 'models/database/db_backup.dart';
import 'models/pdf/catalogo/header.dart';
import 'screens_yk/yk_foundation.dart';

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

  static Future navigate(BuildContext context, Widget screen) async {

    return await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}

class _ApplicationState extends State<Application> {
  Key keyYKVendas = UniqueKey();

  void performHotRestart() {
    setState(() {
      keyYKVendas = UniqueKey();
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
    return MultiProvider(
      providers: [
        Provider<AppTheme>(
          create: (context) {
            return AppTheme();
          },
        ),
        Provider<AppConnection>(
          create: (context) {
            return AppConnection();
          },
        ),
      ],
      child: Builder(
        builder: (BuildContext context) {
          Widget? child;
          child = onLogin
              ? const LoginFoundation()
              : YKFoundation(
                  appUser: appUser!,
                );

          return Container(
            key: keyYKVendas,
            child: child,
          );
        },
      ),
    );
  }
}
