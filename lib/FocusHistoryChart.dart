/// Bar chart example
import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:orbital2020/DataContainers/FocusSession.dart';

class FocusHistoryChart extends StatelessWidget {
  final List<FocusSession> sessionList;

  FocusHistoryChart(this.sessionList);

  @override
  Widget build(BuildContext context) {
    if(sessionList == null || sessionList.length <= 0) {
      return Container(width: 0, height: 0);
    }

    Map<String, int> chartMap = {};
    for(FocusSession session in sessionList) {
      String date = DateFormat('y-MM-dd').format(session.startTime);
      int time = session.durationMins;
      int prev = chartMap[date] ?? 0;
      chartMap[date] = prev + time;
    }

    List<FocusSessionChartData> chartData = [];
    for(MapEntry<String, int> entry in chartMap.entries) {
      chartData.add(FocusSessionChartData(entry.key, entry.value));
    }

    chartData.sort((a, b) => a.date.compareTo(b.date));

    List<Series<FocusSessionChartData, String>> seriesList = [Series<FocusSessionChartData, String>(
      id: 'Sessions',
      colorFn: (_, __) => MaterialPalette.blue.shadeDefault,
      domainFn: (FocusSessionChartData session, _) => session.date,
      measureFn: (FocusSessionChartData session, _) => session.time,
      data: chartData,
    )];

    return SizedBox(
      height: 250,
      child: BarChart(
        seriesList,
        animate: true,
      ),
    );
  }
}

class FocusSessionChartData {
  final String date;
  final int time;

  FocusSessionChartData(this.date, this.time);

  @override
  String toString() {
    return date + ": " + time.toString();
  }
}
