import 'package:flutter/material.dart';

class TelaMetas extends StatefulWidget{

  static const String routeName = 'telaMetas';
  const TelaMetas({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => TelaMetasState();
}

class TelaMetasState extends State<TelaMetas>{

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {



    return Scaffold(
      appBar: AppBar(title: const Text('Metas'),),

      body: ListView(

        children: const [
          Text('Tela de Metas')
        ],


      ),

    );

  }




}