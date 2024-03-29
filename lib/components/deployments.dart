import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kubernetes_dashboard/models/deployment.dart';
import 'package:kubernetes_dashboard/providers/data_provider.dart';
import 'package:kubernetes_dashboard/widgets/filter_dropdown.dart';
import 'package:process_run/process_run.dart';
import 'package:provider/provider.dart';

class Deployments extends StatefulWidget {
  Deployments({
    super.key,
    required this.namespaces,
  });

  List<String> namespaces;

  @override
  State<Deployments> createState() => _DeploymentsState();
}

class _DeploymentsState extends State<Deployments> {
  String dropdownValue = "All";
  bool isLoading = false;
  List<Deployment> deployments = [];

  bool isRefreshing = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      isLoading = true;
    });

    getDeploymentsFromNamespace(dropdownValue);

    DataProvider dataProvider =
        Provider.of<DataProvider>(context, listen: false);

    dataProvider.addListener(() {
      setState(() {
        isRefreshing = true;
      });
      getDeploymentsFromNamespace(dropdownValue);
    });
  }

  void getDeploymentsFromNamespace(namespace) {
    Shell shell = Shell();

    String command = dropdownValue == "All"
        ? 'kubectl get deploy -A -o=jsonpath="{.items}"'
        : 'kubectl get deploy -n $namespace -o=jsonpath="{.items}"';

    shell.run(command).then((result) {
      var items = jsonDecode(result[0].stdout as String) as List<dynamic>;

      List<Deployment> fetchedDeployments = [];

      for (var item in items) {
        Deployment deployment = Deployment(
            name: item['metadata']['name'],
            namespace: item['metadata']['namespace'],
            available: item['status']['availableReplicas'].toString(),
            upToDate: item['status']['updatedReplicas'].toString(),
            ready:
                "${item['status']['readyReplicas']}/${item['status']['replicas']}");

        fetchedDeployments.add(deployment);
      }

      setState(() {
        deployments = fetchedDeployments;
        isLoading = false;
        isRefreshing = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return SizedBox(
      child: AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Deployments"),
            FilterDropDown(
              onChanged: (String? newValue) {
                setState(() {
                  dropdownValue = newValue!;
                  isLoading = true;
                  getDeploymentsFromNamespace(dropdownValue);
                });
              },
              namespaces: widget.namespaces,
              dropdownValue: dropdownValue,
            ),
            isRefreshing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(),
                  )
                : IconButton(
                    icon: const Icon(
                      FontAwesomeIcons.sync,
                      color: Colors.blue,
                    ),
                    onPressed: () {
                      setState(() {
                        isRefreshing = true;
                        getDeploymentsFromNamespace(dropdownValue);
                      });
                    },
                  ),
          ],
        ),
        content: SizedBox(
          width: width,
          child: isLoading
              ? SizedBox(
                  height: height * 0.5,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : deployments.isEmpty
                  ? const Center(
                      child: Text("No deployments found"),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: deployments.map((deployment) {
                          return ListTile(
                            title: Text(deployment.name),
                            leading: const Icon(FontAwesomeIcons.cube),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Namespace: ${deployment.namespace}"),
                                Text("Available: ${deployment.available}"),
                                Text("Up to date: ${deployment.upToDate}"),
                                Text("Ready: ${deployment.ready}"),
                              ],
                            ),
                            trailing: const IconButton(
                                icon: Icon(
                                  FontAwesomeIcons.trash,
                                  color: Colors.red,
                                ),
                                onPressed: null),
                          );
                        }).toList(),
                      ),
                    ),
        ),
      ),
    );
  }
}
