import 'dart:math';
import 'package:flutter/material.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart' as charts;

class StackedHorizontalBarChart extends StatefulWidget {
  final List<charts.Series<dynamic, String>> seriesList;
  final bool animate;

  StackedHorizontalBarChart(this.seriesList, {this.animate = false});

  factory StackedHorizontalBarChart.withRandomData() {
    return StackedHorizontalBarChart(_createRandomData());
  }

  static List<double> generateRandomDataForDay(double target, int parts) {
    final random = Random();
    List<double> values = List.generate(parts, (_) => random.nextDouble());
    double sum = values.reduce((a, b) => a + b);
    values = values.map((value) => (value / sum) * target).toList();
    return values;
  }

  static List<charts.Series<OrdinalSales, String>> _createRandomData() {
    final random = Random();
    final daysInMonth = 8;
    final List<OrdinalSales> data = [];

    for (int day = 1; day <= daysInMonth; day++) {
      List<double> dailyData = generateRandomDataForDay(24.0, 8);

      for (var value in dailyData) {
        data.add(
          OrdinalSales('$day June\nBed Mat', value),
        );
      }
    }

    final colors = [
      charts.MaterialPalette.red.shadeDefault,
      charts.MaterialPalette.green.shadeDefault,
    ];

    return [
      charts.Series<OrdinalSales, String>(
        id: 'Bed mat data',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        colorFn: (OrdinalSales sales, index) => colors[index! % colors.length],
        data: data,
      ),
    ];
  }

  @override
  _StackedHorizontalBarChartState createState() => _StackedHorizontalBarChartState();
}

class _StackedHorizontalBarChartState extends State<StackedHorizontalBarChart> {
  double minMeasure = 0;
  double maxMeasure = 24;

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      double delta = details.primaryDelta ?? 0;
      minMeasure += delta * 0.5;
      maxMeasure += delta * 0.5;
    });
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      double scale = details.scale;
      double center = (minMeasure + maxMeasure) / 2;
      double newRange = (maxMeasure - minMeasure) / scale;
      minMeasure = center - newRange / 2;
      maxMeasure = center + newRange / 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onScaleUpdate: _onScaleUpdate,
      child: charts.BarChart(
        widget.seriesList,
        animate: widget.animate,
        barGroupingType: charts.BarGroupingType.stacked,
        vertical: false,
        primaryMeasureAxis: charts.NumericAxisSpec(
          viewport: charts.NumericExtents(minMeasure, maxMeasure),
          renderSpec: charts.GridlineRendererSpec(
            labelStyle: charts.TextStyleSpec(
              fontSize: 14,
              fontWeight: '400',
              color: charts.MaterialPalette.black,
            ),
            lineStyle: charts.LineStyleSpec(
              thickness: 2,
              color: charts.MaterialPalette.gray.shadeDefault,
            ),
          ),
        ),
        domainAxis: charts.OrdinalAxisSpec(
          renderSpec: charts.SmallTickRendererSpec(
            labelStyle: charts.TextStyleSpec(
              fontSize: 14,
              fontWeight: '400',
              color: charts.MaterialPalette.black,
            ),
            lineStyle: charts.LineStyleSpec(
              thickness: 2,
              color: charts.MaterialPalette.gray.shadeDefault,
            ),
          ),
        ),
      ),
    );
  }
}

class OrdinalSales {
  final String year;
  final double sales;

  OrdinalSales(this.year, this.sales);
}
