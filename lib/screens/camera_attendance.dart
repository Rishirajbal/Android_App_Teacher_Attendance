import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../models/teacher_data.dart';
import '../services/storage_service.dart';

class CameraAttendancePage extends StatefulWidget {
  final List<CameraDescription> cameras;
  final bool isTeluguLanguage;

  const CameraAttendancePage({
    super.key,
    required this.cameras,
    required this.isTeluguLanguage,
  });

  @override
  State<CameraAttendancePage> createState() => _CameraAttendancePageState();
}

class _CameraAttendancePageState extends State<CameraAttendancePage> {
  late CameraController _controller;
  bool _isInitialized = false;
  int _selectedCameraIndex = 0;
  TeacherData? _teacherData;
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadTeacherData();
    if (widget.cameras.isNotEmpty) {
      // Find the back camera first, fallback to front if not available
      _selectedCameraIndex = _findBackCameraIndex();
      _initCamera(widget.cameras[_selectedCameraIndex]);
    }
  }

  int _findBackCameraIndex() {
    for (int i = 0; i < widget.cameras.length; i++) {
      if (widget.cameras[i].lensDirection == CameraLensDirection.back) {
        return i;
      }
    }
    // If no back camera found, return first available camera
    return 0;
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

  String getTranslatedText(String english, String telugu) {
    return widget.isTeluguLanguage ? telugu : english;
  }

  Future<void> _initCamera(CameraDescription camera) async {
    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    try {
      await _controller.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Camera error: $e')));
      }
    }
  }

  void _switchCamera() async {
    if (widget.cameras.length < 2) return;

    setState(() {
      _isInitialized = false;
      _selectedCameraIndex = (_selectedCameraIndex + 1) % widget.cameras.length;
    });

    await _controller.dispose();
    await _initCamera(widget.cameras[_selectedCameraIndex]);
  }

  Future<void> _takePictureForAttendance() async {
    if (!_controller.value.isInitialized ||
        _isProcessing ||
        _teacherData == null) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Take picture - this is real camera functionality
      final image = await _controller.takePicture();

      // TODO: This is where Python face recognition will be integrated
      // 1. Send image.path to Python backend
      // 2. Get face recognition results
      // 3. Update attendance accordingly

      // For now, simulate processing
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Show dummy results - in real implementation, this would be actual recognition results
      _showAttendanceResults(image.path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error taking picture: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showAttendanceResults(String imagePath) {
    // Simulate face recognition results using real student data
    final recognizedStudents =
        _teacherData!.students
            .take(2)
            .toList(); // Simulate 2 students recognized

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
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
                          'Face Recognition Results (Simulated)',
                          'ముఖ గుర్తింపు ఫలితాలు (అనుకరణ)',
                        ),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        getTranslatedText(
                          'Image saved to: $imagePath',
                          'చిత్రం ఇక్కడ సేవ్ చేయబడింది: $imagePath',
                        ),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        getTranslatedText(
                          'Recognized Students:',
                          'గుర్తించిన విద్యార్థులు:',
                        ),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),

                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: recognizedStudents.length,
                          itemBuilder: (context, index) {
                            final student = recognizedStudents[index];
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.green,
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
                                trailing: const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _markAttendance(recognizedStudents);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                getTranslatedText(
                                  'Mark Present',
                                  'హాజరుగా మార్క్ చేయండి',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                getTranslatedText('Cancel', 'రద్దుచేయి'),
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

  void _markAttendance(List<StudentInfo> students) {
    // TODO: Implement actual attendance marking using StorageService.updateStudentAttendance
    for (final student in students) {
      // This would update the actual attendance data
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            getTranslatedText(
              'Marked ${student.name} as present (simulated)',
              '${student.name}ను హాజరుగా మార్క్ చేయబడింది (అనుకరణ)',
            ),
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(getTranslatedText('Camera Attendance', 'కెమెరా హాజరు')),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_teacherData == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(getTranslatedText('Camera Attendance', 'కెమెరా హాజరు')),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                getTranslatedText(
                  'No student data found. Please complete setup first.',
                  'విద్యార్థుల డేటా కనుగొనబడలేదు. దయచేసి ముందుగా సెటప్ పూర్తి చేయండి.',
                ),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    if (widget.cameras.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(getTranslatedText('Camera Attendance', 'కెమెరా హాజరు')),
        ),
        body: Center(
          child: Text(
            getTranslatedText(
              'No cameras available',
              'కెమెరాలు అందుబాటులో లేవు',
            ),
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: Text(getTranslatedText('Camera Attendance', 'కెమెరా హాజరు')),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                getTranslatedText(
                  'Initializing Camera...',
                  'కెమెరా ప్రారంభమవుతోంది...',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(getTranslatedText('Camera Attendance', 'కెమెరా హాజరు')),
            Text(
              '${_teacherData!.subject} - ${_teacherData!.className}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          if (widget.cameras.length > 1)
            IconButton(
              icon: const Icon(Icons.switch_camera),
              onPressed: _switchCamera,
              tooltip: getTranslatedText('Switch Camera', 'కెమెరా మార్చండి'),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Camera preview with proper aspect ratio handling
          Center(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: CameraPreview(_controller),
            ),
          ),

          // Student info overlay
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    getTranslatedText(
                      'Students in class: ${_teacherData!.students.length}',
                      'తరగతిలో విద్యార్థులు: ${_teacherData!.students.length}',
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    getTranslatedText(
                      'Position students in frame and tap capture',
                      'విద్యార్థులను ఫ్రేమ్‌లో ఉంచి క్యాప్చర్ టాప్ చేయండి',
                    ),
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    getTranslatedText(
                      '(Face recognition simulation - Python integration pending)',
                      '(ముఖ గుర్తింపు అనుకరణ - పైథన్ అనుసంధానం పెండింగ్)',
                    ),
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Capture button
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: FloatingActionButton.extended(
                onPressed: _isProcessing ? null : _takePictureForAttendance,
                icon:
                    _isProcessing
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Icon(Icons.camera_alt),
                label: Text(
                  _isProcessing
                      ? getTranslatedText(
                        'Processing...',
                        'ప్రాసెస్ చేస్తున్నా...',
                      )
                      : getTranslatedText('Take Attendance', 'హాజరు తీసుకోండి'),
                ),
                backgroundColor: _isProcessing ? Colors.grey : Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
