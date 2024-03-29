class Service {
  final String name;
  final String namespace;
  final String clusterIP;
  final String externalIP;
  final List<dynamic> ports;
  final String type;
  final String age;

  Service({
    required this.name,
    required this.namespace,
    required this.clusterIP,
    required this.externalIP,
    required this.ports,
    required this.age,
    required this.type,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      name: json['name'],
      namespace: json['namespace'],
      clusterIP: json['clusterIP'],
      externalIP: json['externalIP'],
      ports: json['ports'],
      age: json['age'],
      type: json['type'],
    );
  }
}
