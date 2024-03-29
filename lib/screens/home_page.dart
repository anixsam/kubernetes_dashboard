import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kubernetes_dashboard/providers/dashboard_config_provider.dart';
import 'package:kubernetes_dashboard/providers/data_provider.dart';
import 'package:kubernetes_dashboard/widgets/appbar.dart';
import 'package:kubernetes_dashboard/components/deployments.dart';
import 'package:kubernetes_dashboard/components/graph_collection.dart';
import 'package:kubernetes_dashboard/components/namespaces.dart';
import 'package:kubernetes_dashboard/components/pods.dart';
import 'package:kubernetes_dashboard/components/services.dart';
import 'package:kubernetes_dashboard/components/virtual_services.dart';
import 'package:process_run/process_run.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String currentContext = "";
  bool isLoading = false;
  bool isAutoRefresh = false;
  List<String> namespaces = [];

  bool isNameSpaceLoading = false;
  bool isNameSpaceRefreshing = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      isNameSpaceLoading = true;
      isLoading = true;
    });

    init();
    getNameSpaces();
  }

  void init() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? currentContextFromPref = prefs.getString("currentContext");

    setState(() {
      isLoading = false;
      currentContextFromPref == null
          ? currentContext = ""
          : currentContext = currentContextFromPref;
    });

    DataProvider dataProvider =
        Provider.of<DataProvider>(context, listen: false);

    dataProvider.addListener(() {
      setState(() {
        isLoading = true;
      });
      getNameSpaces();
    });
  }

  void getNameSpaces() async {
    Shell shell = Shell();

    shell.run('kubectl get ns -o=jsonpath=\'{.items[*].metadata.name}\'').then(
      (result) {
        var items = (result[0].stdout as String).split(" ");

        List<String> fetchedStrings = [];

        for (var item in items) {
          if (item.isNotEmpty) {
            fetchedStrings.add(item);
          }
        }

        setState(() {
          namespaces = fetchedStrings;
          isLoading = false;
          isNameSpaceLoading = false;
          isNameSpaceRefreshing = false;
        });
      },
    );
  }

  void refreshNameSpaces() {
    setState(() {
      isNameSpaceRefreshing = true;
    });

    getNameSpaces();
  }

  void refreshAll() {
    var dataProvider = Provider.of<DataProvider>(context, listen: false);

    dataProvider.onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    DashboardConfigProvider dashboardConfigProvider =
        Provider.of<DashboardConfigProvider>(context);

    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            refreshAll();
          },
          child: const Icon(FontAwesomeIcons.arrowRotateLeft),
        ),
        appBar: CustomAppBar(
          title: "Dashboard",
          actions: [
            Text(
              "Current Context: $currentContext",
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(
              width: 20,
            ),
            const Padding(
              padding: EdgeInsets.only(right: 20),
              child: Icon(FontAwesomeIcons.cog),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              dashboardConfigProvider.dashboardConfig!.metrics
                  ? Container(
                      width: width,
                      alignment: Alignment.center,
                      height: height * 0.35,
                      child: const GraphCollection(),
                    )
                  : Container(),
              dashboardConfigProvider.dashboardConfig!.pod
                  ? SizedBox(
                      width: width,
                      height: height * 0.6,
                      child: Pods(namespaces: namespaces),
                    )
                  : Container(),
              const SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  dashboardConfigProvider.dashboardConfig!.namespace
                      ? Flexible(
                          fit: FlexFit.tight,
                          flex: 1,
                          child: SizedBox(
                            height: height * 0.5,
                            child: Namespaces(
                              namespaces: namespaces,
                              isLoading: isNameSpaceLoading,
                              isRefreshing: isNameSpaceRefreshing,
                              refreshCallback: refreshNameSpaces,
                            ),
                          ),
                        )
                      : Container(),
                  dashboardConfigProvider.dashboardConfig!.deployment
                      ? Flexible(
                          fit: FlexFit.tight,
                          flex: 1,
                          child: SizedBox(
                            height: height * 0.5,
                            child: Deployments(
                              namespaces: namespaces,
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
              Row(
                children: [
                  dashboardConfigProvider.dashboardConfig!.services
                      ? Flexible(
                          flex: 1,
                          child: SizedBox(
                            height: height * 0.5,
                            child: Services(
                              namespaces: namespaces,
                            ),
                          ),
                        )
                      : Container(),
                  dashboardConfigProvider.dashboardConfig!.virtualService
                      ? Flexible(
                          flex: 1,
                          child: SizedBox(
                            height: height * 0.5,
                            child: VirtualServices(
                              namespaces: namespaces,
                            ),
                          ),
                        )
                      : Container(),
                ],
              )
            ],
          ),
        ));
  }
}
