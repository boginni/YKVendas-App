import 'dart:ui';

import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../database_objects/produtos_list_item.dart';
import '../pdf_common.dart';
import 'header.dart';
import 'itens.dart';

getRelarioBytes(List<ProdutoListItem> itens) async {
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
  final PdfGrid gridProdutos = await getGridProdutos(itens);

  //Draw the header section by creating text element
  final PdfLayoutResult resultHeader = await drawHeader(page, pageSize, itens);

  await drawGridProdutos(page, gridProdutos, resultHeader);

  final List<int> bytes = document.save();
  document.dispose();

  return bytes;
}
