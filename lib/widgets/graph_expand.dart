import 'package:flutter/material.dart';
import 'package:kubernetes_dashboard/widgets/metrics_graph.dart';

class GraphExpand extends StatefulWidget {
  const GraphExpand({
    super.key,
    required this.metrics,
    required this.startTime,
    required this.kind,
    required this.isError,
  });

  final Map<String, List<dynamic>> metrics;
  final DateTime startTime;
  final String kind;
  final bool isError;

  @override
  State<GraphExpand> createState() => _GraphExpandState();
}

class _GraphExpandState extends State<GraphExpand> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Node Metrics Graph - ${widget.kind.split("-").join(" ")}"),
      content: SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        width: MediaQuery.of(context).size.width * 0.5,
        child: MetricsGraph(
            data: widget.metrics,
            startTime: widget.startTime,
            kind: widget.kind,
            isMinimized: false,
            height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width * 0.5,
            onExpand: (kind) {},
            isError: widget.isError),
      ),
    );
  }
}
