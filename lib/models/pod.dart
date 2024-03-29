class Pod {
  final String name;
  final String namespace;
  final String status;
  final int restarts;
  final String age;

  Pod({
    required this.name,
    required this.namespace,
    required this.status,
    required this.restarts,
    required this.age,
  });

  factory Pod.fromJson(Map<String, dynamic> json) {
    return Pod(
      name: json['name'],
      namespace: json['namespace'],
      status: json['status'],
      restarts: json['restarts'],
      age: json['age'],
    );
  }
}
