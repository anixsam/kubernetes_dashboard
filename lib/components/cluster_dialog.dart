import 'package:flutter/material.dart';
import 'package:kubernetes_dashboard/widgets/file_picker.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';

class ClusterDialog extends StatefulWidget {
  const ClusterDialog({super.key});

  @override
  State<ClusterDialog> createState() => _ClusterDialogState();
}

class _ClusterDialogState extends State<ClusterDialog> {
  List<String> clusterType = ["Azure AKS", "Minikube"];

  String selectedClusterType = "Minikube";

  TextEditingController clusterNameController = TextEditingController();
  TextEditingController clusterUsernameController = TextEditingController();
  TextEditingController minikubeIPController = TextEditingController();
  TextEditingController minikubePortController = TextEditingController();
  XFile? caFile;
  XFile? clientCertFile;
  XFile? clientKeyFile;

  Widget getClusterTypeWidget(String clusterType) {
    if (clusterType == "Minikube") {
      return Column(
        children: [
          TextField(
            controller: clusterNameController,
            decoration: const InputDecoration(
              labelText: "Cluster Name",
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: clusterUsernameController,
            decoration: const InputDecoration(
              labelText: "Cluster Username (alias for the credentials)",
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: minikubeIPController,
            decoration: const InputDecoration(
              labelText: "Minikube IP",
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: minikubePortController,
            decoration: const InputDecoration(
              labelText: "Minikube Port",
            ),
          ),
          const SizedBox(height: 10),
          CustomFilePicker(
            filePath: caFile?.path,
            onBrowse: () {
              openFilePicker("ca");
            },
            labelText: "CA File",
          ),
          const SizedBox(height: 10),
          const Text("Client certificates (in profile directory)"),
          const SizedBox(height: 10),
          CustomFilePicker(
            filePath: clientCertFile?.path,
            onBrowse: () {
              openFilePicker("clientCert");
            },
            labelText: "Client Certificate File",
          ),
          const SizedBox(height: 10),
          CustomFilePicker(
            filePath: clientKeyFile?.path,
            onBrowse: () {
              openFilePicker("clientKey");
            },
            labelText: "Client Key File",
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  openFilePicker(String type) async {
    print("Opening file picker");
    try {
      XFile? result = await FileSelectorPlatform.instance.openFile(
        acceptedTypeGroups: [
          const XTypeGroup(
            label: 'Certificate Files',
            extensions: ['pem', 'crt', 'key'],
          ),
        ],
      );
      print(result?.path);
      if (result != null) {
        if (type == "ca") {
          setState(() {
            caFile = result;
          });
        } else if (type == "clientCert") {
          setState(() {
            clientCertFile = result;
          });
        } else if (type == "clientKey") {
          setState(() {
            clientKeyFile = result;
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cluster Configuration'),
      scrollable: true,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Close"),
        ),
        TextButton(
          onPressed: () {
            // validateClusterConfig();
            Navigator.of(context).pop();
          },
          child: const Text("Save"),
        ),
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<String>(
            items: clusterType.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                selectedClusterType = value!;
              });
            },
            value: selectedClusterType,
          ),
          getClusterTypeWidget(selectedClusterType)
        ],
      ),
    );
  }
}
