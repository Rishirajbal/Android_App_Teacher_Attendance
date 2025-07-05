class Student {
  final String id;
  final String name;
  final String rollNumber;
  final Map<String, Map<String, bool>>
  attendance; // {date: {timeSlot: isPresent}}

  Student({
    required this.id,
    required this.name,
    required this.rollNumber,
    Map<String, Map<String, bool>>? attendance,
  }) : attendance = attendance ?? {};

  Student copyWith({
    String? id,
    String? name,
    String? rollNumber,
    Map<String, Map<String, bool>>? attendance,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      rollNumber: rollNumber ?? this.rollNumber,
      attendance: attendance ?? this.attendance,
    );
  }
}
