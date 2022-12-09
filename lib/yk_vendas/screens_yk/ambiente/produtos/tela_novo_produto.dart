
import 'package:flutter/material.dart';

class TelaNovoProduto extends StatelessWidget {
  // const TelaNovoProduto();

  static const routeName = '/telaNovoProduto';

  const TelaNovoProduto({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    // final ProdutoDet produto = ProdutoDet();
    // final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Produto'),
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pop(context);
          },
        ),
      ),
      body: const Card(
          child: Text('Tela Desativada')

        // Form(
        //   key: formKey,
        //   child: ListView(
        //     shrinkWrap: true,
        //     children: <Widget>[
        //       FormText(
        //           title: "ID",
        //           saveFunction: (text) {
        //             produto.idProduto = int.parse(text.toString());
        //           }),
        //       FormText(
        //           title: "Nome",
        //           saveFunction: (text) {
        //             produto.nome = text;
        //           }),
        //       ElevatedButton(
        //         onPressed: () async {
        //           if (formKey.currentState!.validate()) {
        //             // printDebug("Campos Validados");
        //
        //             formKey.currentState!.save();
        //
        //             onSuccess() {
        //               Navigator.of(context).pop(context);
        //             }
        //
        //             onFail() {
        //               printDebug('Não implementado');
        //             }
        //
        //             await insertProduto(produto, onSuccess, onFail);
        //           }
        //         },
        //         child: const Text(
        //           "Adicionar",
        //           style: TextStyle(fontSize: 18),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),

      ),
    );
  }
}


