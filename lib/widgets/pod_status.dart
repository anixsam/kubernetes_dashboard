// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PodStatus extends StatelessWidget {
  const PodStatus({super.key, required this.status});

  final String status;

  Widget getStatusIcon(String status) {
    switch (status) {
      case 'Running':
        return const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          strokeWidth: 1,
          strokeCap: StrokeCap.round,
        );
      case 'Pending':
        return const FaIcon(FontAwesomeIcons.hourglassHalf,
            color: Colors.orange);
      case 'Succeeded':
        return const FaIcon(
          FontAwesomeIcons.checkCircle,
          color: Colors.green,
        );
      case 'Failed':
        return const FaIcon(
          FontAwesomeIcons.timesCircle,
          color: Colors.red,
        );
      case 'Unknown':
        return const FaIcon(
          FontAwesomeIcons.questionCircle,
          color: Colors.grey,
        );
      case 'Terminating':
        return const FaIcon(
          FontAwesomeIcons.syncAlt,
          color: Colors.red,
        );
      case 'ContainerCreating':
        return const FaIcon(
          FontAwesomeIcons.cube,
          color: Colors.blue,
        );
      case 'CrashLoopBackOff':
        return const FaIcon(
          FontAwesomeIcons.syncAlt,
          color: Colors.red,
        );
      case 'Completed':
        return const FaIcon(
          FontAwesomeIcons.checkCircle,
          color: Colors.green,
        );
      default:
        return const FaIcon(FontAwesomeIcons.questionCircle,
            color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: status,
      child: SizedBox(
        width: 20,
        height: 20,
        child: getStatusIcon(status),
      ),
    );
  }
}
