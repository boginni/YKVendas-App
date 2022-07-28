import 'package:flutter/material.dart';
import 'package:forca_de_vendas/api/common/components/barra_progresso.dart';
import 'package:forca_de_vendas/yukem_vendas/models/internet/sync_rota.dart';
import 'package:provider/provider.dart';

import '../../../../api/common/custom_widgets/custom_text.dart';
import '../../../../api/models/page_manager.dart';
import '../../../common/custom_tiles/object_tiles/tile_rota.dart';
import '../../../models/configuracao/app_ambiente.dart';
import '../../../models/configuracao/app_user.dart';
import '../../../models/database_objects/rota.dart';
import '../base/custom_drawer.dart';
import '../base/moddel_screen.dart';

class TelaRotas extends ModdelScreen {
  const TelaRotas({Key? key}) : super(key: key);

  @override
  Widget getCustomScreen(BuildContext context) {
    final appUser = AppUser.of(context);

    List<Rota> list = [];

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
        body: FutureBuilder(
          future: Rota.getRotas(appUser.vendedorAtual),
          builder: (BuildContext context, AsyncSnapshot<List<Rota>> snapshot) {
            if (snapshot.data != null) {
              list = snapshot.data!;
            }

            if (list.isEmpty) {
              return const Center(
                  child:
                      TextNormal('Não existem registros a serem carregados!'));
            }

            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (BuildContext context, int i) {
                Rota rota = list[i];

                onPress() async {
                  Provider.of<Rota>(context, listen: false).id = rota.id;
                  Provider.of<Rota>(context, listen: false).nome = rota.nome;
                  await setAmbienteConfig(16, rota.id);
                  syncRota(context);
                  context.read<PageManager>().setPage(0);
                }

                return TileRota(rota, onPress);
              },
            );
          },
        ));
  }
}
