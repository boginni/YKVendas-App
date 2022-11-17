import 'package:flutter/material.dart';
import 'package:forca_de_vendas/yukem_vendas/screens_yukem/ambiente/base/custom_drawer.dart';

class TelaHome extends StatefulWidget {
  const TelaHome({Key? key}) : super(key: key);

  @override
  State<TelaHome> createState() => _TelaHomeState();
}

class _TelaHomeState extends State<TelaHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: CustomDrawer(),
    );
  }
}
