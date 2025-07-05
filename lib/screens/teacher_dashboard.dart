import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:intl/intl.dart';
import '../models/teacher_data.dart';
import 'camera_attendance.dart';
import 'attendance_report.dart';
import 'login_page.dart';
import '../services/storage_service.dart';

class TeacherDashboard extends StatefulWidget {
  final List<CameraDescription> cameras;
  final bool isTeluguLanguage;

  const TeacherDashboard({
    super.key,
    required this.cameras,
    this.isTeluguLanguage = false,
  });

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  bool _isTeluguLanguage = false;
  TeacherData? _teacherData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _isTeluguLanguage = widget.isTeluguLanguage;
    _loadTeacherData();
  }

  Future<void> _loadTeacherData() async {
    try {
      final data = await StorageService.getTeacherData();
      setState(() {
        _teacherData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
  }

  // Public method to refresh data
  void refreshData() {
    _loadTeacherData();
  }

  String getTranslatedText(String english, String telugu) {
    return _isTeluguLanguage ? telugu : english;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                getTranslatedText(
                  'Loading your data...',
                  'మీ డేటాను లోడ్ చేస్తున్నాము...',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              // Background gradient
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.05),
                        Theme.of(context).colorScheme.surface,
                        Theme.of(
                          context,
                        ).colorScheme.secondary.withOpacity(0.05),
                      ],
                    ),
                  ),
                ),
              ),
              // Main content
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with language toggle and show details button
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        getTranslatedText(
                                          'TSWREIS Attendance System',
                                          'TSWREIS హాజరు వ్యవస్థ',
                                        ),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleLarge?.copyWith(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    // Show Teacher Details Button
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: TextButton.icon(
                                        icon: const Icon(Icons.person),
                                        label: Text(
                                          getTranslatedText(
                                            'Show Details',
                                            'వివరాలు చూపించు',
                                          ),
                                        ),
                                        onPressed: _showTeacherDetails,
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _buildTimeWidget(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextButton.icon(
                              icon: const Icon(Icons.language),
                              label: Text(
                                _isTeluguLanguage ? 'English' : 'తెలుగు',
                              ),
                              onPressed: () {
                                setState(() {
                                  _isTeluguLanguage = !_isTeluguLanguage;
                                });
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Reset button with warning
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.restart_alt,
                                color: Colors.red,
                              ),
                              onPressed: _showResetDialog,
                              tooltip: getTranslatedText(
                                'Reset App',
                                'యాప్ రీసెట్',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Debug info button
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.info, color: Colors.blue),
                              onPressed: _showDebugInfo,
                              tooltip: getTranslatedText(
                                'Debug Info',
                                'డీబగ్ సమాచారం',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Title with original Telangana text
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.secondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getTranslatedText(
                              'Telangana School Education Department',
                              'తెలంగాణ పాఠశాల విద్య శాఖ',
                            ),
                            style: Theme.of(context).textTheme.displayLarge
                                ?.copyWith(color: Colors.white, height: 1.2),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              DateFormat(
                                'EEEE, dd MMMM yyyy',
                              ).format(DateTime.now()),
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Quick Actions Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      children: [
                        _buildQuickActionButton(
                          icon: Icons.camera_alt,
                          label: getTranslatedText(
                            'Camera Attendance',
                            'కెమెరా హాజరు',
                          ),
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => CameraAttendancePage(
                                        cameras: widget.cameras,
                                        isTeluguLanguage: _isTeluguLanguage,
                                      ),
                                ),
                              ),
                        ),
                        _buildQuickActionButton(
                          icon: Icons.edit,
                          label: getTranslatedText(
                            'Manual Attendance',
                            'మాన్యువల్ హాజరు',
                          ),
                          onTap: () => _showManualAttendance(),
                        ),
                        _buildQuickActionButton(
                          icon: Icons.calendar_today,
                          label: getTranslatedText('Time Table', 'టైమ్ టేబుల్'),
                          onTap: () => _showTimeTable(context),
                        ),
                        _buildQuickActionButton(
                          icon: Icons.analytics,
                          label: getTranslatedText(
                            'Attendance Report',
                            'హాజరు నివేదిక',
                          ),
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => AttendanceReportPage(
                                        isTeluguLanguage: _isTeluguLanguage,
                                      ),
                                ),
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeWidget() {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            DateFormat('hh:mm:ss a').format(DateTime.now()),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  void _showManualAttendance() {
    if (_teacherData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            getTranslatedText(
              'No student data found. Please complete setup first.',
              'విద్యార్థుల డేటా కనుగొనబడలేదు. దయచేసి ముందుగా సెటప్ పూర్తి చేయండి.',
            ),
          ),
        ),
      );
      return;
    }

    // State variables for the attendance form
    String? selectedDay;
    String? selectedTimeSlot;
    Map<String, bool> attendanceStatus = {};

    // Initialize attendance status for all students
    for (var student in _teacherData!.students) {
      attendanceStatus[student.name] = false;
    }

    // Find first available day and time slot
    if (_teacherData!.timetable.isNotEmpty) {
      // Find first day that has actual classes
      for (String day in _teacherData!.timetable.keys) {
        bool hasClasses = _teacherData!.timetable[day]!.values.any(
          (subject) => subject.isNotEmpty,
        );
        if (hasClasses) {
          selectedDay = day;
          break;
        }
      }

      // Find first time slot for selected day that has a class
      if (selectedDay != null) {
        for (String slot in _teacherData!.timetable[selectedDay]!.keys) {
          if (_teacherData!.timetable[selectedDay]![slot]?.isNotEmpty == true) {
            selectedTimeSlot = slot;
            break;
          }
        }
      }
    }

    // Show bottom sheet with manual attendance form
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setModalState) => DraggableScrollableSheet(
                  initialChildSize: 0.9,
                  maxChildSize: 0.9,
                  minChildSize: 0.5,
                  builder:
                      (context, scrollController) => Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              getTranslatedText(
                                'Manual Attendance',
                                'మాన్యువల్ హాజరు',
                              ),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),

                            // Show class info
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.class_,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_teacherData!.subject} - ${_teacherData!.className}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Day and time slot selection (only if timetable exists)
                            if (_teacherData!.timetable.isNotEmpty)
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: selectedDay,
                                      decoration: InputDecoration(
                                        labelText: getTranslatedText(
                                          'Day',
                                          'రోజు',
                                        ),
                                      ),
                                      items:
                                          _teacherData!.timetable.keys
                                              .where(
                                                (day) => _teacherData!
                                                    .timetable[day]!
                                                    .values
                                                    .any(
                                                      (subject) =>
                                                          subject.isNotEmpty,
                                                    ),
                                              )
                                              .map(
                                                (day) => DropdownMenuItem(
                                                  value: day,
                                                  child: Text(day),
                                                ),
                                              )
                                              .toList(),
                                      onChanged: (value) {
                                        if (value != null) {
                                          setModalState(() {
                                            selectedDay = value;
                                            // Find first available time slot for selected day
                                            selectedTimeSlot = null;
                                            for (String slot
                                                in _teacherData!
                                                    .timetable[value]!
                                                    .keys) {
                                              if (_teacherData!
                                                      .timetable[value]![slot]
                                                      ?.isNotEmpty ==
                                                  true) {
                                                selectedTimeSlot = slot;
                                                break;
                                              }
                                            }
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: selectedTimeSlot,
                                      decoration: InputDecoration(
                                        labelText: getTranslatedText(
                                          'Time Slot',
                                          'సమయం స్లాట్',
                                        ),
                                      ),
                                      items:
                                          selectedDay != null
                                              ? _teacherData!
                                                  .timetable[selectedDay]!
                                                  .keys
                                                  .where(
                                                    (slot) =>
                                                        _teacherData!
                                                            .timetable[selectedDay]![slot]
                                                            ?.isNotEmpty ==
                                                        true,
                                                  )
                                                  .map(
                                                    (slot) => DropdownMenuItem(
                                                      value: slot,
                                                      child: Text(slot),
                                                    ),
                                                  )
                                                  .toList()
                                              : [],
                                      onChanged: (value) {
                                        if (value != null) {
                                          setModalState(() {
                                            selectedTimeSlot = value;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            if (_teacherData!.timetable.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.info_outline,
                                      color: Colors.orange,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        getTranslatedText(
                                          'No timetable set. Attendance for general class session.',
                                          'టైమ్‌టేబుల్ సెట్ చేయబడలేదు. సాధారణ క్లాస్ సెషన్ కోసం హాజరు.',
                                        ),
                                        style: const TextStyle(
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 16),

                            Expanded(
                              child: ListView.builder(
                                controller: scrollController,
                                itemCount: _teacherData!.students.length,
                                itemBuilder: (context, index) {
                                  final student = _teacherData!.students[index];
                                  return Card(
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                        child: Text(
                                          student.rollNumber,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      title: Text(student.name),
                                      subtitle: Text(
                                        '${getTranslatedText('Roll No:', 'రోల్ నం:')} ${student.rollNumber}',
                                      ),
                                      trailing: Switch(
                                        value:
                                            attendanceStatus[student.name] ??
                                            false,
                                        onChanged: (value) {
                                          setModalState(() {
                                            attendanceStatus[student.name] =
                                                value;
                                          });
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            // Save button
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  // Save attendance data
                                  final today =
                                      DateTime.now().toString().split(' ')[0];
                                  final timeSlot =
                                      selectedTimeSlot ?? 'General';

                                  for (var student in _teacherData!.students) {
                                    final isPresent =
                                        attendanceStatus[student.name] ?? false;
                                    await StorageService.updateStudentAttendance(
                                      student.name,
                                      today,
                                      timeSlot,
                                      isPresent,
                                    );
                                  }

                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        getTranslatedText(
                                          'Attendance saved successfully!',
                                          'హాజరు విజయవంతంగా సేవ్ చేయబడింది!',
                                        ),
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );

                                  // Refresh teacher data to reflect changes
                                  _loadTeacherData();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                child: Text(
                                  getTranslatedText(
                                    'Save Attendance',
                                    'హాజరు సేవ్ చేయండి',
                                  ),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                ),
          ),
    );
  }

  void _showTimeTable(BuildContext context) {
    if (_teacherData == null || _teacherData!.timetable.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            getTranslatedText(
              'No timetable data found. Please complete setup first.',
              'టైమ్‌టేబుల్ డేటా కనుగొనబడలేదు. దయచేసి ముందుగా సెటప్ పూర్తి చేయండి.',
            ),
          ),
        ),
      );
      return;
    }

    // Filter to only include days and time slots that have actual classes
    Map<String, Map<String, String>> activeTimetable = {};
    Set<String> activeTimeSlots = <String>{};

    for (String day in _teacherData!.timetable.keys) {
      Map<String, String> daySchedule = {};
      for (String timeSlot in _teacherData!.timetable[day]!.keys) {
        String subject = _teacherData!.timetable[day]![timeSlot] ?? '';
        if (subject.isNotEmpty) {
          daySchedule[timeSlot] = subject;
          activeTimeSlots.add(timeSlot);
        }
      }
      if (daySchedule.isNotEmpty) {
        activeTimetable[day] = daySchedule;
      }
    }

    if (activeTimetable.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            getTranslatedText(
              'No classes scheduled in timetable.',
              'టైమ్‌టేబుల్‌లో ఎటువంటి క్లాసులు షెడ్యూల్ చేయబడలేదు.',
            ),
          ),
        ),
      );
      return;
    }

    List<String> sortedTimeSlots = activeTimeSlots.toList()..sort();

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    getTranslatedText('Time Table', 'టైమ్ టేబుల్'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_teacherData!.subject} - ${_teacherData!.className}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(
                          label: Text(getTranslatedText('Time', 'సమయం')),
                        ),
                        ...activeTimetable.keys.map(
                          (day) => DataColumn(label: Text(day)),
                        ),
                      ],
                      rows:
                          sortedTimeSlots.map((timeSlot) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    timeSlot,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                ...activeTimetable.keys.map(
                                  (day) => DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration:
                                          activeTimetable[day]?[timeSlot]
                                                      ?.isNotEmpty ==
                                                  true
                                              ? BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              )
                                              : null,
                                      child: Text(
                                        activeTimetable[day]?[timeSlot] ?? '',
                                        style: TextStyle(
                                          color:
                                              activeTimetable[day]?[timeSlot]
                                                          ?.isNotEmpty ==
                                                      true
                                                  ? Theme.of(
                                                    context,
                                                  ).colorScheme.primary
                                                  : Colors.grey,
                                          fontWeight:
                                              activeTimetable[day]?[timeSlot]
                                                          ?.isNotEmpty ==
                                                      true
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(getTranslatedText('Close', 'మూసివేయి')),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder:
          (context) => _ResetConfirmationDialog(
            isTeluguLanguage: _isTeluguLanguage,
            cameras: widget.cameras,
          ),
    );
  }

  void _showDebugInfo() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(getTranslatedText('Debug Info', 'డీబగ్ సమాచారం')),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_teacherData != null) ...[
                    Text('Teacher Name: ${_teacherData!.teacherName}'),
                    Text('Subject: ${_teacherData!.subject}'),
                    Text('Class: ${_teacherData!.className}'),
                    Text(
                      'Number of Students: ${_teacherData!.students.length}',
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Students:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ..._teacherData!.students.map(
                      (student) => Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 4),
                        child: Text('${student.rollNumber}: ${student.name}'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Timetable:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (_teacherData!.timetable.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(left: 16),
                        child: Text('No timetable data'),
                      )
                    else
                      ..._teacherData!.timetable.entries.map(
                        (dayEntry) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 16, top: 8),
                              child: Text(
                                '${dayEntry.key}:',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            ...dayEntry.value.entries
                                .where((slot) => slot.value.isNotEmpty)
                                .map(
                                  (slot) => Padding(
                                    padding: const EdgeInsets.only(
                                      left: 32,
                                      bottom: 2,
                                    ),
                                    child: Text('${slot.key}: ${slot.value}'),
                                  ),
                                ),
                          ],
                        ),
                      ),
                  ] else
                    const Text('No data loaded'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(getTranslatedText('Close', 'మూసివేయి')),
              ),
            ],
          ),
    );
  }

  void _showTeacherDetails() {
    if (_teacherData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            getTranslatedText(
              'No teacher data found. Please complete setup first.',
              'ఉపాధ్యాయుల డేటా కనుగొనబడలేదు. దయచేసి ముందుగా సెటప్ పూర్తి చేయండి.',
            ),
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  getTranslatedText('Teacher Details', 'ఉపాధ్యాయుల వివరాలు'),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(
                  getTranslatedText('Name', 'పేరు'),
                  _teacherData!.teacherName,
                  Icons.person_outline,
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  getTranslatedText('Subject', 'విషయం'),
                  _teacherData!.subject,
                  Icons.book,
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  getTranslatedText('Class', 'తరగతి'),
                  _teacherData!.className,
                  Icons.class_,
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  getTranslatedText('Total Students', 'మొత్తం విద్యార్థులు'),
                  '${_teacherData!.students.length}',
                  Icons.group,
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  getTranslatedText('Setup Status', 'సెటప్ స్థితి'),
                  getTranslatedText('Complete', 'పూర్తయింది'),
                  Icons.check_circle,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(getTranslatedText('Close', 'మూసివేయి')),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ResetConfirmationDialog extends StatefulWidget {
  final bool isTeluguLanguage;
  final List<CameraDescription> cameras;

  const _ResetConfirmationDialog({
    required this.isTeluguLanguage,
    required this.cameras,
  });

  @override
  State<_ResetConfirmationDialog> createState() =>
      _ResetConfirmationDialogState();
}

class _ResetConfirmationDialogState extends State<_ResetConfirmationDialog>
    with TickerProviderStateMixin {
  bool _showFinalConfirmation = false;
  bool _isHolding = false;
  double _holdProgress = 0.0;
  late AnimationController _progressController;
  late AnimationController _warningController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _warningController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _warningController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _progressController.dispose();
    _warningController.dispose();
    super.dispose();
  }

  String getTranslatedText(String english, String telugu) {
    return widget.isTeluguLanguage ? telugu : english;
  }

  void _startHold() {
    setState(() {
      _isHolding = true;
    });
    _progressController.forward().then((_) {
      if (_isHolding) {
        _performReset();
      }
    });
    _progressController.addListener(() {
      setState(() {
        _holdProgress = _progressController.value;
      });
    });
  }

  void _stopHold() {
    setState(() {
      _isHolding = false;
      _holdProgress = 0.0;
    });
    _progressController.reset();
  }

  Future<void> _performReset() async {
    // Reset app state
    await StorageService.resetApp();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => LoginPage(cameras: widget.cameras),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_showFinalConfirmation) {
      return AlertDialog(
        title: Row(
          children: [
            AnimatedBuilder(
              animation: _warningController,
              builder: (context, child) {
                return Icon(
                  Icons.warning,
                  color: Color.lerp(
                    Colors.red,
                    Colors.orange,
                    _warningController.value,
                  ),
                  size: 30,
                );
              },
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                getTranslatedText(
                  '⚠️ DANGER: Reset App',
                  '⚠️ ప్రమాదం: యాప్ రీసెట్',
                ),
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getTranslatedText(
                        'This action will PERMANENTLY DELETE:',
                        'ఈ చర్య శాశ్వతంగా తొలగిస్తుంది:',
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...([
                      '🚨 All student information and attendance records',
                      '🚨 Class schedules and timetables',
                      '🚨 Teacher profile and settings',
                      '🚨 Face recognition data',
                      '🚨 All app configuration',
                    ]).map((item) {
                      String translatedItem = item;
                      if (widget.isTeluguLanguage) {
                        switch (item) {
                          case '🚨 All student information and attendance records':
                            translatedItem =
                                '🚨 అన్ని విద్యార్థుల సమాచారం మరియు హాజరు రికార్డులు';
                            break;
                          case '🚨 Class schedules and timetables':
                            translatedItem =
                                '🚨 క్లాస్ షెడ్యూల్స్ మరియు టైమ్‌టేబుల్స్';
                            break;
                          case '🚨 Teacher profile and settings':
                            translatedItem =
                                '🚨 ఉపాధ్యాయుడి ప్రొఫైల్ మరియు సెట్టింగ్స్';
                            break;
                          case '🚨 Face recognition data':
                            translatedItem = '🚨 ముఖ గుర్తింపు డేటా';
                            break;
                          case '🚨 All app configuration':
                            translatedItem = '🚨 అన్ని యాప్ కాన్ఫిగరేషన్';
                            break;
                        }
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          translatedItem,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getTranslatedText('⚠️ WARNING:', '⚠️ హెచ్చరిక:'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      getTranslatedText(
                        '• This action CANNOT be undone\n• You will need to set up the entire app again\n• All data will be lost forever\n• Consider backing up important data first',
                        '• ఈ చర్యను రద్దు చేయలేము\n• మీరు మొత్తం యాప్‌ను మళ్లీ సెటప్ చేయాలి\n• అన్ని డేటా ఎల్లప్పటికీ పోతుంది\n• ముందుగా ముఖ్యమైన డేటాను బ్యాకప్ చేయడాన్ని పరిగణించండి',
                      ),
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              getTranslatedText('Cancel', 'రద్దుచేయి'),
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _showFinalConfirmation = true;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(
              getTranslatedText(
                'I Understand, Proceed',
                'నేను అర్థం చేసుకున్నాను, కొనసాగండి',
              ),
            ),
          ),
        ],
      );
    }

    // Final confirmation with 3-second hold
    return AlertDialog(
      title: Text(
        getTranslatedText('🚨 FINAL CONFIRMATION', '🚨 చివరి ధృవీకరణ'),
        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Text(
              getTranslatedText(
                'To confirm reset, HOLD the button below for 3 seconds.\n\nThis is your last chance to cancel!',
                'రీసెట్‌ను ధృవీకరించడానికి, దిగువ బటన్‌ను 3 సెకన్లు నొక్కి ఉంచండి.\n\nరద్దు చేయడానికి ఇది మీ చివరి అవకాశం!',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 30),
          // 3-second hold button
          GestureDetector(
            onTapDown: (_) => _startHold(),
            onTapUp: (_) => _stopHold(),
            onTapCancel: _stopHold,
            child: Container(
              width: 200,
              height: 80,
              decoration: BoxDecoration(
                color: _isHolding ? Colors.red : Colors.red.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Progress background
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          stops: [_holdProgress, _holdProgress],
                          colors: [
                            Colors.red.shade800,
                            Colors.red.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Button content
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isHolding ? Icons.delete_forever : Icons.touch_app,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isHolding
                              ? getTranslatedText(
                                'Hold for ${(3 - _holdProgress * 3).ceil()}s',
                                '${(3 - _holdProgress * 3).ceil()}సె నొక్కండి',
                              )
                              : getTranslatedText(
                                'HOLD TO RESET',
                                'రీసెట్ చేయడానికి నొక్కండి',
                              ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isHolding) ...[
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: _holdProgress,
              backgroundColor: Colors.red.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            getTranslatedText('Cancel', 'రద్దుచేయి'),
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
