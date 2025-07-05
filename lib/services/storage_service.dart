import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/teacher_data.dart';

class StorageService {
  static const String _isFirstLaunchKey = 'is_first_launch';
  static const String _teacherDataKey = 'teacher_data';
  static const String _isSetupCompleteKey = 'is_setup_complete';

  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isFirstLaunchKey) ?? true;
  }

  static Future<void> setFirstLaunchComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isFirstLaunchKey, false);
  }

  static Future<void> resetApp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<bool> isSetupComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isSetupCompleteKey) ?? false;
  }

  static Future<void> setSetupComplete(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isSetupCompleteKey, value);
  }

  static Future<TeacherData?> getTeacherData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_teacherDataKey);
    print('DEBUG: Getting teacher data, found JSON: ${jsonString != null}');
    if (jsonString != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(jsonString);
        print('DEBUG: Decoded JSON keys: ${json.keys.toList()}');
        final teacherData = TeacherData.fromJson(json);
        print('DEBUG: Loaded teacher data - Teacher: ${teacherData.teacherName}, Students: ${teacherData.students.length}, Timetable days: ${teacherData.timetable.keys.length}');
        return teacherData;
      } catch (e) {
        print('Error loading teacher data: $e');
        return null;
      }
    }
    print('DEBUG: No teacher data found in storage');
    return null;
  }

  static Future<void> saveTeacherData(TeacherData teacherData) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(teacherData.toJson());
    print('DEBUG: Saving teacher data - Teacher: ${teacherData.teacherName}, Students: ${teacherData.students.length}, Timetable days: ${teacherData.timetable.keys.length}');
    print('DEBUG: JSON length: ${jsonString.length}');
    await prefs.setString(_teacherDataKey, jsonString);
    print('DEBUG: Teacher data saved successfully');
  }

  static Future<void> updateStudentAttendance(
    String studentName,
    String date,
    String timeSlot,
    bool isPresent,
  ) async {
    final teacherData = await getTeacherData();
    if (teacherData != null) {
      final updatedStudents =
          teacherData.students.map((student) {
            if (student.name == studentName) {
              final updatedAttendance = Map<String, Map<String, bool>>.from(
                student.attendance,
              );
              if (!updatedAttendance.containsKey(date)) {
                updatedAttendance[date] = {};
              }
              updatedAttendance[date]![timeSlot] = isPresent;

              return student.copyWith(attendance: updatedAttendance);
            }
            return student;
          }).toList();

      final updatedTeacherData = teacherData.copyWith(
        students: updatedStudents,
      );
      await saveTeacherData(updatedTeacherData);
    }
  }
}
