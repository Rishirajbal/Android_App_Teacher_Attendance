class TimeSlot {
  final String time;
  final Map<String, String> subjects; // {day: subject}

  TimeSlot({required this.time, required this.subjects});
}

class TimeTable {
  static final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  static final List<String> timeSlots = [
    '8:00-9:00',
    '9:00-10:00',
    '10:00-11:00',
    '11:00-12:00',
  ];

  static final Map<String, Map<String, String>> schedule = {
    '8:00-9:00': {
      'Mon': 'Math',
      'Tue': 'Science',
      'Wed': 'English',
      'Thu': 'History',
      'Fri': 'Math',
    },
    '9:00-10:00': {
      'Mon': 'Science',
      'Tue': 'Math',
      'Wed': 'History',
      'Thu': 'English',
      'Fri': 'English',
    },
    '10:00-11:00': {
      'Mon': 'English',
      'Tue': 'History',
      'Wed': 'Math',
      'Thu': 'Science',
      'Fri': 'Science',
    },
    '11:00-12:00': {
      'Mon': 'History',
      'Tue': 'English',
      'Wed': 'Science',
      'Thu': 'Math',
      'Fri': 'History',
    },
  };

  static String getSubject(String time, String day) {
    return schedule[time]?[day] ?? '';
  }
}
