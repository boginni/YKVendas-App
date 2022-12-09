//Draw the invoice footer data.
import 'dart:ui';

import 'package:syncfusion_flutter_pdf/pdf.dart';

int diasValidos = 7;

void drawFooter(PdfPage page, Size pageSize) {
  // final PdfPen linePen =
  //     PdfPen(PdfColor(142, 170, 219, 255), dashStyle: PdfDashStyle.custom);
  // linePen.dashPattern = <double>[3, 3];
  //Draw line
  // page.graphics.drawLine(linePen, Offset(0, pageSize.height - 100),
  //     Offset(pageSize.width, pageSize.height - 100));

  // const String footerContent =
  //     // ignore: leading_newlines_in_multiline_strings
  //     '''800 Interchange Blvd.\r\n\r\nSuite 2501, Austin,
  //        TX 78721\r\n\r\nAny Questions? support@adventure-works.com''';

  String footerContent =
      // ignore: leading_newlines_in_multiline_strings
      ///TODO: Parâmetro novo
      'Orçamento Válido por $diasValidos Dias';

  //Added 30 as a margin for the layout
  page.graphics.drawString(
      footerContent, PdfStandardFont(PdfFontFamily.helvetica, 9),
      format: PdfStringFormat(alignment: PdfTextAlignment.right),
      bounds: Rect.fromLTWH(pageSize.width - 30, pageSize.height - 40, 0, 0),
      pen: PdfPen(PdfColor(220, 60, 60)));
}
