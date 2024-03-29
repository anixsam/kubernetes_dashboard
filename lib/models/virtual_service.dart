class VirtualService {
  final String name;
  final String namespace;
  final List<dynamic> hosts;
  final List<dynamic> gateways;
  final String age;

  VirtualService({
    required this.name,
    required this.namespace,
    required this.hosts,
    required this.gateways,
    required this.age,
  });

  factory VirtualService.fromJson(Map<String, dynamic> json) {
    return VirtualService(
      name: json['name'],
      namespace: json['namespace'],
      hosts: json['hosts'],
      gateways: json['gateways'],
      age: json['age'],
    );
  }
}
