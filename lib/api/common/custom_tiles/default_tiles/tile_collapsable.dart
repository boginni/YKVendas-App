import 'package:flutter/material.dart';
import 'package:forca_de_vendas/api/common/components/list_scrollable.dart';

class TileCollapsable extends StatelessWidget {
  final Widget title;

  final List<Widget> children;

  final bool collapsable;

  final bool alwaysExpanded;

  final bool initiallyExpanded;

  const TileCollapsable(
      {Key? key,
      required this.title,
      this.children = const <Widget>[],
      this.collapsable = true,
      this.alwaysExpanded = false,
      required this.initiallyExpanded})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (alwaysExpanded) {
      return Card(child: ListViewNested2(children: children, title: title));
    }

    if (collapsable && children.isNotEmpty) {
      return Card(
        child: ExpansionTile(
          title: title,
          initiallyExpanded: initiallyExpanded,
          children: children,
        ),
      );
    }

    return title;
  }
}
