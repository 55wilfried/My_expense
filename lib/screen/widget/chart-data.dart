import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartSummary extends StatelessWidget {
  final List<ChartData> data;

  ChartSummary({required this.data});

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      title: ChartTitle(text: 'Expense Summary'),
      legend: Legend(isVisible: true),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries>[
        ColumnSeries<ChartData, String>(
          dataSource: data,
          xValueMapper: (ChartData expense, _) => expense.category,
          yValueMapper: (ChartData expense, _) => expense.amount,
          name: 'Expenses',
          dataLabelSettings: DataLabelSettings(isVisible: true),
        ),
      ],
    );
  }
}

class ChartData {
  final String category;
  final double amount;

  ChartData(this.category, this.amount);
}
