import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kubernetes_dashboard/models/dashoard_config.dart';
import 'package:kubernetes_dashboard/providers/dashboard_config_provider.dart';
import 'package:kubernetes_dashboard/themes/custom_colors.dart';
import 'package:kubernetes_dashboard/components/cluster_dialog.dart';
import 'package:kubernetes_dashboard/widgets/dashboard_config_dialog.dart';
import 'package:process_run/process_run.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String currentContext = "";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    getCurrentContext();
  }

  void getCurrentContext() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? currentContextFromPref = prefs.getString("currentContext");

    if (currentContextFromPref == null) {
      Shell shell = Shell();

      shell.run('kubectl config current-context').then((result) {
        String context = result[0].stdout as String;

        prefs.setString("currentContext", context);
        currentContextFromPref = context;

        setState(() {
          currentContext = currentContextFromPref!;
        });
      });
    } else {
      setState(() {
        currentContext = currentContextFromPref!;
      });
    }
  }

  void setContext(String context) {
    Shell shell = Shell();

    shell.run('kubectl config use-context $context').then((result) {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString("currentContext", context);

        setState(() {
          currentContext = context;
        });
      });
    }).catchError((error) {
      print(error);
    });
  }

  void openContextDialog() {
    setState(() {
      isLoading = true;
    });

    List<String> contexts = [];

    Shell shell = Shell();

    shell.run('kubectl config get-contexts -o=\'name\'').then((result) {
      String output = result[0].stdout;

      List<String> contextList = output.split("\n");

      for (String line in contextList) {
        if (line.trim() != "") {
          contexts.add(line);
        }
      }

      setState(() {
        isLoading = false;
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          final CustomColors customTheme =
              Theme.of(context).extension<CustomColors>()!;
          return AlertDialog(
            title: const Text("Select Context"),
            content: Container(
              alignment: Alignment.center,
              width: double.maxFinite,
              child: ListView.builder(
                itemCount: contexts.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    trailing: Icon(
                      FontAwesomeIcons.cloud,
                      color: (currentContext != contextList[index])
                          ? customTheme.iconColor
                          : Colors.green,
                    ),
                    title: Text(contexts[index]),
                    onTap: () {
                      setContext(contextList[index]);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Close"),
              )
            ],
          );
        },
      );
    }).catchError((error) {
      setState(() {
        isLoading = false;
      });
      print(error);
    });
  }

  void openClusterDialog() {
    showDialog(context: context, builder: (context) => const ClusterDialog());
  }

  void openDasboardConfig() {
    DashboardConfig dashboardConfig =
        Provider.of<DashboardConfigProvider>(context, listen: false)
            .dashboardConfig!;

    Map<String, bool> newDashboardConfig = {
      "pod": dashboardConfig.pod,
      "deployment": dashboardConfig.deployment,
      "node": dashboardConfig.node,
      "services": dashboardConfig.services,
      "virtualService": dashboardConfig.virtualService,
      "namespace": dashboardConfig.namespace,
      "metrics": dashboardConfig.metrics,
    };

    showDialog(
      context: context,
      builder: (context) {
        return DashboardConfigDialog(
          newDashboardConfig: newDashboardConfig,
        );
      },
    ).then((value) => {
          if (value is Map<String, bool>)
            {
              Provider.of<DashboardConfigProvider>(context, listen: false)
                  .setDashboardConfig(DashboardConfig(
                pod: value["pod"]!,
                deployment: value["deployment"]!,
                node: value["node"]!,
                services: value["services"]!,
                virtualService: value["virtualService"]!,
                namespace: value["namespace"]!,
                metrics: value["metrics"]!,
              ))
            }
        });
  }

  @override
  Widget build(BuildContext context) {
    DashboardConfigProvider dashboardConfigProvider =
        Provider.of<DashboardConfigProvider>(context);

    return isLoading
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Card(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text("Contexts"),
                          subtitle: Text(
                            currentContext == ""
                                ? "Set Current Context"
                                : currentContext,
                          ),
                          trailing: IconButton(
                            icon: const Icon(FontAwesomeIcons.chevronRight),
                            onPressed: () {
                              openContextDialog();
                            },
                          ),
                        ),
                        ListTile(
                          title: const Text("Add new Cluster"),
                          subtitle: const Text("Add new cluster to kubeconfig"),
                          trailing: IconButton(
                            icon: const Icon(FontAwesomeIcons.plus),
                            onPressed: () {
                              openClusterDialog();
                            },
                          ),
                        ),
                        ListTile(
                          title: const Text("Configure Dashboard"),
                          subtitle: const Text("Configure Dashboard settings"),
                          trailing: IconButton(
                            icon: const Icon(FontAwesomeIcons.cog),
                            onPressed: () {
                              openDasboardConfig();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}
