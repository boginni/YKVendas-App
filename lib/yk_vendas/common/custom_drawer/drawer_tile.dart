import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../api/common/debugger.dart';
import '../../../api/models/page_manager.dart';

class DrawerTile extends StatelessWidget {
  final IconData iconData;
  final String title;
  final int page;

  final Function()? onPressed;

  const DrawerTile(
      {Key? key,
      required this.iconData,
      required this.title,
      required this.page,
      this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    final int curPage = context.watch<PageManager>().page;
    final Color primaryColor = Theme.of(context).primaryColor;

    return InkWell(
      onTap: onPressed ??
          () {
            context.read<PageManager>().setPage(page);
          },
      child: SizedBox(
        height: 60,
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Icon(iconData,
                  size: 32,
                  color: curPage == page ? primaryColor : Colors.grey[700]),
            ),
            Text(
              title,
              style: TextStyle(
                  fontSize: 16,
                  color: curPage == page ? primaryColor : Colors.grey[700]),
            )
          ],
        ),
      ),
    );
  }
}
