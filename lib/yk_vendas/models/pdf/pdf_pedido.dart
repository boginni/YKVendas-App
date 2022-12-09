import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share/share.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../../api/common/debugger.dart';
import '../database/database_ambiente.dart';
import '../database_objects/cliente.dart';
import '../database_objects/contato.dart';
import '../database_objects/pedido_item.dart';
import '../database_objects/totais_pedido.dart';
import '../database_objects/visita.dart';
import 'drawFotter.dart';
import 'drawGrid.dart';
import 'drawHeader.dart';
import 'pdf_common.dart';

Future<void> gerarRelatorio(final int idVisita,
    {required bool formato, String? pessoaNome}) async {
  final dados = await _getDados(idVisita, pessoaNome);

  final directory = (await getApplicationDocumentsDirectory()).path;

  // String uuid = const Uuid().v1();
  // final filePath = '$directory/$uuid.$formato';

  final filePath = '$directory/documento.pdf';

  final file = File(filePath);

  await file.writeAsBytes(await dados.getRelarioBytes());

  if (formato) {
    return await sharePDF(filePath);
  }
  return await shareImage(filePath);
}


Future<void> salvarBackup(final int idVisita,
    {required bool formato, String? pessoaNome}) async {
  final dados = await _getDados(idVisita, pessoaNome);

  final directory = (await getApplicationDocumentsDirectory());

  // String uuid = const Uuid().v1();
  // final filePath = '$directory/$uuid.$formato';

  final filePath = '$directory/documento.pdf';

  final file = File(filePath);

  await file.writeAsBytes(await dados.getRelarioBytes());

  if (formato) {
    return await sharePDF(filePath);
  }
  return await shareImage(filePath);
}

Future<void> sharePDF(filePath) async {
  await Share.shareFiles([filePath], text: '');
}

Future<void> shareImage(filePath) async {
  try {
    File file = File(filePath);
    List<Uint8List> bytes = [];

    await for (var page in Printing.raster(file.readAsBytesSync())) {
      bytes.add(await page.toPng());
    }

    final directory = (await getApplicationDocumentsDirectory()).path;

    final imgPath = '$directory/documento.png';
    final image = File(imgPath);
    await image.writeAsBytes(bytes[0]);

    printDebug(bytes.length.toString());
    await Share.shareFiles([imgPath], text: '');
  } catch (e) {
    printDebug(e.toString());
  }
}

class _Dados {
  late final Visita visita;
  late final TotaisPedido totais;
  late final Cliente cliente;
  late final List<PedidoItem> produtos;
  late final List<Contato> contatos;

  getRelarioBytes() async {
    //Receive data to generate Invoice
    //Create a PDF document.
    final PdfDocument document = PdfDocument();
    //Add page to the PDF
    final PdfPage page = document.pages.add();

    //Get page client size
    final Size pageSize = page.getClientSize();

    page.graphics.drawRectangle(
      bounds: Rect.fromLTWH(0, 0, pageSize.width, pageSize.height),
      brush: PdfBrushes.white,
    );

    //Draw rectangle
    page.graphics.drawRectangle(
        bounds: Rect.fromLTWH(0, 0, pageSize.width, pageSize.height),
        pen: PdfPen(PdfCommon.color4));

    //Generate PDF gridProdutos.
    final PdfGrid gridCliente = getGridCliente(cliente, visita);

    //Generate PDF gridProdutos.
    final PdfGrid gridProdutos = getGridProdutos(produtos);

    //Draw the header section by creating text element
    final PdfLayoutResult resultHeader =
        await drawHeader(page, pageSize, visita: visita, totaisPedido: totais);

    //Draw gridcliente
    final PdfLayoutResult resultCliente =
        drawGridClient(page, gridCliente, resultHeader);

    //Draw gridProdutos
    await drawGridProdutos(page, gridProdutos, resultCliente,
        totaisPedido: totais);


    if(!visita.isSync){
      //Add invoice footer
      drawFooter(page, pageSize);
    }
    //Save the PDF document
    final List<int> bytes = document.save();
    //Dispose the document.
    document.dispose();

    return bytes;
  }
}

Future<_Dados> _getDados(int idVisita, String? pessoaNome) async {
  _Dados dados = _Dados();

  dados.visita = await Visita.getVisita(idVisita);
  dados.totais = await TotaisPedido.getTotaisPedido(idVisita) as TotaisPedido;
  dados.produtos = await PedidoItem.getListPedidoItemList(idVisita);

  late int idCliente;

  if (dados.visita.faturamento) {
    final maps = await DatabaseAmbiente.select('CONF_AMBIENTE',
        where: 'NOME = ?', whereArgs: ['ID PESSOA ORCAMENTO']);
    idCliente = int.parse(maps[0]['VALOR']!);
  } else {
    idCliente = dados.visita.idPessoa;
  }

  dados.cliente =
      (await Cliente.getCliente(idCliente, sync: dados.visita.faturamento))!;

  dados.cliente.nomeOrcamento = pessoaNome;

  return dados;
}
