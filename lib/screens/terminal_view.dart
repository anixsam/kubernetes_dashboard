import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:process_run/process_run.dart';
import 'package:xterm/xterm.dart';

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';

class TerminalScreen extends StatefulWidget {
  const TerminalScreen({
    super.key,
    required this.name,
    required this.namespace,
  });

  final String name;
  final String namespace;

  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen> {
  Terminal terminal = Terminal(
    maxLines: 10000,
    reflowEnabled: false,
  );

  TerminalController terminalController = TerminalController();

  @override
  void initState() {
    super.initState();
    loadLogs();

    terminal.setAutoWrapMode(true);
    terminal.setColumnMode(true);
  }

  void loadLogs() {
    // listen to logs of the pod

    var controller = ShellLinesController();

    Shell shell = Shell(
      stdout: controller.sink,
    );

    shell
        .run('kubectl logs -f ${widget.name} -n ${widget.namespace}')
        .then((result) {});

    controller.stream.listen((event) {
      event.split("\n").forEach((element) {
        // try {
        //   var json = jsonDecode(element);
        //   terminal.cursorNextLine(1);
        //   terminal.setCursorX(0);
        //   // Displaying json in prettied format
        //   terminal.write(jsonEncode(json));
        // } catch (e) {
        terminal.cursorNextLine(1);
        terminal.setCursorX(0);
        terminal.write(element);
        // }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.chevronLeft),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text("Logs"),
        actions: [
          IconButton(
            onPressed: () {
              // Downloading logs
              Shell shell = Shell();
              // Select directory to save logs
              FileSelectorPlatform.instance.getDirectoryPath().then((path) {
                if (path != null) {
                  print("Saving logs to: $path");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Saving logs to: $path"),
                    ),
                  );
                  shell
                      .run(
                        'kubectl logs ${widget.name} -n ${widget.namespace}',
                      )
                      .then((value) => {
                            // Saving logs to file
                            File('$path/${widget.name}_${DateTime.now().toIso8601String()}.log')
                                .writeAsString(value[0].stdout)
                          });
                }
              });
            },
            icon: const Icon(FontAwesomeIcons.download),
          ),
          IconButton(
            onPressed: () {
              // Clearing terminal
              setState(() {
                terminal = Terminal(
                  maxLines: 10000,
                  reflowEnabled: false,
                );
              });
            },
            icon: const Icon(FontAwesomeIcons.trash),
          ),
        ],
      ),
      body: TerminalView(
        terminal,
        autoResize: true,
        backgroundOpacity: 0.5,
        readOnly: true,
        padding: const EdgeInsets.all(8),
        textStyle: const TerminalStyle(
          fontSize: 13,
        ),
        controller: terminalController,
      ),
    );
  }
}
