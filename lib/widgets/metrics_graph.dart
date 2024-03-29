import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kubernetes_dashboard/shared/gradient_colors.dart';
import 'package:kubernetes_dashboard/shared/utils.dart';
import 'package:kubernetes_dashboard/themes/custom_colors.dart';
import 'package:intl/intl.dart';
import 'package:kubernetes_dashboard/widgets/gradientSquare.dart';

class MetricsGraph extends StatefulWidget {
  const MetricsGraph({
    super.key,
    required this.data,
    required this.startTime,
    required this.kind,
    required this.isMinimized,
    required this.height,
    required this.width,
    required this.onExpand,
    required this.isError,
  });

  final Map<String, List<dynamic>> data;
  final DateTime startTime;
  final String kind;

  final bool isMinimized;
  final bool isError;

  final double height;
  final double width;

  final Function(String kind) onExpand;

  @override
  State<MetricsGraph> createState() => _MetricsGraphState();
}

class _MetricsGraphState extends State<MetricsGraph> {
  @override
  void initState() {
    super.initState();
  }

  LineChartBarData cpuData(List<dynamic> data, LinearGradient gradient) {
    return LineChartBarData(
      preventCurveOverShooting: true,
      spots: [
        ...data.map((e) {
          return FlSpot(e["time"], e[widget.kind]);
        })
      ],
      dotData: const FlDotData(
        show: false,
      ),
      gradient: gradient,
      barWidth: 4,
      isCurved: true,
      isStrokeCapRound: true,
      isStrokeJoinRound: true,
    );
  }

  double getMaxValue() {
    double max = 0;
    for (var item in widget.data.entries) {
      for (var data in item.value) {
        if (data[widget.kind] > max) {
          max = data[widget.kind];
        }
      }
    }
    max = (max / 10).ceil() * 10;

    return max;
  }

  @override
  Widget build(BuildContext context) {
    CustomColors customTheme = Theme.of(context).extension<CustomColors>()!;
    return AspectRatio(
      aspectRatio: 1.5,
      child: Tooltip(
        message: widget.kind.split("-").join(" ").toUpperCase(),
        child: InkWell(
          onTap: () {
            widget.onExpand(widget.kind);
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  widget.kind.split("-").join(" ").toUpperCase(),
                  style: TextStyle(
                    color: customTheme.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  height: widget.height,
                  width: widget.width,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: customTheme.cardBgColor,
                    borderRadius: BorderRadius.circular(10),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: customTheme.cardShadowColor ??
                    //         const Color.fromARGB(255, 41, 41, 41),
                    //     blurRadius: 3,
                    //     spreadRadius: 2,
                    //     offset: const Offset(0, 3),
                    //   ),
                    // ],
                  ),
                  child: widget.isError
                      ? const Center(
                          child: Text(
                            "Error Fetching Data",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : LineChart(
                          LineChartData(
                            lineTouchData: LineTouchData(
                              enabled: !widget.isMinimized,
                              touchTooltipData: LineTouchTooltipData(
                                tooltipBgColor: Colors.blueGrey,
                                getTooltipItems: (touchedSpots) {
                                  return touchedSpots.map((touchedSpot) {
                                    return LineTooltipItem(
                                      "${DateFormat('HH:mm:ss').format(widget.startTime.add(Duration(seconds: touchedSpot.x.toInt())))}\n${touchedSpot.y}${widget.kind.contains("percentage") ? "%" : widget.kind.contains("cpu") ? "m" : "Mi"}",
                                      const TextStyle(color: Colors.white),
                                    );
                                  }).toList();
                                },
                              ),
                            ),
                            clipData: const FlClipData.all(),
                            minY: 0,
                            maxY: getMaxValue(),
                            gridData: const FlGridData(
                              show: false,
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              ...widget.data.entries.map(
                                (e) {
                                  var data = cpuData(
                                    e.value,
                                    gradients[widget.data.entries
                                        .map((e) => e.key)
                                        .toList()
                                        .indexOf(e.key)],
                                  );
                                  return data;
                                },
                              ),
                            ],
                            titlesData: FlTitlesData(
                              show: !widget.isMinimized,
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  reservedSize: 50,
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) => Text(
                                    "${value.toInt()}${widget.kind.contains("percentage") ? "%" : widget.kind.contains("cpu") ? "m" : "Mi"}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 9,
                                    ),
                                  ),
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: !widget.isMinimized,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                        DateFormat('HH:mm:ss').format(
                                            widget.startTime.add(Duration(
                                                seconds: value.toInt()))),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 9,
                                        ));
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: false,
                                ),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: false,
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ...widget.data.entries.map(
                        (e) {
                          return Row(
                            children: [
                              GradientSquare(
                                height: 20,
                                width: 20,
                                gradient: gradients[widget.data.entries
                                    .map((e) => e.key)
                                    .toList()
                                    .indexOf(e.key)],
                              ),
                              const SizedBox(width: 5),
                              Container(
                                decoration: BoxDecoration(
                                  color: customTheme.cardBgColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  Utils().truncate(e.key, 20),
                                  style: TextStyle(
                                    color: customTheme.textColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
