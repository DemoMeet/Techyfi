import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../constants/style.dart';
import '../../../model/Expense.dart';

class PieCharts extends StatefulWidget {
  List<Expense> top3Expenses;
  double expense, expensal;
  PieCharts({super.key, required this.top3Expenses, required this.expense, required this.expensal});

  @override
  State<StatefulWidget> createState() => PieChartState(expensal: expensal, expense: expense, top3Expenses: top3Expenses);
}

class PieChartState extends State {
  int touchedIndex = 0;
  List<Expense> top3Expenses;
  double expense, expensal;
  PieChartState({required this.top3Expenses, required this.expense, required this.expensal});

  @override
  Widget build(BuildContext context) {
    Color getExpenseColor(int index) {
      // Add your logic to determine color based on index
      // You can customize this function according to your color scheme
      switch (index) {
        case 1:
          return c2;
        case 2:
          return c3;
        case 3:
          return c4;
        default:
          throw Exception('Invalid index for color');
      }
    }
    List<PieChartSectionData> showingSections() {
      return List.generate(4, (i) {
        final isTouched = i == touchedIndex;
        const fontSize = 10.0;
        final radius = isTouched ? 110.0 : 100.0;
        const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

        switch (i) {
          case 0:
            return PieChartSectionData(
              color: c1,
              value: expensal,
              title: isTouched ? 'Salary $expensal/-' : "",
              radius: radius,
              titleStyle: const TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Color(0xffffffff),
                shadows: shadows,
              ),
            );
          default:
            if (i - 1 < top3Expenses.length) {
              return PieChartSectionData(
                color: getExpenseColor(i),
                value: top3Expenses[i - 1].amount,
                title: isTouched
                    ? '${top3Expenses[i - 1].expensename} ${top3Expenses[i - 1].amount}/-'
                    : "",
                radius: radius,
                titleStyle: const TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Color(0xffffffff),
                  shadows: shadows,
                ),
              );
            }  else {
              // Handle the case where the index is out of bounds gracefully
              return PieChartSectionData(color: Colors.transparent, value: 0);
            }
        }
      });
    }

    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  pieTouchResponse == null ||
                  pieTouchResponse.touchedSection == null) {
                touchedIndex = -1;
                return;
              }
              touchedIndex =
                  pieTouchResponse.touchedSection!.touchedSectionIndex;
            });
          },
        ),
        borderData: FlBorderData(
          show: false,
        ),
        sectionsSpace: 0,
        centerSpaceRadius: 0,
        sections: showingSections(),
      ),
    );
  }

}
