import 'package:flutter/material.dart';

class DashboardConfigDialog extends StatefulWidget {
  const DashboardConfigDialog({
    super.key,
    required this.newDashboardConfig,
  });

  final Map<String, bool> newDashboardConfig;

  @override
  State<DashboardConfigDialog> createState() => _DashboardConfigDialogState();
}

class _DashboardConfigDialogState extends State<DashboardConfigDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Dashboard Configuration"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CheckboxListTile(
            title: const Text("Metrics"),
            value: widget.newDashboardConfig["metrics"],
            onChanged: (value) {
              setState(() {
                widget.newDashboardConfig["metrics"] = value!;
              });
            },
          ),
          CheckboxListTile(
            title: const Text("Pods"),
            value: widget.newDashboardConfig["pod"],
            onChanged: (value) {
              setState(() {
                widget.newDashboardConfig["pod"] = value!;
              });
            },
          ),
          // CheckboxListTile(
          //   title: const Text("Nodes"),
          //   value: dashboardConfig.node,
          //   onChanged: (value) {
          //     setState(() {
          //       dashboardConfig.node = value!;
          //     });
          //   },
          // ),
          CheckboxListTile(
            title: const Text("Deployments"),
            value: widget.newDashboardConfig["deployment"],
            onChanged: (value) {
              setState(() {
                widget.newDashboardConfig["deployment"] = value!;
              });
            },
          ),
          CheckboxListTile(
            title: const Text("Services"),
            value: widget.newDashboardConfig["services"],
            onChanged: (value) {
              setState(() {
                widget.newDashboardConfig["services"] = value!;
              });
            },
          ),
          CheckboxListTile(
            title: const Text("Virtual Services"),
            value: widget.newDashboardConfig["virtualService"],
            onChanged: (value) {
              setState(() {
                widget.newDashboardConfig["virtualService"] = value!;
              });
            },
          ),
          CheckboxListTile(
            title: const Text("Namespaces"),
            value: widget.newDashboardConfig["namespace"],
            onChanged: (value) {
              setState(() {
                widget.newDashboardConfig["namespace"] = value!;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text("Close"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(widget.newDashboardConfig);
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
