import 'package:flutter/material.dart';
import 'package:forca_de_vendas/api/common/components/barra_progresso.dart';
import 'package:forca_de_vendas/api/models/interface/realtime_sync.dart';
import 'package:forca_de_vendas/yukem_vendas/models/internet/sync_rota.dart';
import 'package:provider/provider.dart';

import '../../../../api/models/page_manager.dart';
import '../../../common/custom_tiles/object_tiles/tile_rota.dart';
import '../../../models/configuracao/app_user.dart';
import '../../../models/database_objects/rota.dart';
import '../base/custom_drawer.dart';

class TelaRotas extends StatefulWidget {
  const TelaRotas({Key? key}) : super(key: key);

  @override
  State<TelaRotas> createState() => _TelaRotasState();
}

class _TelaRotasState extends State<TelaRotas> implements RealTimeSync {
  List<Rota> list = [];

  getData() {
    final appUser = AppUser.of(context);

    Rota.getRotas(appUser.vendedorAtual).then((value) {
      setState(() {
        list = value;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      RealTimeSync.addListener(this);
      getData();
    });
  }

  @override
  void dispose() {
    super.dispose();
    RealTimeSync.removeListener(this);
  }

  @override
  void onEvent(List<int> events) {
    bool toUp = false;

    for (final i in events) {
      if (i == 7) {
        toUp = true;
      }
    }

    if (!toUp) {
      return;
    }

    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rotas'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: InkWell(
              onTap: () {
                final key = mostrarBarraProgressoCircular(context);

                Future.delayed(const Duration(milliseconds: 500))
                    .then((value) async {
                  await syncRota(context);

                  key.currentState!.finish();
                });
              },
              child: const Icon(Icons.sync, size: 26.0),
            ),
          )
        ],
      ),
      drawer: const CustomDrawer(),
      body: ListView.builder(
        itemCount: list.length,
        itemBuilder: (BuildContext context, int i) {
          Rota rota = list[i];

          onPress() {
            Provider.of<Rota>(context, listen: false).id = rota.id;
            Provider.of<Rota>(context, listen: false).nome = rota.nome;
            // await setAmbienteConfig(16, rota.id);
            syncRota(context);
            context.read<PageManager>().setPage(0);
          }

          return TileRota(rota, onPress);
        },
      ),
    );
  }
}
