import 'package:flutter/material.dart';

class FilterDropDown extends StatelessWidget {
  const FilterDropDown({
    super.key,
    required this.onChanged,
    required this.namespaces,
    required this.dropdownValue,
  });

  final Function(String?) onChanged;
  final List<String> namespaces;
  final String dropdownValue;

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
        value: dropdownValue,
        items: ["All", ...namespaces].map((String items) {
          return DropdownMenuItem(
            value: items,
            child: Text(items),
          );
        }).toList(),
        borderRadius: BorderRadius.circular(10),
        padding: const EdgeInsets.all(5),
        onChanged: onChanged);
  }
}
