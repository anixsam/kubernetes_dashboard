import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kubernetes_dashboard/models/service.dart';
import 'package:kubernetes_dashboard/providers/data_provider.dart';
import 'package:kubernetes_dashboard/shared/utils.dart';
import 'package:kubernetes_dashboard/widgets/filter_dropdown.dart';
import 'package:process_run/process_run.dart';
import 'package:provider/provider.dart';

class Services extends StatefulWidget {
  const Services({
    super.key,
    required this.namespaces,
  });

  final List<String> namespaces;

  @override
  State<Services> createState() => _ServicesState();
}

class _ServicesState extends State<Services> {
  bool isLoading = false;
  bool isRefreshing = false;

  List<Service> services = [];

  String dropdownValue = "All";

  @override
  void initState() {
    super.initState();

    setState(() {
      isLoading = true;
    });
    getServicesFromNamespace(dropdownValue);

    DataProvider dataProvider =
        Provider.of<DataProvider>(context, listen: false);

    dataProvider.addListener(() {
      setState(() {
        isRefreshing = true;
      });
      getServicesFromNamespace(dropdownValue);
    });
  }

  getServicesFromNamespace(String namespace) {
    Shell shell = Shell();
    String command = dropdownValue == "All"
        ? 'kubectl get svc -A -o=jsonpath="{.items}"'
        : 'kubectl get svc -n $namespace -o=jsonpath="{.items}"';
    shell.run(command).then((result) {
      var items = jsonDecode(result[0].stdout as String) as List<dynamic>;
      List<Service> fetchedServices = [];
      for (var item in items) {
        print("Service: $item");
        Service service = Service(
          name: item['metadata']['name'],
          namespace: item['metadata']['namespace'],
          type: item['spec']['type'],
          clusterIP: item['spec']['clusterIP'],
          externalIP: item['spec']['loadBalancerIP'] ?? "None",
          age: item['metadata']['creationTimestamp'],
          ports: item['spec']['ports'],
        );
        fetchedServices.add(service);
      }
      setState(() {
        services = fetchedServices;
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
            const Text("Services"),
            FilterDropDown(
              onChanged: (newValue) {
                setState(() {
                  dropdownValue = newValue!;
                  isLoading = true;
                  getServicesFromNamespace(dropdownValue);
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
                        getServicesFromNamespace(dropdownValue);
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
              : services.isEmpty
                  ? const Center(
                      child: Text("No deployments found"),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: services.map((service) {
                          return ListTile(
                              title: Text(service.name),
                              leading: const Icon(
                                FontAwesomeIcons.server,
                                color: Colors.blue,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(service.namespace),
                                  Text(service.type),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                      "Age: ${Utils().getTimeDifference(service.age)}"),
                                  const IconButton(
                                    icon: Icon(
                                      FontAwesomeIcons.trash,
                                      color: Colors.red,
                                    ),
                                    onPressed: null,
                                  ),
                                ],
                              ));
                        }).toList(),
                      ),
                    ),
        ),
      ),
    );
  }
}
