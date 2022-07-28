import 'package:flutter/material.dart';

class TelaVazia extends StatefulWidget {
  const TelaVazia({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => TelaVaziaState();
}

class TelaVaziaState extends State<TelaVazia> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }
}
