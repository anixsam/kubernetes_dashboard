import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kubernetes_dashboard/models/virtual_service.dart';
import 'package:kubernetes_dashboard/providers/data_provider.dart';
import 'package:kubernetes_dashboard/shared/utils.dart';
import 'package:kubernetes_dashboard/widgets/filter_dropdown.dart';
import 'package:process_run/process_run.dart';
import 'package:provider/provider.dart';

class VirtualServices extends StatefulWidget {
  const VirtualServices({
    super.key,
    required this.namespaces,
  });

  final List<String> namespaces;

  @override
  State<VirtualServices> createState() => _VirtualServicesState();
}

class _VirtualServicesState extends State<VirtualServices> {
  bool isLoading = false;
  bool isRefreshing = false;
  List<VirtualService> virtualServices = [];
  String dropdownValue = "All";

  @override
  void initState() {
    super.initState();

    setState(() {
      isLoading = true;
    });
    getVirtualServicesFromNamespace(dropdownValue);

    DataProvider dataProvider =
        Provider.of<DataProvider>(context, listen: false);

    dataProvider.addListener(() {
      print("Refreshing Virtual Services");
      setState(() {
        isRefreshing = true;
      });
      getVirtualServicesFromNamespace(dropdownValue);
    });
  }

  getVirtualServicesFromNamespace(String namespace) {
    Shell shell = Shell();
    String command = dropdownValue == "All"
        ? 'kubectl get vs -A -o=jsonpath="{.items}"'
        : 'kubectl get vs -n $namespace -o=jsonpath="{.items}"';
    shell.run(command).then((result) {
      var items = jsonDecode(result[0].stdout as String) as List<dynamic>;
      List<VirtualService> fetchedVirtualServices = [];
      for (var item in items) {
        print("Virtual Service: $item");
        VirtualService virtualService = VirtualService(
          name: item['metadata']['name'],
          namespace: item['metadata']['namespace'],
          hosts: item['spec']['hosts'],
          gateways: item['spec']['gateways'],
          age: item['metadata']['creationTimestamp'],
        );
        fetchedVirtualServices.add(virtualService);
      }
      setState(() {
        virtualServices = fetchedVirtualServices;
        isLoading = false;
        isRefreshing = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Virtual Services"),
            FilterDropDown(
              onChanged: (newValue) {
                setState(() {
                  dropdownValue = newValue!;
                  isLoading = true;
                  getVirtualServicesFromNamespace(dropdownValue);
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
                      setState(
                        () {
                          isRefreshing = true;
                          getVirtualServicesFromNamespace(dropdownValue);
                        },
                      );
                    },
                  ),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : virtualServices.isEmpty
                  ? const Center(
                      child: Text("No virtual services found"),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          for (var virtualService in virtualServices)
                            ListTile(
                              title: Text(virtualService.name),
                              leading: const Icon(
                                FontAwesomeIcons.database,
                                color: Colors.blue,
                              ),
                              subtitle: Text(virtualService.namespace),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                      "Age: ${Utils().getTimeDifference(virtualService.age)}"),
                                  const IconButton(
                                    icon: Icon(
                                      FontAwesomeIcons.trash,
                                      color: Colors.red,
                                    ),
                                    onPressed: null,
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
