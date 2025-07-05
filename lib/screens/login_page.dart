import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'tutorial_page.dart';

class LoginPage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const LoginPage({super.key, required this.cameras});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isLocked = false;
  int _remainingSeconds = 0;
  Timer? _lockTimer;
  int _failedAttempts = 0;

  void _login() {
    if (_formKey.currentState!.validate() && !_isLocked) {
      setState(() => _isLoading = true);

      // Hardcoded credentials: username = h, password = h
      if (_usernameController.text == 'h' && _passwordController.text == 'h') {
        // Reset failed attempts on successful login
        _failedAttempts = 0;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WelcomePage()),
        );
      } else {
        _failedAttempts++;

        if (_failedAttempts >= 5) {
          // Lock after 5 failed attempts
          _lockLoginForFiveMinutes();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Security Alert: Too many failed attempts! App locked for 5 minutes.',
              ),
              backgroundColor: Colors.red[800],
              duration: const Duration(seconds: 5),
            ),
          );
        } else {
          // Show warning for attempts 1-4
          int remainingAttempts = 5 - _failedAttempts;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Invalid credentials. $remainingAttempts attempt(s) remaining before lockout.',
              ),
              backgroundColor:
                  remainingAttempts <= 2 ? Colors.red : Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        setState(() => _isLoading = false);
      }
    }
  }

  void _lockLoginForFiveMinutes() {
    setState(() {
      _isLocked = true;
      _remainingSeconds = 300; // 5 minutes = 300 seconds
    });

    _lockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
      });

      if (_remainingSeconds <= 0) {
        timer.cancel();
        setState(() {
          _isLocked = false;
          _remainingSeconds = 0;
          _failedAttempts = 0; // Reset failed attempts after lockout expires
        });

        // Show message when lock expires
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login unlocked. You may try again.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'TSWREIS Teacher Login',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Security warning if locked
                  if (_isLocked)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.security,
                            color: Colors.red,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '🔒 SECURITY LOCKOUT',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'App locked due to 5 failed login attempts.\nAccess will be restored in: ${_formatTime(_remainingSeconds)}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Security hint for valid credentials
                  if (!_isLocked && _failedAttempts == 0)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Use username: h and password: h\n⚠️ Account locks after 5 failed attempts',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  TextFormField(
                    controller: _usernameController,
                    enabled: !_isLocked,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.person),
                      filled: _isLocked,
                      fillColor: _isLocked ? Colors.grey[100] : null,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    enabled: !_isLocked,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.lock),
                      filled: _isLocked,
                      fillColor: _isLocked ? Colors.grey[100] : null,
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: (_isLoading || _isLocked) ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isLocked ? Colors.grey : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                          _isLoading
                              ? const CircularProgressIndicator()
                              : Text(_isLocked ? 'Login Locked' : 'Login'),
                    ),
                  ),

                  // Failed attempts counter with enhanced warning
                  if (_failedAttempts > 0 && !_isLocked)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(top: 16),
                      decoration: BoxDecoration(
                        color:
                            _failedAttempts >= 3
                                ? Colors.red.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                        border: Border.all(
                          color:
                              _failedAttempts >= 3 ? Colors.red : Colors.orange,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _failedAttempts >= 3
                                ? Icons.warning
                                : Icons.info_outline,
                            color:
                                _failedAttempts >= 3
                                    ? Colors.red
                                    : Colors.orange[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _failedAttempts >= 4
                                  ? '🚨 FINAL WARNING: 1 attempt remaining!'
                                  : _failedAttempts >= 3
                                  ? '⚠️ WARNING: ${5 - _failedAttempts} attempts remaining'
                                  : 'Failed attempts: $_failedAttempts of 5',
                              style: TextStyle(
                                color:
                                    _failedAttempts >= 3
                                        ? Colors.red[700]
                                        : Colors.orange[700],
                                fontSize: 12,
                                fontWeight:
                                    _failedAttempts >= 3
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _lockTimer?.cancel();
    super.dispose();
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Welcome message
              Container(
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
                ),
                child: Column(
                  children: [
                    const Icon(Icons.school, size: 60, color: Colors.white),
                    const SizedBox(height: 20),
                    Text(
                      'Welcome to TSWREIS\nAttendance App',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Smart attendance tracking for modern education',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Tutorial button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TutorialPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Start Tutorial',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
