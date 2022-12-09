import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../database_objects/produtos_list_item.dart';
import '../drawHeader.dart';
import '../pdf_common.dart';

Future<void> drawGridProdutos(
    PdfPage page, PdfGrid grid, PdfLayoutResult layoutResultAbove) async {
  /***
   *
   * produto
   *
   */

  Rect? totalPriceCellBounds;
  Rect? quantityCellBounds;
  //Invoke the beginCellLayout event.
  grid.beginCellLayout = (Object sender, PdfGridBeginCellLayoutArgs args) {
    final PdfGrid grid = sender as PdfGrid;
    if (args.cellIndex == grid.columns.count - 1) {
      totalPriceCellBounds = args.bounds;
    } else if (args.cellIndex == grid.columns.count - 2) {
      quantityCellBounds = args.bounds;
    }
  };

  grid.draw(
      page: page,
      bounds: Rect.fromLTWH(0, layoutResultAbove.bounds.bottom, 0, 0))!;
}

//Create PDF grid and return
Future<PdfGrid> getGridProdutos(List<ProdutoListItem> produtos) async {
  //Create a PDF grid
  final PdfGrid grid = PdfGrid();

  //Secify the columns count to the grid.
  grid.columns.add(count: 6);

  //Create the header row of the grid.
  final PdfGridRow headerRow = grid.headers.add(1)[0];

  //Set style
  headerRow.style.backgroundBrush = PdfSolidBrush(PdfCommon.color3);

  headerRow.style.textBrush = PdfBrushes.white;
  headerRow.cells[0].value = 'Icon';
  headerRow.cells[1].value = 'ID';
  headerRow.cells[1].stringFormat.alignment = PdfTextAlignment.center;
  headerRow.cells[2].value = 'Nome do Produto';
  headerRow.cells[3].value = 'Preço';
  headerRow.cells[4].value = 'Estoque';
  // headerRow.cells[4].value = 'Desconto';
  // headerRow.cells[5].value = 'Total';

  //Add rows
  for (final item in produtos) {
    item.render(grid);
  }

  grid.applyBuiltInStyle(PdfGridBuiltInStyle.listTable4Accent5);

  grid.columns[2].width = 300;
  for (int i = 0; i < headerRow.cells.count; i++) {
    headerRow.cells[i].style.cellPadding =
        PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
  }

  for (int i = 0; i < grid.rows.count; i++) {
    final PdfGridRow row = grid.rows[i];
    row.height = 50;

    for (int j = 0; j < row.cells.count; j++) {
      final PdfGridCell cell = row.cells[j];
      if (j == 0) {

        final bytes = await getImage(produtos[i].idProduto);

        if (bytes != null) {
          cell.style.backgroundImage = PdfBitmap(bytes);
        }
      }

      if(j == 1 || j == 4){
        cell.stringFormat.alignment = PdfTextAlignment.center;
      }

      cell.style.cellPadding =
          PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
    }
  }

  return grid;
}

Future<Uint8List?> getImage(int id) async {
  final folder = (await getTemporaryDirectory()).path;
  final path = '$folder/${HeaderDrawer.ambiente}';

  final dir = Directory(path);
  final filePath = '$path/$id-thumb.png';

  if (!dir.existsSync()) {
    dir.createSync();
  }

  File imgFile = File(filePath);

  if ((imgFile.existsSync() && imgFile.lengthSync() > 200)) {
    return imgFile.readAsBytesSync();
  }
}
