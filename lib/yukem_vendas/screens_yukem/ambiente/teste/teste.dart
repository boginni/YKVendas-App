import 'package:flutter/material.dart';
import 'package:forca_de_vendas/api/common/components/list_scrollable.dart';
import 'package:forca_de_vendas/api/common/custom_widgets/custom_icons.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/base/custom_drawer.dart';
import 'package:share/share.dart';

import '../../../../api/common/custom_widgets/custom_text.dart';
import 'class_teste.dart';

class Teste extends StatefulWidget {
  const Teste({Key? key}) : super(key: key);

  @override
  State<Teste> createState() => _TesteState();
}

class _TesteState extends State<Teste> {
  share(BuildContext context, TesteVenda vendas)  {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    final String text ="ID  = ${vendas.id}, CLIENTE = ${vendas.cliente}";

    Share.share(
      text,
      subject: vendas.cliente,
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: CustomDrawer(),
      body: ListViewNested(
        children: [
          ElevatedButton.icon(
              onPressed: () => share(context, TesteVenda(id: '1', cliente: 'Junin')),
            icon: IconSmall(Icons.share_outlined),
            label: TextNormal("Compartilhar"),

          ),
        ],
      ),
    );
  }
}

