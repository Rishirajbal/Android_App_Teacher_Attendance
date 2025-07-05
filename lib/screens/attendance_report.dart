import 'package:flutter/material.dart';
import '../models/teacher_data.dart';
import '../services/storage_service.dart';

class AttendanceReportPage extends StatefulWidget {
  final bool isTeluguLanguage;

  const AttendanceReportPage({super.key, required this.isTeluguLanguage});

  @override
  State<AttendanceReportPage> createState() => _AttendanceReportPageState();
}

class _AttendanceReportPageState extends State<AttendanceReportPage> {
  String _selectedDay = '';
  TeacherData? _teacherData;
  bool _isLoading = true;
  List<String> _availableDays = [];

  @override
  void initState() {
    super.initState();
    _loadTeacherData();
  }

  Future<void> _loadTeacherData() async {
    try {
      final data = await StorageService.getTeacherData();
      if (data != null) {
        // Filter to only include days that have actual classes
        List<String> activeDays = [];
        for (String day in data.timetable.keys) {
          bool hasClasses = data.timetable[day]!.values.any(
            (subject) => subject.isNotEmpty,
          );
          if (hasClasses) {
            activeDays.add(day);
          }
        }

        setState(() {
          _teacherData = data;
          _availableDays = activeDays;
          _isLoading = false;
          if (activeDays.isNotEmpty) {
            _selectedDay = activeDays.first;
          }
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String getTranslatedText(String english, String telugu) {
    return widget.isTeluguLanguage ? telugu : english;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(getTranslatedText('Attendance Report', 'హాజరు నివేదిక')),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_teacherData == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(getTranslatedText('Attendance Report', 'హాజరు నివేదిక')),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                getTranslatedText(
                  'No data found. Please complete setup first.',
                  'డేటా కనుగొనబడలేదు. దయచేసి ముందుగా సెటప్ పూర్తి చేయండి.',
                ),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslatedText('Attendance Report', 'హాజరు నివేదిక')),
      ),
      body: Column(
        children: [
          // Teacher and class info header
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.school,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_teacherData!.teacherName} - ${_teacherData!.subject}',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_teacherData!.className} • ${_teacherData!.students.length} ${getTranslatedText('students', 'విద్యార్థులు')}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Day selection
          if (_teacherData!.timetable.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButtonFormField<String>(
                value: _selectedDay,
                decoration: InputDecoration(
                  labelText: getTranslatedText('Day', 'రోజు'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items:
                    _availableDays
                        .map(
                          (day) =>
                              DropdownMenuItem(value: day, child: Text(day)),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedDay = value);
                  }
                },
              ),
            ),

          const SizedBox(height: 16),

          // Attendance table
          Expanded(child: _buildAttendanceTable()),

          // Legend
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        getTranslatedText(
                          'Green Check: Present | Red X: Absent | Grey: No data',
                          'ఆకుపచ్చ టిక్: హాజరు | ఎరుపు X: గైర్హాజరు | బూడిద: డేటా లేదు',
                        ),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTable() {
    if (_teacherData!.timetable.isEmpty || _selectedDay.isEmpty) {
      return Center(
        child: Text(
          getTranslatedText(
            'No timetable data available',
            'టైమ్‌టేబుల్ డేటా అందుబాటులో లేదు',
          ),
        ),
      );
    }

    final daySchedule = _teacherData!.timetable[_selectedDay] ?? {};
    final timeSlots =
        daySchedule.keys
            .where((slot) => daySchedule[slot]?.isNotEmpty == true)
            .toList();

    if (timeSlots.isEmpty) {
      return Center(
        child: Text(
          getTranslatedText(
            'No classes scheduled for $_selectedDay',
            '$_selectedDay కోసం ఎటువంటి క్లాసులు షెడ్యూల్ చేయబడలేదు',
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: DataTable(
              columnSpacing: 20,
              horizontalMargin: 10,
              columns: [
                DataColumn(
                  label: SizedBox(
                    width: 120,
                    child: Text(
                      getTranslatedText('Student', 'విద్యార్థి'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                ...timeSlots.map(
                  (slot) => DataColumn(
                    label: SizedBox(
                      width: 100,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            slot,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            daySchedule[slot] ?? '',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              rows:
                  _teacherData!.students.map((student) {
                    final date = DateTime.now().toString().split(' ')[0];
                    return DataRow(
                      cells: [
                        DataCell(
                          SizedBox(
                            width: 120,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  student.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${getTranslatedText('Roll:', 'రోల్:')} ${student.rollNumber}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey[600]),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                        ...timeSlots.map((slot) {
                          final isPresent = student.attendance[date]?[slot];

                          return DataCell(
                            SizedBox(
                              width: 100,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isPresent == null
                                          ? Colors.grey.withOpacity(0.1)
                                          : isPresent
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isPresent == null
                                          ? Icons.help_outline
                                          : isPresent
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      color:
                                          isPresent == null
                                              ? Colors.grey
                                              : isPresent
                                              ? Colors.green
                                              : Colors.red,
                                      size: 18,
                                    ),
                                    const SizedBox(height: 2),
                                    Flexible(
                                      child: Text(
                                        isPresent == null
                                            ? getTranslatedText(
                                              'No data',
                                              'డేటా లేదు',
                                            )
                                            : isPresent
                                            ? getTranslatedText(
                                              'Present',
                                              'హాజరు',
                                            )
                                            : getTranslatedText(
                                              'Absent',
                                              'గైర్హాజరు',
                                            ),
                                        style: TextStyle(
                                          fontSize: 9,
                                          color:
                                              isPresent == null
                                                  ? Colors.grey
                                                  : isPresent
                                                  ? Colors.green
                                                  : Colors.red,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
