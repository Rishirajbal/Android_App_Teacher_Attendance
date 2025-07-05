class TeacherData {
  final String teacherName;
  final String subject;
  final String className;
  final List<StudentInfo> students;
  final Map<String, Map<String, String>> timetable;
  final bool isSetupComplete;

  TeacherData({
    required this.teacherName,
    required this.subject,
    required this.className,
    required this.students,
    required this.timetable,
    this.isSetupComplete = false,
  });

  factory TeacherData.fromJson(Map<String, dynamic> json) {
    Map<String, Map<String, String>> timetableMap = {};
    if (json['timetable'] != null) {
      Map<String, dynamic> timetableJson = Map<String, dynamic>.from(
        json['timetable'],
      );
      for (String day in timetableJson.keys) {
        timetableMap[day] = Map<String, String>.from(timetableJson[day] ?? {});
      }
    }

    return TeacherData(
      teacherName: json['teacherName'] ?? '',
      subject: json['subject'] ?? '',
      className: json['className'] ?? '',
      students:
          (json['students'] as List<dynamic>?)
              ?.map((e) => StudentInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      timetable: timetableMap,
      isSetupComplete: json['isSetupComplete'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teacherName': teacherName,
      'subject': subject,
      'className': className,
      'students': students.map((e) => e.toJson()).toList(),
      'timetable': timetable,
      'isSetupComplete': isSetupComplete,
    };
  }

  TeacherData copyWith({
    String? teacherName,
    String? subject,
    String? className,
    List<StudentInfo>? students,
    Map<String, Map<String, String>>? timetable,
    bool? isSetupComplete,
  }) {
    return TeacherData(
      teacherName: teacherName ?? this.teacherName,
      subject: subject ?? this.subject,
      className: className ?? this.className,
      students: students ?? this.students,
      timetable: timetable ?? this.timetable,
      isSetupComplete: isSetupComplete ?? this.isSetupComplete,
    );
  }
}

class StudentInfo {
  final String name;
  final String rollNumber;
  final String faceEmbedding; // Will store face data later
  final Map<String, Map<String, bool>>
  attendance; // {date: {timeSlot: isPresent}}

  StudentInfo({
    required this.name,
    required this.rollNumber,
    this.faceEmbedding = '',
    Map<String, Map<String, bool>>? attendance,
  }) : attendance = attendance ?? {};

  factory StudentInfo.fromJson(Map<String, dynamic> json) {
    Map<String, Map<String, bool>> attendanceMap = {};
    if (json['attendance'] != null) {
      Map<String, dynamic> attendanceJson = Map<String, dynamic>.from(
        json['attendance'],
      );
      for (String date in attendanceJson.keys) {
        attendanceMap[date] = Map<String, bool>.from(
          attendanceJson[date] ?? {},
        );
      }
    }

    return StudentInfo(
      name: json['name'] ?? '',
      rollNumber: json['rollNumber'] ?? '',
      faceEmbedding: json['faceEmbedding'] ?? '',
      attendance: attendanceMap,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'rollNumber': rollNumber,
      'faceEmbedding': faceEmbedding,
      'attendance': attendance,
    };
  }

  StudentInfo copyWith({
    String? name,
    String? rollNumber,
    String? faceEmbedding,
    Map<String, Map<String, bool>>? attendance,
  }) {
    return StudentInfo(
      name: name ?? this.name,
      rollNumber: rollNumber ?? this.rollNumber,
      faceEmbedding: faceEmbedding ?? this.faceEmbedding,
      attendance: attendance ?? this.attendance,
    );
  }
}
