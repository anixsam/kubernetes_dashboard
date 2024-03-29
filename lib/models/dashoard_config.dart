
class DashboardConfig {
  bool pod;
  bool node;
  bool deployment;
  bool services;
  bool virtualService;
  bool namespace;
  bool metrics;

  DashboardConfig({
    required this.pod,
    required this.node,
    required this.deployment,
    required this.services,
    required this.virtualService,
    required this.namespace,
    required this.metrics,
  });

  factory DashboardConfig.fromJson(Map<String, dynamic> json) {
    return DashboardConfig(
      pod: json['pod'],
      node: json['node'],
      deployment: json['deployment'],
      services: json['services'],
      virtualService: json['virtualService'],
      namespace: json['namespace'],
      metrics: json['metrics'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pod': pod,
      'node': node,
      'deployment': deployment,
      'services': services,
      'virtualService': virtualService,
      'namespace': namespace,
      'metrics': metrics,
    };
  }
}
