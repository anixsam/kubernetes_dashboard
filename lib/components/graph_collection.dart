import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kubernetes_dashboard/widgets/graph_expand.dart';
import 'package:kubernetes_dashboard/widgets/metrics_graph.dart';
import 'package:process_run/process_run.dart';

class GraphCollection extends StatefulWidget {
  const GraphCollection({super.key});

  @override
  State<GraphCollection> createState() => _GraphCollectionState();
}

class _GraphCollectionState extends State<GraphCollection> {
  Map<String, List<dynamic>> metrics = {};

  DateTime startTime = DateTime.now();

  int interval = 10;

  bool isError = false;

  Timer? timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(Duration(seconds: interval), (timer) {
      fetchMetrics();
    });
  }

  void expandGraph(kind) {
    // Open overlay with graph
    showDialog(
      context: context,
      builder: (context) {
        return GraphExpand(
          metrics: metrics,
          startTime: startTime,
          kind: kind,
          isError: isError,
        );
      },
    );
  }

  fetchMetrics() async {
    Shell shell = Shell();

    isError = false;

    shell.run('kubectl top nodes').then((result) {
      var lines = result[0].stdout.split("\n");
      lines.removeAt(0);

      Map<String, List<dynamic>> nodeCollection = metrics;

      for (var line in lines) {
        var parts = line.split(" ");
        if (parts.length < 2) {
          continue;
        }

        parts.removeWhere((element) => element == "");

        List<dynamic> nodeMetrics = nodeCollection[parts[0]] ??
            [
              {
                "time": 0.0,
                "cpu-usage": 0.0,
                "memory-usage": 0.0,
                "memory-percentage": 0.0,
                "cpu-percentage": 0.0,
              }
            ];

        // print("Node Collection: ${nodeCollection[parts[0]]}");

        nodeMetrics.add({
          "time": DateTime.now().difference(startTime).inSeconds.toDouble(),
          "cpu-usage": double.parse(parts[1].replaceAll("m", "")),
          "memory-usage": double.parse(parts[3].replaceAll("Mi", "")),
          "memory-percentage": double.parse(parts[4].replaceAll("%", "")),
          "cpu-percentage": double.parse(parts[2].replaceAll("%", "")),
        });

        nodeCollection[parts[0]] = nodeMetrics;
      }

      setState(() {
        metrics = nodeCollection;
      });
    }).catchError((error) {
      setState(() {
        isError = true;
        timer?.cancel();
      });
      print("Error 33: $error $isError");
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    double graphHeight = 200;
    double graphWidth = 400;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Node Metrics"),
        actions: [
          isError
              ? IconButton(
                  onPressed: () {
                    timer =
                        Timer.periodic(Duration(seconds: interval), (timer) {
                      fetchMetrics();
                    });
                    setState(() {
                      isError = false;
                    });
                  },
                  icon: const Icon(Icons.refresh),
                )
              : const SizedBox(),
          Text(
            "Data Refreshing in $interval seconds",
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MetricsGraph(
                data: metrics,
                startTime: startTime,
                kind: "cpu-percentage",
                isMinimized: true,
                height: graphHeight,
                width: graphWidth,
                onExpand: expandGraph,
                isError: isError,
              ),
              const SizedBox(width: 20),
              MetricsGraph(
                data: metrics,
                startTime: startTime,
                kind: "memory-percentage",
                isMinimized: true,
                height: graphHeight,
                width: graphWidth,
                onExpand: expandGraph,
                isError: isError,
              ),
              const SizedBox(width: 20),
              MetricsGraph(
                data: metrics,
                startTime: startTime,
                kind: "cpu-usage",
                isMinimized: true,
                height: graphHeight,
                width: graphWidth,
                onExpand: expandGraph,
                isError: isError,
              ),
              const SizedBox(width: 20),
              MetricsGraph(
                data: metrics,
                startTime: startTime,
                kind: "memory-usage",
                isMinimized: true,
                height: graphHeight,
                width: graphWidth,
                onExpand: expandGraph,
                isError: isError,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
