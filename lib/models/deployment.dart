class Deployment {
  final String name;
  final String namespace;
  final String ready;
  final String upToDate;
  final String available;

  Deployment({
    required this.name,
    required this.namespace,
    required this.ready,
    required this.upToDate,
    required this.available,
  });

  factory Deployment.fromJson(Map<String, dynamic> json) {
    return Deployment(
      name: json['name'],
      namespace: json['namespace'],
      ready: json['ready'],
      upToDate: json['upToDate'],
      available: json['available'],
    );
  }
}
