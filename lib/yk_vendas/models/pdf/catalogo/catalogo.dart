import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../database_objects/produtos_list_item.dart';
import '../pdf_pedido.dart';
import 'relatorio.dart';

Future gerarCatalogo(List<ProdutoListItem> itens) async {
  final directory = (await getApplicationDocumentsDirectory()).path;
  final filePath = '$directory/catalogo.pdf';
  final file = File(filePath);
  await file.writeAsBytes(await getRelarioBytes(itens));
  return await sharePDF(filePath);
}
