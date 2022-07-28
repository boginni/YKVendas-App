import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/configuracao/app_user.dart';
import 'ambiente/ambiente_foundation.dart';
import 'databa_update_viewer.dart';
import 'sync/tela_sync.dart';

class YokemFoundation extends StatefulWidget {
  const YokemFoundation({Key? key, required this.appUser}) : super(key: key);

  static performYukemRestart(BuildContext context,
      {bool app = false, bool toSync = false}) {
    final _AmbienteState? state =
        context.findAncestorStateOfType<_AmbienteState>();

    if (state != null) {
      if (app) {
        state.toSync = false;
      }
      state.toSync = toSync;
      state.performHotRestart();
    }
  }

  @override
  State<StatefulWidget> createState() => _AmbienteState();

  final AppUser appUser;
}

class _AmbienteState extends State<YokemFoundation> {
  Key keyAmbiente = UniqueKey();

  void performHotRestart() {
    setState(() {
      keyAmbiente = UniqueKey();
    });
  }

  bool toSync = true;
  bool databaseReady = false;

  @override
  void initState() {
    super.initState();
    toSync = !widget.appUser.offline;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: keyAmbiente,
      child: Provider<AppUser>(
        create: (BuildContext context) {
          return widget.appUser;
        },
        child: Builder(
          builder: ((context) {
            if (!databaseReady) {
              return MaterialApp(
                home: DatabaseUpdateViwer(
                  ambiente: widget.appUser.ambiente,
                  onFinish: (fullSync) {
                    setState(() {
                      widget.appUser.fullsync = fullSync;
                      databaseReady = true;
                    });
                  },
                ),
              );
            }

            if (databaseReady && toSync) {
              return TelaSync(
                onFinish: () async {
                  setState(() {
                    toSync = false;
                  });
                },
              );
            }

            return const AmbienteFoundation();
          }),
        ),
      ),
    );
  }
}
