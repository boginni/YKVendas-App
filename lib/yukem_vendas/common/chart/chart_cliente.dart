import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

import '../../../api/common/custom_widgets/custom_text.dart';
import '../../models/database_objects/comissao.dart';

class HorizontalBarLabelChart extends StatelessWidget {
  final List<charts.Series<dynamic, String>> seriesList;
  final bool animate;

  const HorizontalBarLabelChart(this.seriesList,
      {Key? key, this.animate = false})
      : super(key: key);

  /// Creates a [BarChart] with sample data and no transition.
  factory HorizontalBarLabelChart.comissaoMes(
      List<ComissaoMes> totais, bool tipo) {
    return HorizontalBarLabelChart(
      _createSampleData(totais, tipo),
      // Disable animations for image tests.
      animate: true,
    );
  }

  // [BarLabelDecorator] will automatically position the label
  // inside the bar if the label will fit. If the label will not fit and the
  // area outside of the bar is larger than the bar, it will draw outside of the
  // bar. Labels can always display inside or outside using [LabelPosition].
  //
  // Text style for inside / outside can be controlled independently by setting
  // [insideLabelStyleSpec] and [outsideLabelStyleSpec].
  @override
  Widget build(BuildContext context) {
    return charts.BarChart(
      seriesList,
      animate: animate,
      vertical: false,
      // Set a bar label decorator.
      // Example configuring different styles for inside/outside:
      //       barRendererDecorator: new charts.BarLabelDecorator(
      //          insideLabelStyleSpec: new charts.TextStyleSpec(...),
      //          outsideLabelStyleSpec: new charts.TextStyleSpec(...)),
      barRendererDecorator: charts.BarLabelDecorator<String>(),
      // Hide domain axis.
      domainAxis:
          const charts.OrdinalAxisSpec(renderSpec: charts.NoneRenderSpec()),
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<ComissaoMes, String>> _createSampleData(
      List<ComissaoMes> data, bool tipo) {
    return [
      charts.Series<ComissaoMes, String>(
          id: 'Sales',
          domainFn: (ComissaoMes sales, _) => sales.mes,
          measureFn: (ComissaoMes sales, _) =>
              tipo ? sales.valorTotal : sales.comissao,
          data: data,
          // Set a label accessor to control the text of the bar label.
          labelAccessorFn: (ComissaoMes sales, _) =>
              '${sales.mes}: ${TextDinheiroReal.format(tipo ? sales.valorTotal : sales.comissao)}')
    ];
  }
}

/// Sample ordinal data type.
