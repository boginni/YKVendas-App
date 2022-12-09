//Draws the grid
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../../api/helpers/brasil_formatter.dart';
import '../database/database_ambiente.dart';
import '../database_objects/cliente.dart';
import '../database_objects/pedido_item.dart';
import '../database_objects/totais_pedido.dart';
import '../database_objects/visita.dart';
import 'drawHeader.dart';
import 'pdf_common.dart';

Future<void> drawGridProdutos(
    PdfPage page, PdfGrid grid, PdfLayoutResult layoutResultAbove,
    {required TotaisPedido totaisPedido}) async {
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

  PdfLayoutResult gridResult = grid.draw(
      page: page,
      bounds: Rect.fromLTWH(0, layoutResultAbove.bounds.bottom + 10, 0, 0))!;

  /***
   *
   * total
   *
   */

  /**
   * Header
   */
  double size = 0;

  double getCurSize() {
    size += 15;

    double boundBottom = gridResult.bounds.bottom;

    return size + boundBottom;
  }

  Rect getBounds() {
    return Rect.fromLTWH(quantityCellBounds!.left, getCurSize(),
        quantityCellBounds!.width, quantityCellBounds!.height);
  }

  final font =
      PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold);

  str(String s, double d) {
    final bounds = getBounds();

    final Size contentSize = font.measureString(s);

    page.graphics.drawString(s, font, bounds: bounds);

    page.graphics.drawString(d.toStringAsFixed(2), font,
        bounds: Rect.fromLTWH(totalPriceCellBounds!.left + 8, bounds.top,
            totalPriceCellBounds!.width, totalPriceCellBounds!.height));
  }

  str2(String s, String d) {


    final Size contentSize = font.measureString(s);
    final Size dSize = font.measureString(d);

    final bounds = Rect.fromLTWH(quantityCellBounds!.left - contentSize.width + 28, getCurSize(),
        contentSize.width, quantityCellBounds!.height);

    page.graphics.drawString(s, font, bounds: bounds);

    page.graphics.drawString(d, font,
        bounds: Rect.fromLTWH(totalPriceCellBounds!.left + 8 - dSize.width + 28, bounds.top,
            dSize.width, totalPriceCellBounds!.height));
  }

  /**
   * Body
   */
  str('Subtotal', totaisPedido.totalBruto);
  str('Descontos', totaisPedido.totalDesconto);
  str('Total liquido', totaisPedido.totalLiquido);

  
  if(totaisPedido.idFormaPagamento != null){
    final maps = await DatabaseAmbiente.select('TB_FORMA_PAGAMENTO', where: 'ID = ?', whereArgs: [totaisPedido.idFormaPagamento]);
    str2('Forma de Pagamento:', maps[0]['NOME']);
  }

}

//Create PDF grid and return
PdfGrid getGridProdutos(List<PedidoItem> produtos) {
  //Create a PDF grid
  final PdfGrid grid = PdfGrid();

  //Secify the columns count to the grid.
  grid.columns.add(count: 6);

  //Create the header row of the grid.
  final PdfGridRow headerRow = grid.headers.add(1)[0];

  //Set style
  headerRow.style.backgroundBrush = PdfSolidBrush(PdfCommon.color3);

  headerRow.style.textBrush = PdfBrushes.white;
  headerRow.cells[0].value = 'ID Produto';
  headerRow.cells[0].stringFormat.alignment = PdfTextAlignment.center;
  headerRow.cells[1].value = 'Nome do Produto';
  headerRow.cells[2].value = 'Preço';
  headerRow.cells[3].value = 'Quantidade';
  headerRow.cells[4].value = 'Desconto';
  headerRow.cells[5].value = 'Total';

  //Add rows
  for (final item in produtos) {
    item.render(grid);
  }

  // grid.style = PdfGridStyle(backgroundBrush: PdfSolidBrush(PdfCommon.color1), );

  if(HeaderDrawer.ambiente == 'amazonia'){
    grid.applyBuiltInStyle(PdfGridBuiltInStyle.listTable4Accent6);
  } else {
    grid.applyBuiltInStyle(PdfGridBuiltInStyle.listTable4Accent5);
  }


  grid.columns[1].width = 200;
  for (int i = 0; i < headerRow.cells.count; i++) {
    headerRow.cells[i].style.cellPadding =
        PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
  }

  for (int i = 0; i < grid.rows.count; i++) {
    final PdfGridRow row = grid.rows[i];

    for (int j = 0; j < row.cells.count; j++) {
      final PdfGridCell cell = row.cells[j];
      if (j == 0) {
        cell.stringFormat.alignment = PdfTextAlignment.center;
      }
      cell.style.cellPadding =
          PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
    }
  }

  return grid;
}

PdfLayoutResult drawGridClient(
    PdfPage page, PdfGrid grid, PdfLayoutResult layoutResultAbove) {
  return grid.draw(
      page: page,
      bounds: Rect.fromLTWH(0, layoutResultAbove.bounds.bottom + 10, 0, 0))!;
}

//Create PDF grid and return
PdfGrid getGridCliente(Cliente cliente, Visita visita) {
  row1(PdfGrid grid) {

    // row.style.backgroundBrush = PdfSolidBrush(PdfColor(68, 114, 196));

    // final header = grid.rows.add();
    //
    // header.style.textBrush = PdfBrushes.black;
    // header.cells[0].value = 'Codigo';
    // header.cells[1].value = 'Nome do Cliente';
    // header.cells[2].value = 'Data';
    //
    // for (int i = 0; i < header.cells.count; i++) {
    //   header.cells[i].style.borders.bottom = PdfPens.transparent;
    // }

    final row = grid.rows.add();
    row.style.textBrush = PdfBrushes.black;
    // row.cells[0].value = visita.idPessoa;

    row.cells[0].value = cliente.apelido;
    row.cells[0].columnSpan = 5;
    row.cells[5].value = visita.getDataCriacao();
  }

  row2(PdfGrid grid) {
    final row = grid.rows.add();

    row.style.textBrush = PdfBrushes.black;
    row.cells[0].value = cliente.nomeOrcamento ?? (cliente.nome ?? '');
    row.cells[0].columnSpan = 5;
    row.cells[5].value = 'CNPJ\n${formatCpfCnpj(cliente.cpfcnpj ?? '')}';
  }

  row3(PdfGrid grid) {
    final row = grid.rows.add();

    row.style.textBrush = PdfBrushes.black;
    // '\n${}'
    row.cells[0].value = 'CIDADE\n${cliente.cidade ?? ''}';
    // row.cells[0].columnSpan = 1;

    row.cells[1].value = 'BAIRRO\n${cliente.bairro ?? ''}' ;
    // row.cells[1].columnSpan = 1;

    row.cells[2].value = 'LOGRADOURO\n${cliente.logradouro ?? ''}' ;
    row.cells[2].columnSpan = 3;

    row.cells[5].value = 'NUMERO\n${cliente.numero ?? ''}' ;
    // row.cells[0].columnSpan = 1;
  }

  row4(PdfGrid grid) {
    final row = grid.rows.add();

    row.style.textBrush = PdfBrushes.black;
    row.cells[0].value = cliente.cidade ?? '';
    row.cells[0].columnSpan = 1;
    row.cells[1].value = '';
    row.cells[1].columnSpan = 5;

    // row.h
  }

  //Create a PDF grid
  final PdfGrid grid = PdfGrid();

  //Secify the columns count to the grid.
  grid.columns.add(count: 6);

  row1(grid);
  row2(grid);
  row3(grid);
  // row4(grid);

  for (final contato in cliente.contatos) {
    final row = grid.rows.add();
    row.style.textBrush = PdfBrushes.black;
    row.cells[0].value = contato.tipo;
    row.cells[0].columnSpan = 1;
    row.cells[1].value = '${contato.ddd} ${contato.contato}';
    row.cells[1].columnSpan = 5;
  }

  // grid.applyBuiltInStyle(PdfGridBuiltInStyle.listTable4Accent5);
  // grid.columns[1].width = 200;

  // for (int i = 0; i < row.cells.count; i++) {
  //   row.cells[i].style.cellPadding =
  //       PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
  // }

  for (int i = 0; i < grid.rows.count; i++) {
    final PdfGridRow row = grid.rows[i];

    for (int j = 0; j < row.cells.count; j++) {
      final PdfGridCell cell = row.cells[j];
      if (j == 0) {
        cell.stringFormat.alignment = PdfTextAlignment.left;
      }
      cell.style.cellPadding =
          PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
    }
  }

  // grid.rows[1].cells[0].stringFormat.alignment = PdfTextAlignment.left;

  return grid;
}
