
import 'package:flutter/material.dart';
import '../base/custom_drawer.dart';
import '../../../common/custom_tiles/object_tiles/tile_graph.dart';
import '../../../models/database_objects/graph.dart';
import '../base/moddel_screen.dart';


class TelaGraficos extends ModdelScreen {
  const TelaGraficos({Key? key}) : super(key: key);

  @override
  Widget getCustomScreen(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Gráficos')),
        drawer: const CustomDrawer(),
        body: FutureBuilder(
          future: getGraphList(),
          builder: (BuildContext context, AsyncSnapshot<List<Graph>> snapshot) {
            if (snapshot.hasData) {
              List<Graph> itens = snapshot.data!;

              if (itens.isEmpty) {
                return const Text("Não existem registros a serem carregados!");
              }

              return ListView.builder(
                itemCount: itens.length,
                itemBuilder: (BuildContext context, int index) {
                  return TileGraph(itens[index]);
                },
              );
            }

            return const Text("Carregando Registros");
          },
        ));
  }
}