import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kubernetes_dashboard/providers/data_provider.dart';
import 'package:provider/provider.dart';

class Namespaces extends StatefulWidget {
  const Namespaces({
    super.key,
    required this.namespaces,
    required this.isLoading,
    required this.refreshCallback,
    required this.isRefreshing,
  });

  final List<String> namespaces;
  final bool isLoading;
  final bool isRefreshing;
  final Function() refreshCallback;

  @override
  State<Namespaces> createState() => _NamespacesState();
}

class _NamespacesState extends State<Namespaces> {
  @override
  void initState() {
    super.initState();

    DataProvider dataProvider =
        Provider.of<DataProvider>(context, listen: false);

    dataProvider.addListener(() {
      widget.refreshCallback();
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
            const Text("Namespaces"),
            widget.isRefreshing
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
                      widget.refreshCallback();
                    },
                  ),
          ],
        ),
        content: SizedBox(
          width: width,
          child: widget.isLoading
              ? SizedBox(
                  height: height * 0.5,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: widget.namespaces.map((namespace) {
                      return ListTile(
                        title: Text(namespace),
                        trailing: const IconButton(
                          icon: Icon(
                            FontAwesomeIcons.trash,
                            color: Colors.red,
                          ),
                          onPressed: null,
                        ),
                      );
                    }).toList(),
                  ),
                ),
        ),
      ),
    );
  }
}
