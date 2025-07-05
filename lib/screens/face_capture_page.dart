import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class FaceCapturePage extends StatefulWidget {
  final List<CameraDescription> cameras;
  final List<String> studentNames;
  final List<String> studentRollNumbers;
  final bool isTeluguLanguage;
  final VoidCallback onComplete;

  const FaceCapturePage({
    super.key,
    required this.cameras,
    required this.studentNames,
    required this.studentRollNumbers,
    required this.isTeluguLanguage,
    required this.onComplete,
  });

  @override
  State<FaceCapturePage> createState() => _FaceCapturePageState();
}

class _FaceCapturePageState extends State<FaceCapturePage> {
  late CameraController _controller;
  bool _isInitialized = false;
  int _currentStudentIndex = 0;
  bool _isCapturing = false;
  final List<String> _capturedStudents = [];
  int _selectedCameraIndex = 0;
  bool _showNotification = false;
  String _notificationMessage = '';

  @override
  void initState() {
    super.initState();
    if (widget.cameras.isNotEmpty) {
      _initCamera(widget.cameras[0]);
    }
  }

  String getTranslatedText(String english, String telugu) {
    return widget.isTeluguLanguage ? telugu : english;
  }

  Future<void> _initCamera(CameraDescription camera) async {
    _controller = CameraController(camera, ResolutionPreset.max);
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

  void _showCenterNotification(String message) {
    setState(() {
      _notificationMessage = message;
      _showNotification = true;
    });

    // Auto-hide after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _showNotification) {
        setState(() {
          _showNotification = false;
        });
      }
    });
  }

  void _hideNotification() {
    setState(() {
      _showNotification = false;
    });
  }

  Future<void> _captureStudentFace() async {
    if (!_controller.value.isInitialized || _isCapturing) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      // Simulate face capture process
      // TODO: In future, integrate Python face recognition model here
      // 1. Take the picture using _controller.takePicture()
      // 2. Send image to Python backend for face embedding extraction
      // 3. Store face embedding in database
      // 4. Associate with student record

      await Future.delayed(const Duration(seconds: 2));

      final currentStudentName = widget.studentNames[_currentStudentIndex];
      _capturedStudents.add(currentStudentName);

      if (mounted) {
        _showCenterNotification(
          getTranslatedText(
            'Face data placeholder created for $currentStudentName (Python model will be integrated later)',
            '$currentStudentName కోసం ముఖ డేటా ప్లేస్‌హోల్డర్ సృష్టించబడింది (పైథన్ మోడల్ తరువాత అనుసంధానించబడుతుంది)',
          ),
        );
      }

      // Move to next student or complete
      if (_currentStudentIndex < widget.studentNames.length - 1) {
        setState(() {
          _currentStudentIndex++;
          _isCapturing = false;
        });
      } else {
        _completeSetup();
      }
    } catch (e) {
      if (mounted) {
        _showCenterNotification('Capture failed: $e');
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  void _skipCurrentStudent() {
    if (_currentStudentIndex < widget.studentNames.length - 1) {
      setState(() {
        _currentStudentIndex++;
      });
    } else {
      _completeSetup();
    }
  }

  void _completeSetup() {
    Navigator.pop(context);
    widget.onComplete();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cameras.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text(
            widget.isTeluguLanguage
                ? 'కెమెరాలు అందుబాటులో లేవు'
                : 'No cameras available',
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Scaffold(
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

    final currentStudentName = widget.studentNames[_currentStudentIndex];
    final progress = (_currentStudentIndex + 1) / widget.studentNames.length;
    final isFrontCamera =
        widget.cameras[_selectedCameraIndex].lensDirection ==
        CameraLensDirection.front;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(getTranslatedText('Face Setup', 'ముఖ సెటప్')),
        actions: [
          if (widget.cameras.length > 1)
            IconButton(
              icon: const Icon(Icons.switch_camera),
              onPressed: _switchCamera,
              tooltip: getTranslatedText('Switch Camera', 'కెమెరా మార్చండి'),
            ),
          TextButton(
            onPressed: _skipCurrentStudent,
            child: Text(
              getTranslatedText('Skip', 'దాటవేయండి'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Progress indicator
              Container(
                padding: const EdgeInsets.all(20),
                color: Colors.black,
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[700],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${getTranslatedText('Student', 'విద్యార్థి')} ${_currentStudentIndex + 1} ${getTranslatedText('of', 'లో')} ${widget.studentNames.length}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      currentStudentName.isEmpty
                          ? '${getTranslatedText('Student', 'విద్యార్థి')} ${_currentStudentIndex + 1}'
                          : currentStudentName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      getTranslatedText(
                        isFrontCamera ? 'Front Camera' : 'Back Camera',
                        isFrontCamera ? 'ముందు కెమెరా' : 'వెనుక కెమెరా',
                      ),
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Camera preview
              Expanded(
                child: Stack(
                  children: [
                    // Camera view with proper aspect ratio
                    Center(
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity(),
                        child: CameraPreview(_controller),
                      ),
                    ),

                    // Face detection overlay (dummy)
                    Center(
                      child: Container(
                        width: 200,
                        height: 250,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _isCapturing ? Colors.green : Colors.white,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child:
                            _isCapturing
                                ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.green,
                                  ),
                                )
                                : null,
                      ),
                    ),

                    // Instructions
                    Positioned(
                      top: 20,
                      left: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              getTranslatedText(
                                'Position face within the frame and tap capture',
                                'ముఖాన్ని ఫ్రేమ్‌లో ఉంచి క్యాప్చర్ టాప్ చేయండి',
                              ),
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              getTranslatedText(
                                '(Python face recognition model will be integrated later)',
                                '(పైథన్ ముఖ గుర్తింపు మోడల్ తరువాత అనుసంధానించబడుతుంది)',
                              ),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.orange,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Capture button
              Container(
                padding: const EdgeInsets.all(20),
                color: Colors.black,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Skip button
                    ElevatedButton(
                      onPressed: _isCapturing ? null : _skipCurrentStudent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                      child: Text(getTranslatedText('Skip', 'దాటవేయండి')),
                    ),

                    // Capture button
                    ElevatedButton(
                      onPressed: _isCapturing ? null : _captureStudentFace,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                      ),
                      child:
                          _isCapturing
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : Text(
                                getTranslatedText(
                                  'Capture Face',
                                  'ముఖాన్ని క్యాప్చర్ చేయండి',
                                ),
                              ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Center notification overlay
          if (_showNotification)
            Positioned.fill(
              child: GestureDetector(
                onTap: _hideNotification,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 40,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _notificationMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            getTranslatedText(
                              'Tap to dismiss',
                              'దాచడానికి నొక్కండి',
                            ),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
