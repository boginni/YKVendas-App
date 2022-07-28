import 'package:flutter/material.dart';
import 'package:share/share.dart';

import 'cat_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Cat> cats = [
    Cat(
      name: "Gato Rajado",
      description: "Um gato rajado.",
    ),
    Cat(name: "Apollo", description: "Um cachorro que se identifica como gato"),
  ];

  share(BuildContext context, Cat cat) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    final String text = "${cat.name} - ${cat.description}";

    Share.share(
      text,
      subject: cat.description,
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Favourite Cat"),
      ),
      body: Column(
        children: cats
            .map((Cat cat) => Card(
                  child: ListTile(
                    title: Text(cat.name),
                    subtitle: Text(cat.description),
                    onTap: () => share(context, cat),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
