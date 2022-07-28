/// Bar chart with series legend example
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class SimpleSeriesLegend extends StatelessWidget {
  final List<charts.Series<dynamic, String>> seriesList;
  final bool animate;

  const SimpleSeriesLegend(this.seriesList, {Key? key, this.animate = false})
      : super(key: key);

  factory SimpleSeriesLegend.withSampleData() {
    return SimpleSeriesLegend(
      _createSampleData(),
      // Disable animations for image tests.
      // animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return charts.BarChart(
      seriesList,
      animate: animate,
      barGroupingType: charts.BarGroupingType.grouped,
      // Add the series legend behavior to the chart to turn on series legends.
      // By default the legend will display above the chart.
      behaviors: [charts.SeriesLegend()],
    );
  }

  /// Create series list with multiple series
  static List<charts.Series<OrdinalSales, String>> _createSampleData() {
    final desktopSalesData = [
      OrdinalSales('2014', 569),
      OrdinalSales('2015', 1231),
      OrdinalSales('2016', 1104),
      OrdinalSales('2017', 2456),
    ];

    final tabletSalesData = [
      OrdinalSales('2014', 1350),
      OrdinalSales('2015', 1247),
      OrdinalSales('2016', 1100),
      OrdinalSales('2017', 1054),
    ];

    return [
      charts.Series<OrdinalSales, String>(
        id: 'Desktop',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: desktopSalesData,
      ),
      charts.Series<OrdinalSales, String>(
        id: 'Tablet',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: tabletSalesData,
      ),
    ];
  }
}

/// Sample ordinal data type.
class OrdinalSales {
  final String year;
  final int sales;

  OrdinalSales(this.year, this.sales);
}
