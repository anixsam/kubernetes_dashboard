import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kubernetes_dashboard/models/dashoard_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardConfigProvider extends ChangeNotifier {
  DashboardConfig _dashboardConfig = DashboardConfig(
    pod: false,
    deployment: false,
    node: false,
    services: false,
    virtualService: false,
    namespace: false,
    metrics: false,
  );
  bool isLoading = false;
  DashboardConfig? get dashboardConfig => _dashboardConfig;

  void setLoading(bool loading) {
    isLoading = loading;
    notifyListeners();
  }

  void setDashboardConfig(DashboardConfig dashboardConfig) {
    _dashboardConfig = dashboardConfig;
    notifyListeners();
  }

  Future<void> fetchDashboardConfig() async {
    setLoading(true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("dashboardConfig") == null) {
      DashboardConfig config = DashboardConfig(
        pod: true,
        deployment: true,
        node: true,
        services: true,
        virtualService: true,
        namespace: true,
        metrics: true,
      );
      setDashboardConfig(config);
      prefs.setString("dashboardConfig", jsonEncode(config.toJson()));
      setLoading(false);
    } else {
      DashboardConfig config = DashboardConfig.fromJson(
          jsonDecode(prefs.getString("dashboardConfig")!));

      setDashboardConfig(config);
      setLoading(false);
    }
  }
}
