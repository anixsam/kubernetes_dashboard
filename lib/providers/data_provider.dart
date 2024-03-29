import 'package:flutter/material.dart';

class DataProvider extends ChangeNotifier {
  onRefresh() {
    notifyListeners();
  }
}
