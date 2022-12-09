//Draws the invoice header
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../database_objects/produtos_list_item.dart';
import '../pdf_common.dart';

class HeaderDrawer {
  static String ambiente = 'live';
}

Future<PdfLayoutResult> drawHeader(PdfPage page, Size pageSize, List<ProdutoListItem> produtos) async {
  double height = 60;

  double strHei = height - 70;


  //Draw rectangle
  page.graphics.drawRectangle(
      brush: PdfSolidBrush(PdfCommon.color1),
      bounds: Rect.fromLTWH(0, 0, pageSize.width - 115, height));
  //Draw string
  page.graphics.drawString(('Catálogo'),
      PdfStandardFont(PdfFontFamily.helvetica, 30),
      brush: PdfBrushes.white,
      bounds: Rect.fromLTWH(25, strHei, pageSize.width - 115, height),
      format: PdfStringFormat(lineAlignment: PdfVerticalAlignment.middle));

  page.graphics.drawRectangle(
      bounds: Rect.fromLTWH(400, 0, pageSize.width - 400, height),
      brush: PdfSolidBrush(PdfCommon.color2));

  page.graphics.drawString(
      produtos.length.toString(),
      PdfStandardFont(PdfFontFamily.helvetica, 18),
      bounds: Rect.fromLTWH(400, strHei, pageSize.width - 400, 100),
      brush: PdfBrushes.white,
      format: PdfStringFormat(
          alignment: PdfTextAlignment.center,
          lineAlignment: PdfVerticalAlignment.middle));

  final PdfFont contentFont = PdfStandardFont(PdfFontFamily.helvetica, 9);
  //Draw string
  page.graphics.drawString('Produtos', contentFont,
      brush: PdfBrushes.white,
      bounds: Rect.fromLTWH(400, strHei, pageSize.width - 400, 33),
      format: PdfStringFormat(
          alignment: PdfTextAlignment.center,
          lineAlignment: PdfVerticalAlignment.bottom));

  final bytes = await getLogo(HeaderDrawer.ambiente);

  if (bytes != null) {
    page.graphics.drawImage(
        PdfBitmap(bytes), Rect.fromLTWH(50, height, pageSize.width - 115, 90));
    height += 90;
  }

  return PdfTextElement(text: '', font: contentFont).draw(
      page: page,
      bounds: Rect.fromLTWH(30, height, pageSize.width, pageSize.height - 0))!;
}

Future<Uint8List?> getLogo(String ambiente) async {
  final folder = (await getTemporaryDirectory()).path;
  final path = '$folder/${ambiente}';

  final dir = Directory(path);
  final filePath = '$path/logo.png';

  if (!dir.existsSync()) {
    dir.createSync();
  }

  File imgFile = File(filePath);

  if ((imgFile.existsSync() && imgFile.lengthSync() > 200)) {
    return imgFile.readAsBytesSync();
  }
}
