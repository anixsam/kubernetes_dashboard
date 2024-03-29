import 'package:flutter/material.dart';

class CustomFilePicker extends StatelessWidget {
  const CustomFilePicker({
    super.key,
    required this.filePath,
    required this.onBrowse,
    required this.labelText,
  });

  final String? filePath;
  final Function() onBrowse;
  final String? labelText;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              filePath ?? labelText ?? "Choose File",
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              print("Browse");
              onBrowse();
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            child: const Text("Browse"),
          ),
        ],
      ),
    );
  }
}
