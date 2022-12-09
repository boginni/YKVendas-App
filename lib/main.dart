import 'package:flutter/material.dart';

import 'api/screens/principal/sistema.dart';
import 'yk_vendas/models/file/file_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // debugPrintStack();

  runApp(const Sistema());
  // runApp(const Test());
}

class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  String txt = 'xxx';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ListView(children: [
          TextButton(
              onPressed: () async {
                final str = await FilePath.getVendaBackupPath('teste');
                setState(() {
                  txt = str;
                });
              },
              child: const Text('Testar')),
          Text(txt)
        ]),
      ),
    );
  }
}
