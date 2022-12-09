import 'package:flutter/material.dart';

class TelaDesempenho extends StatefulWidget{

  static const String routeName = 'telaDesempenho';

  const TelaDesempenho({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => TelaDesempenhoState();

}

class TelaDesempenhoState extends State<TelaDesempenho>{


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {



    return Scaffold(
      appBar: AppBar(title: const Text('Desempenho'),),

      body: ListView(

        children: const [
          Text('Tela de Metas')
        ],
      ),

    );

  }




}