import 'package:flutter/cupertino.dart';

import '../../../../api/common/custom_widgets/custom_buttons.dart';
import '../../../../api/common/custom_widgets/icon_dynamic.dart';
import '../../../models/database_objects/graph.dart';

class TileGraph extends StatelessWidget {
  const TileGraph(this.graph, {Key? key}) : super(key: key);

  final Graph graph;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    const icon = IconDynamic(
      primary: CupertinoIcons.graph_circle,
      secondary: CupertinoIcons.graph_circle_fill,
      size: 24,
    );

    onClick() {
      throw UnimplementedError();
    }

    return ButtonIconCustom(
      icon: icon,
      name: graph.nome,
      onClickFunction: onClick,
    );
  }
}
