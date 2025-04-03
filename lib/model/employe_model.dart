class Employee {
  int? id;
  String name;
  String role;
  DateTime startDate;
  DateTime? endDate;

  Employee({
    this.id,
    required this.name,
    required this.role,
    required this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate?.millisecondsSinceEpoch,
    };
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'],
      name: map['name'],
      role: map['role'],
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate']),
      endDate:
          map['endDate'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['endDate'])
              : null,
    );
  }
}
