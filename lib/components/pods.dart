import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kubernetes_dashboard/models/pod.dart';
import 'package:kubernetes_dashboard/providers/data_provider.dart';
import 'package:kubernetes_dashboard/shared/utils.dart';
import 'package:kubernetes_dashboard/widgets/filter_dropdown.dart';
import 'package:kubernetes_dashboard/widgets/pod_status.dart';
import 'package:kubernetes_dashboard/screens/terminal_view.dart';
import 'package:process_run/process_run.dart';
import 'package:provider/provider.dart';

class Pods extends StatefulWidget {
  Pods({
    super.key,
    required this.namespaces,
  });

  List<String> namespaces;

  @override
  State<Pods> createState() => _PodsState();
}

class _PodsState extends State<Pods> {
  bool isAutoRefresh = false;
  List<Pod> pods = [];
  List<Pod> selectedPods = [];
  bool isLoading = false;
  bool isRefreshing = false;
  bool isError = false;

  String dropdownValue = "All";

  Timer? timer;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    getPodsFromNameSpace(dropdownValue);

    DataProvider dataProvider =
        Provider.of<DataProvider>(context, listen: false);

    dataProvider.addListener(() {
      setState(() {
        isRefreshing = true;
      });
      getPodsFromNameSpace(dropdownValue);
    });
  }

  void getPodsFromNameSpace(String namespace) {
    setState(() {
      isError = false;
      selectedPods = [];
    });

    Shell shell = Shell();

    String command = namespace == "All"
        ? 'kubectl get po -A -o=jsonpath="{.items}"'
        : 'kubectl get po -n $namespace -o=jsonpath="{.items}"';

    shell.run(command).then(
      (result) {
        var items = jsonDecode(result[0].stdout as String) as List<dynamic>;

        List<Pod> fetchedPods = [];

        for (var item in items) {
          Pod pod = Pod(
            name: item['metadata']['name'],
            namespace: item['metadata']['namespace'],
            status: item['status']['phase'],
            restarts: item['status']['containerStatuses'][0]['restartCount'],
            age: item['metadata']['creationTimestamp'],
          );

          fetchedPods.add(pod);
        }

        setState(() {
          isLoading = false;
          isRefreshing = false;
          pods = fetchedPods;
        });
      },
    ).catchError((error) {
      print("Error in pods: $error");
      setState(() {
        isError = true;
        isLoading = false;
        isRefreshing = false;
      });
    });
  }

  void refreshPods() {
    setState(() {
      isRefreshing = true;
    });
    getPodsFromNameSpace(dropdownValue);
  }

  void refreshPod(String podName, String namespace) {
    setState(() {
      isRefreshing = true;
    });
    Shell shell = Shell();

    shell.run('kubectl delete pod $podName -n $namespace').then((result) {
      setState(() {
        dropdownValue = "All";
        getPodsFromNameSpace(dropdownValue);
      });
    });
  }

  void startAutoRefresh() {
    timer = Timer.periodic(
      const Duration(seconds: 10),
      (timer) {
        refreshPods();
      },
    );
  }

  void stopAutoRefresh() {
    if (timer != null) {
      timer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    void openLogs(String name, String namespace) {
      showDialog(
        context: context,
        builder: (context) {
          return TerminalScreen(name: name, namespace: namespace);
        },
      );
    }

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Pods"),
          SizedBox(
            width: width * 0.01,
          ),
          FilterDropDown(
            onChanged: (String? newValue) {
              setState(() {
                dropdownValue = newValue!;
                isLoading = true;
                getPodsFromNameSpace(dropdownValue);
              });
            },
            namespaces: widget.namespaces,
            dropdownValue: dropdownValue,
          ),
          const SizedBox(
            width: 30,
          ),
          selectedPods.isEmpty
              ? Container()
              : ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Restart Pods"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                  "Are you sure you want to restart the selected pods?"),
                              const SizedBox(height: 10),
                              Text(selectedPods.map((e) => e.name).join(", ")),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, false);
                              },
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                for (var pod in selectedPods) {
                                  Shell shell = Shell();
                                  shell
                                      .run(
                                          'kubectl delete pod ${pod.name} -n ${pod.namespace}')
                                      .then((result) {});
                                }
                                Navigator.pop(context, true);
                              },
                              child: const Text("Delete"),
                            ),
                          ],
                        );
                      },
                    ).then((value) {
                      if (!value) {
                        return;
                      }

                      setState(() {
                        selectedPods = [];
                        isLoading = true;
                        dropdownValue = "All";
                      });

                      Timer.periodic(
                        const Duration(seconds: 5),
                        (timer) {
                          getPodsFromNameSpace(dropdownValue);
                          timer.cancel();
                        },
                      );
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    textStyle: MaterialStateProperty.all(
                      const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  icon: const Icon(FontAwesomeIcons.refresh),
                  label: const Text(
                    "Refresh Pods",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(5),
            width: width * 0.1,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Switch(
                  value: isAutoRefresh,
                  onChanged: (value) {
                    setState(() {
                      isAutoRefresh = value;
                    });

                    if (value) {
                      startAutoRefresh();
                    } else {
                      stopAutoRefresh();
                    }
                  },
                ),
                const SizedBox(
                  width: 10,
                ),
                isRefreshing
                    ? const SizedBox(
                        height: 30,
                        width: 30,
                        child: CircularProgressIndicator())
                    : IconButton(
                        onPressed: isAutoRefresh
                            ? null
                            : () {
                                refreshPods();
                              },
                        icon: const Icon(
                          FontAwesomeIcons.sync,
                          color: Colors.blue,
                        ),
                      )
              ],
            ),
          )
        ],
      ),
      content: SizedBox(
        width: width,
        child: Card(
          child: isError
              ? const Center(
                  child: Text("Error fetching pods"),
                )
              : isLoading
                  ? SizedBox(
                      height: height * 0.6,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : pods.isEmpty
                      ? const Center(child: Text("No Pods"))
                      : SingleChildScrollView(
                          child: isLoading
                              ? SizedBox(
                                  width: width,
                                  height: height * 0.6,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : Column(
                                  children: [
                                    ...pods.map(
                                      (pod) {
                                        return ListTile(
                                          title: Text(pod.name),
                                          leading: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Checkbox(
                                                value:
                                                    selectedPods.contains(pod),
                                                onChanged: (value) {
                                                  setState(() {
                                                    if (value!) {
                                                      selectedPods.add(pod);
                                                    } else {
                                                      selectedPods.remove(pod);
                                                    }
                                                  });
                                                },
                                              ),
                                              const SizedBox(width: 10),
                                              const Icon(
                                                FontAwesomeIcons.cloud,
                                                color: Colors.blue,
                                              ),
                                            ],
                                          ),
                                          subtitle: Text(pod.namespace),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                pod.restarts.toString(),
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ),
                                              const SizedBox(width: 20),
                                              PodStatus(status: pod.status),
                                              const SizedBox(width: 10),
                                              Text(
                                                Utils()
                                                    .getTimeDifference(pod.age),
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 20,
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  refreshPod(
                                                      pod.name, pod.namespace);
                                                },
                                                icon: const Icon(
                                                  FontAwesomeIcons
                                                      .arrowRotateRight,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 20,
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  openLogs(
                                                      pod.name, pod.namespace);
                                                },
                                                icon: const Icon(
                                                    FontAwesomeIcons.terminal),
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                        ),
        ),
      ),
    );
  }
}
