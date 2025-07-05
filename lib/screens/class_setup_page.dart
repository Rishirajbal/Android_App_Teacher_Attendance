import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'face_capture_page.dart';
import 'teacher_dashboard.dart';
import '../models/teacher_data.dart';
import '../services/storage_service.dart';

class ClassSetupPage extends StatefulWidget {
  final bool isTeluguLanguage;

  const ClassSetupPage({super.key, this.isTeluguLanguage = false});

  @override
  State<ClassSetupPage> createState() => _ClassSetupPageState();
}

class _ClassSetupPageState extends State<ClassSetupPage> {
  bool _isTeluguLanguage = false;
  final _formKey = GlobalKey<FormState>();
  final _teacherNameController = TextEditingController();
  int _numberOfStudents = 5;
  int _currentStep = 0;
  List<String> _studentNames = [];
  List<String> _studentRollNumbers = [];
  List<CameraDescription> _cameras = [];

  // New fields for enhanced setup
  String _selectedSubject = 'Mathematics';
  String _selectedClass = 'Class 1';
  Map<String, String> _timetable = {};

  final List<String> _subjects = [
    'Mathematics',
    'Science',
    'English',
    'Telugu',
    'Hindi',
    'Social Studies',
    'Physics',
    'Chemistry',
    'Biology',
    'Computer Science',
  ];

  final List<String> _classes = [
    'Class 1',
    'Class 2',
    'Class 3',
    'Class 4',
    'Class 5',
    'Class 6',
    'Class 7',
    'Class 8',
    'Class 9',
    'Class 10',
  ];

  // Time options for dropdowns
  final List<String> _timeOptions = [
    '08:00',
    '08:15',
    '08:30',
    '08:45',
    '09:00',
    '09:15',
    '09:30',
    '09:45',
    '10:00',
    '10:15',
    '10:30',
    '10:45',
    '11:00',
    '11:15',
    '11:30',
    '11:45',
    '12:00',
    '12:15',
    '12:30',
    '12:45',
    '13:00',
    '13:15',
    '13:30',
    '13:45',
    '14:00',
    '14:15',
    '14:30',
    '14:45',
    '15:00',
    '15:15',
    '15:30',
    '15:45',
    '16:00',
    '16:15',
    '16:30',
    '16:45',
    '17:00',
    '17:15',
    '17:30',
    '17:45',
  ];

  final List<String> _timeSlots = [
    '8:00-9:00',
    '9:00-10:00',
    '10:00-11:00',
    '11:00-12:00',
    '12:00-1:00',
    '1:00-2:00',
    '2:00-3:00',
    '3:00-4:00',
  ];

  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];

  @override
  void initState() {
    super.initState();
    _isTeluguLanguage = widget.isTeluguLanguage;
    _initCamera();
    _initializeTimetable();
  }

  void _initializeTimetable() {
    for (String day in _days) {
      for (String slot in _timeSlots) {
        _timetable['${day}_$slot'] = '';
      }
    }
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera initialization failed: $e')),
        );
      }
    }
  }

  String getTranslatedText(String english, String telugu) {
    return _isTeluguLanguage ? telugu : english;
  }

  void _nextStep() {
    if (_currentStep == 0) {
      // Validate teacher info
      if (!_formKey.currentState!.validate()) {
        return;
      }
      if (_selectedSubject.isEmpty || _selectedClass.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              getTranslatedText(
                'Please fill all required fields',
                'దయచేసి అవసరమైన అన్ని ఫీల్డ్‌లను పూర్తి చేయండి',
              ),
            ),
          ),
        );
        return;
      }
      setState(() {
        _currentStep = 1;
      });
    } else if (_currentStep == 1) {
      // Initialize student lists based on number of students
      _studentNames = List.generate(_numberOfStudents, (index) => '');
      _studentRollNumbers = List.generate(_numberOfStudents, (index) => '');
      setState(() {
        _currentStep = 2;
      });
    } else if (_currentStep == 2) {
      _proceedToFaceCapture();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _proceedToFaceCapture() {
    if (_cameras.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => FaceCapturePage(
                cameras: _cameras,
                studentNames: _studentNames,
                studentRollNumbers: _studentRollNumbers,
                isTeluguLanguage: _isTeluguLanguage,
                onComplete: _onSetupComplete,
              ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            getTranslatedText(
              'No cameras available. Proceeding without face data.',
              'కెమెరాలు అందుబాటులో లేవు. ముఖ డేటా లేకుండా కొనసాగుతోంది.',
            ),
          ),
        ),
      );
      _onSetupComplete();
    }
  }

  void _onSetupComplete() async {
    // Create teacher data
    final students =
        _studentNames.asMap().entries.map((entry) {
          return StudentInfo(
            name:
                entry.value.isEmpty ? 'Student ${entry.key + 1}' : entry.value,
            rollNumber:
                _studentRollNumbers[entry.key].isNotEmpty
                    ? _studentRollNumbers[entry.key]
                    : '${entry.key + 1}'.padLeft(3, '0'),
          );
        }).toList();

    final teacherData = TeacherData(
      teacherName: _teacherNameController.text,
      subject: _selectedSubject,
      className: _selectedClass,
      students: students,
      timetable: _convertTimetableToMap(),
      isSetupComplete: true,
    );

    // Save data
    await StorageService.saveTeacherData(teacherData);
    await StorageService.setSetupComplete(true);
    await StorageService.setFirstLaunchComplete();

    // Navigate to main dashboard
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder:
              (context) => TeacherDashboard(
                cameras: _cameras,
                isTeluguLanguage: _isTeluguLanguage,
              ),
        ),
        (route) => false,
      );
    }
  }

  Map<String, Map<String, String>> _convertTimetableToMap() {
    Map<String, Map<String, String>> result = {};
    for (String day in _days) {
      result[day] = {};
      for (String slot in _timeSlots) {
        result[day]![slot] = _timetable['${day}_$slot'] ?? '';
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(getTranslatedText('Class Setup', 'క్లాస్ సెటప్')),
        actions: [
          // Language toggle
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton.icon(
              icon: const Icon(Icons.language, color: Colors.white),
              label: Text(
                _isTeluguLanguage ? 'English' : 'తెలుగు',
                style: const TextStyle(color: Colors.white),
              ),
              onPressed: () {
                setState(() {
                  _isTeluguLanguage = !_isTeluguLanguage;
                });
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: (_currentStep + 1) / 4,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),

              // Step indicator
              Text(
                '${getTranslatedText('Step', 'దశ')} ${_currentStep + 1} ${getTranslatedText('of', 'లో')} 4',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 30),

              // Content based on current step
              Expanded(child: _getCurrentStepWidget()),

              // Navigation buttons
              Row(
                children: [
                  // Back button (only show if not on first step)
                  if (_currentStep > 0)
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _previousStep,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[600],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.arrow_back),
                          label: Text(
                            getTranslatedText('Back', 'వెనుకకు'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Add spacing between buttons if both are visible
                  if (_currentStep > 0) const SizedBox(width: 16),

                  // Next button
                  Expanded(
                    flex:
                        _currentStep == 0
                            ? 1
                            : 1, // Takes full width on first step
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _nextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon:
                            _currentStep == 2
                                ? const Icon(Icons.face)
                                : const Icon(Icons.arrow_forward),
                        label: Text(
                          _getNextButtonText(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getCurrentStepWidget() {
    switch (_currentStep) {
      case 0:
        return _buildTeacherInfoStep();
      case 1:
        return _buildStudentNamesStep();
      case 2:
        return _buildTimetableStep();
      default:
        return _buildTeacherInfoStep();
    }
  }

  String _getNextButtonText() {
    switch (_currentStep) {
      case 0:
        return getTranslatedText('Next: Students', 'తదుపరి: విద్యార్థులు');
      case 1:
        return getTranslatedText('Next: Timetable', 'తదుపరి: టైమ్‌టేబుల్');
      case 2:
        return getTranslatedText(
          'Setup Face Recognition',
          'ముఖ గుర్తింపు సెటప్',
        );
      default:
        return getTranslatedText('Next', 'తదుపరి');
    }
  }

  Widget _buildTeacherInfoStep() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            getTranslatedText('Teacher Information', 'ఉపాధ్యాయుల సమాచారం'),
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),

          // Teacher name input
          TextFormField(
            controller: _teacherNameController,
            decoration: InputDecoration(
              labelText: getTranslatedText('Teacher Name', 'ఉపాధ్యాయుడి పేరు'),
              hintText: getTranslatedText(
                'Enter your name',
                'మీ పేరు నమోదు చేయండి',
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return getTranslatedText(
                  'Please enter teacher name',
                  'దయచేసి ఉపాధ్యాయుడి పేరు నమోదు చేయండి',
                );
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Subject selection
          Text(
            getTranslatedText('Subject', 'విషయం'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedSubject,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.book),
            ),
            items:
                _subjects.map((subject) {
                  return DropdownMenuItem(value: subject, child: Text(subject));
                }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedSubject = value;
                });
              }
            },
          ),
          const SizedBox(height: 20),

          // Class selection
          Text(
            getTranslatedText('Class', 'తరగతి'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedClass,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.class_),
            ),
            items:
                _classes.map((className) {
                  return DropdownMenuItem(
                    value: className,
                    child: Text(className),
                  );
                }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedClass = value;
                });
              }
            },
          ),

          // Number of students
          Text(
            getTranslatedText('Number of Students', 'విద్యార్థుల సంఖ్య'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<int>(
            value: _numberOfStudents,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.group),
            ),
            items: List.generate(10, (index) {
              int value = index + 1;
              return DropdownMenuItem(
                value: value,
                child: Text(
                  '$value ${getTranslatedText('students', 'విద్యార్థులు')}',
                ),
              );
            }),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _numberOfStudents = value;
                });
              }
            },
          ),

          // Updated instructions without voice input
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    getTranslatedText(
                      'Tip: Fill in all the required information carefully. You can always edit this later from settings.',
                      'చిట్కా: అవసరమైన అన్ని సమాచారాన్ని జాగ్రత్తగా నింపండి. మీరు దీన్ని ఎల్లప్పుడూ సెట్టింగ్‌ల నుండి సవరించవచ్చు.',
                    ),
                    style: const TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentNamesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getTranslatedText('Student Information', 'విద్యార్థుల సమాచారం'),
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Text(
          getTranslatedText(
            'Enter the names and roll numbers of your students:',
            'మీ విద్యార్థుల పేర్లు మరియు రోల్ నంబర్లను నమోదు చేయండి:',
          ),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 20),

        Expanded(
          child: Scrollbar(
            thumbVisibility: true,
            child: ListView.builder(
              itemCount: _numberOfStudents,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${getTranslatedText('Student', 'విద్యార్థి')} ${index + 1}',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  initialValue: _studentNames[index],
                                  decoration: InputDecoration(
                                    labelText: getTranslatedText(
                                      'Name',
                                      'పేరు',
                                    ),
                                    hintText: getTranslatedText(
                                      'Enter student name',
                                      'విద్యార్థి పేరు నమోదు చేయండి',
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.person_outline,
                                    ),
                                  ),
                                  onChanged: (value) {
                                    _studentNames[index] = value;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  initialValue: _studentRollNumbers[index],
                                  decoration: InputDecoration(
                                    labelText: getTranslatedText(
                                      'Roll No.',
                                      'రోల్ నం.',
                                    ),
                                    hintText: getTranslatedText(
                                      'e.g., 001',
                                      'ఉదా., 001',
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    prefixIcon: const Icon(Icons.numbers),
                                  ),
                                  onChanged: (value) {
                                    _studentRollNumbers[index] = value;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimetableStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getTranslatedText('Class Timetable Setup', 'తరగతి టైమ్‌టేబుల్ సెటప్'),
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        // Subject info display
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.book, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getTranslatedText(
                        'Setting schedule for: $_selectedSubject',
                        'దీని కోసం షెడ్యూల్ సెట్ చేస్తున్నాము: $_selectedSubject',
                      ),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      getTranslatedText(
                        'Add your class days and times below',
                        'దిగువ మీ క్లాస్ రోజులు మరియు సమయాలను జోడించండి',
                      ),
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Text(
          getTranslatedText(
            'When do you have $_selectedSubject classes?',
            'మీకు $_selectedSubject తరగతులు ఎప్పుడు ఉన్నాయి?',
          ),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),

        // Add new class schedule button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showAddClassTimeDialog(),
            icon: const Icon(Icons.add),
            label: Text(
              getTranslatedText('Add Class Time', 'క్లాస్ సమయం జోడించండి'),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Show added class times with scrolling
        Expanded(child: _buildScheduleList()),
      ],
    );
  }

  Widget _buildScheduleList() {
    final subjectSchedules = _getSubjectSchedules();

    if (subjectSchedules.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.schedule, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                getTranslatedText(
                  'No class times added yet',
                  'ఇంకా క్లాస్ సమయాలు జోడించబడలేదు',
                ),
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                getTranslatedText(
                  'Tap "Add Class Time" to get started',
                  'ప్రారంభించడానికి "క్లాస్ సమయం జోడించండి" నొక్కండి',
                ),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scrollbar(
      thumbVisibility: true,
      child: ListView.builder(
        itemCount: subjectSchedules.length,
        itemBuilder: (context, index) {
          final schedule = subjectSchedules[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: 2,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  (schedule['day'] ?? '').isNotEmpty
                      ? (schedule['day'] ?? '')[0]
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                schedule['day'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${schedule['startTime'] ?? ''} - ${schedule['endTime'] ?? ''}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _selectedSubject,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed:
                    () => _removeSchedule(
                      schedule['day'] ?? '',
                      schedule['timeSlot'] ?? '',
                    ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Map<String, String>> _getSubjectSchedules() {
    List<Map<String, String>> schedules = [];

    for (String day in _days) {
      for (String slot in _timeSlots) {
        final key = '${day}_$slot';
        final timetableValue = _timetable[key];
        if (timetableValue != null && timetableValue == _selectedSubject) {
          final times = slot.split('-');
          schedules.add({
            'day': day,
            'timeSlot': slot,
            'startTime': times.isNotEmpty ? times[0] : '',
            'endTime':
                times.length > 1
                    ? times[1]
                    : (times.isNotEmpty ? times[0] : ''),
          });
        }
      }
    }

    return schedules;
  }

  void _removeSchedule(String day, String timeSlot) {
    setState(() {
      _timetable['${day}_$timeSlot'] = '';
    });
  }

  void _showAddClassTimeDialog() {
    String selectedDay = _days[0];
    String startTime = '09:00';
    String endTime = '10:00';

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: Text(
                    getTranslatedText(
                      'Add Class Time',
                      'క్లాస్ సమయం జోడించండి',
                    ),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Day selection
                        DropdownButtonFormField<String>(
                          value: selectedDay,
                          decoration: InputDecoration(
                            labelText: getTranslatedText(
                              'Select Day',
                              'రోజు ఎంచుకోండి',
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items:
                              _days
                                  .map(
                                    (day) => DropdownMenuItem(
                                      value: day,
                                      child: Text(day),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() {
                                selectedDay = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // Start time dropdown
                        DropdownButtonFormField<String>(
                          value: startTime,
                          decoration: InputDecoration(
                            labelText: getTranslatedText(
                              'Start Time',
                              'ప్రారంభ సమయం',
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.access_time),
                          ),
                          items:
                              _timeOptions
                                  .map(
                                    (time) => DropdownMenuItem(
                                      value: time,
                                      child: Text(time),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() {
                                startTime = value;
                                // Auto-update end time to be at least 1 hour later
                                int startIndex = _timeOptions.indexOf(value);
                                if (startIndex != -1 &&
                                    startIndex + 4 < _timeOptions.length) {
                                  endTime =
                                      _timeOptions[startIndex +
                                          4]; // 1 hour later (4 slots of 15 min)
                                }
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // End time dropdown
                        DropdownButtonFormField<String>(
                          value: endTime,
                          decoration: InputDecoration(
                            labelText: getTranslatedText(
                              'End Time',
                              'ముగింపు సమయం',
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.access_time),
                          ),
                          items:
                              _timeOptions
                                  .where(
                                    (time) =>
                                        _timeOptions.indexOf(time) >
                                        _timeOptions.indexOf(startTime),
                                  )
                                  .map(
                                    (time) => DropdownMenuItem(
                                      value: time,
                                      child: Text(time),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() {
                                endTime = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(getTranslatedText('Cancel', 'రద్దుచేయి')),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _addClassTime(selectedDay, startTime, endTime);
                        Navigator.pop(context);
                      },
                      child: Text(getTranslatedText('Add', 'జోడించు')),
                    ),
                  ],
                ),
          ),
    );
  }

  void _addClassTime(String day, String startTime, String endTime) {
    final timeSlot = '$startTime-$endTime';
    final key = '${day}_$timeSlot';

    setState(() {
      _timetable[key] = _selectedSubject;
      // Also add to predefined time slots if not exists
      if (!_timeSlots.contains(timeSlot)) {
        _timeSlots.add(timeSlot);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          getTranslatedText(
            'Added $_selectedSubject class on $day from $startTime to $endTime',
            '$day రోజు $startTime నుండి $endTime వరకు $_selectedSubject క్లాస్ జోడించబడింది',
          ),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _teacherNameController.dispose();
    super.dispose();
  }
}
