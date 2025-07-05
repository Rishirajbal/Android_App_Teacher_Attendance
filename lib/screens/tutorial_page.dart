import 'package:flutter/material.dart';
import 'class_setup_page.dart';

class TutorialPage extends StatefulWidget {
  final bool isTeluguLanguage;

  const TutorialPage({super.key, this.isTeluguLanguage = false});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  int _currentPage = 0;
  bool _isTeluguLanguage = false;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _isTeluguLanguage = widget.isTeluguLanguage;
  }

  String getTranslatedText(String english, String telugu) {
    return _isTeluguLanguage ? telugu : english;
  }

  final List<TutorialStep> _tutorialSteps = [
    // Welcome Step
    TutorialStep(
      icon: Icons.school,
      titleEn: 'Welcome to TSWREIS Attendance App',
      titleTe: 'TSWREIS హాజరు యాప్‌కు స్వాగతం',
      descriptionEn:
          'This app helps teachers efficiently manage student attendance using advanced face recognition technology and manual methods.',
      descriptionTe:
          'ఈ యాప్ అధునాతన ముఖ గుర్తింపు సాంకేతికత మరియు మాన్యువల్ పద్ధతులను ఉపయోగించి ఉపాధ్యాయులను విద్యార్థుల హాజరును సమర్థవంతంగా నిర్వహించడానికి సహాయపడుతుంది.',
      features: [
        'Advanced face recognition for automatic attendance',
        'Manual attendance marking option',
        'Detailed attendance reports and analytics',
        'Class schedule management',
        'Multi-language support (English/Telugu)',
      ],
      featuresTeluguEn: [
        'స్వయంచాలక హాజరు కోసం అధునాతన ముఖ గుర్తింపు',
        'మాన్యువల్ హాజరు గుర్తింపు ఎంపిక',
        'వివరణాత్మక హాజరు నివేదికలు మరియు విశ్లేషణలు',
        'క్లాస్ షెడ్యూల్ నిర్వహణ',
        'బహుభాషా మద్దతు (ఇంగ్లీష్/తెలుగు)',
      ],
      isInteractive: false,
    ),

    // Camera Attendance Step
    TutorialStep(
      icon: Icons.camera_alt,
      titleEn: 'Camera Attendance - AI Recognition',
      titleTe: 'కెమెరా హాజరు - AI గుర్తింపు',
      descriptionEn:
          'Use advanced face recognition to automatically mark attendance. Point camera at students and the AI will recognize and mark them present.',
      descriptionTe:
          'స్వయంచాలకంగా హాజరును గుర్తించడానికి అధునాతన ముఖ గుర్తింపును ఉపయోగించండి. విద్యార్థుల వైపు కెమెరాను చూపండి మరియు AI వారిని గుర్తించి హాజరుగా గుర్తిస్తుంది.',
      features: [
        '✅ Quick and accurate attendance marking',
        '⚠️ WARNING: Ensure good lighting for best results',
        '⚠️ CAUTION: Do not use in poor lighting conditions',
        '✅ Automatic face detection and recognition',
        '⚠️ IMPORTANT: Students must look directly at camera',
      ],
      featuresTeluguEn: [
        '✅ త్వరిత మరియు ఖచ్చితమైన హాజరు గుర్తింపు',
        '⚠️ హెచ్చరిక: మంచి ఫలితాల కోసం మంచి లైటింగ్ ఉండేలా చూసుకోండి',
        '⚠️ జాగ్రత్త: దృష్టిహీన లైటింగ్ పరిస్థితులలో ఉపయోగించవద్దు',
        '✅ స్వయంచాలక ముఖ గుర్తింపు మరియు గుర్తింపు',
        '⚠️ ముఖ్యమైనది: విద్యార్థులు కెమెరా వైపు నేరుగా చూడాలి',
      ],
      isInteractive: true,
      dangerWarnings: [
        'Never force students to look at camera',
        'Do not use in direct sunlight',
        'Ensure privacy and consent before taking photos',
      ],
      dangerWarningsTeluguEn: [
        'విద్యార్థులను కెమెరా వైపు చూడమని బలవంతం చేయవద్దు',
        'నేరుగా సూర్యకాంతిలో ఉపయోగించవద్దు',
        'ఫోటోలు తీయడానికి ముందు గోప్యత మరియు అనుమతిని నిర్ధారించండి',
      ],
    ),

    // Manual Attendance Step
    TutorialStep(
      icon: Icons.edit,
      titleEn: 'Manual Attendance - Reliable Backup',
      titleTe: 'మాన్యువల్ హాజరు - నమ్మకమైన బ్యాకప్',
      descriptionEn:
          'When camera is not available or face recognition fails, use manual attendance to mark students present or absent.',
      descriptionTe:
          'కెమెరా అందుబాటులో లేనప్పుడు లేదా ముఖ గుర్తింపు విఫలమైనప్పుడు, విద్యార్థులను హాజరుగా లేదా గైర్హాజరుగా గుర్తించడానికి మాన్యువల్ హాజరును ఉపయోగించండి.',
      features: [
        '✅ Reliable when technology fails',
        '✅ Quick toggle switches for each student',
        '⚠️ WARNING: Double-check before submitting',
        '⚠️ CAUTION: Cannot be undone easily',
        '✅ Works offline without internet',
      ],
      featuresTeluguEn: [
        '✅ సాంకేతికత విఫలమైనప్పుడు నమ్మకమైనది',
        '✅ ప్రతి విద్యార్థి కోసం త్వరిత టోగుల్ స్విచ్‌లు',
        '⚠️ హెచ్చరిక: సమర్పించడానికి ముందు రెండుసార్లు తనిఖీ చేయండి',
        '⚠️ జాగ్రత్త: సులభంగా రద్దు చేయలేము',
        '✅ ఇంటర్నెట్ లేకుండా ఆఫ్‌లైన్‌లో పని చేస్తుంది',
      ],
      isInteractive: true,
      dangerWarnings: [
        'Always verify student names before marking',
        'Do not mark attendance for absent students',
        'Save immediately after marking to avoid data loss',
      ],
      dangerWarningsTeluguEn: [
        'గుర్తించడానికి ముందు ఎల్లప్పుడూ విద్యార్థి పేర్లను ధృవీకరించండి',
        'గైర్హాజరైన విద్యార్థుల కోసం హాజరును గుర్తించవద్దు',
        'డేటా నష్టాన్ని నివారించడానికి గుర్తించిన తర్వాత వెంటనే సేవ్ చేయండి',
      ],
    ),

    // Reports Step
    TutorialStep(
      icon: Icons.analytics,
      titleEn: 'Attendance Reports & Analytics',
      titleTe: 'హాజరు నివేదికలు & విశ్లేషణలు',
      descriptionEn:
          'Generate detailed reports to track student attendance patterns, identify frequently absent students, and share reports with administration.',
      descriptionTe:
          'విద్యార్థుల హాజరు నమూనాలను ట్రాక్ చేయడానికి, తరచుగా గైర్హాజరయ్యే విద్యార్థులను గుర్తించడానికి మరియు పరిపాలనతో నివేదికలను పంచుకోవడానికి వివరణాత్మక నివేదికలను రూపొందించండి.',
      features: [
        '✅ Daily, weekly, monthly attendance reports',
        '✅ Student-wise attendance percentage',
        '✅ Class-wise attendance statistics',
        '⚠️ WARNING: Reports contain sensitive student data',
        '⚠️ CAUTION: Share reports only with authorized personnel',
      ],
      featuresTeluguEn: [
        '✅ రోజువారీ, వారానికి, నెలవారీ హాజరు నివేదికలు',
        '✅ విద్యార్థి వారీగా హాజరు శాతం',
        '✅ క్లాస్ వారీగా హాజరు గణాంకాలు',
        '⚠️ హెచ్చరిక: నివేదికలలో సున్నితమైన విద్యార్థి డేటా ఉంటుంది',
        '⚠️ జాగ్రత్త: అధికారిక వ్యక్తులతో మాత్రమే నివేదికలను పంచుకోండి',
      ],
      isInteractive: true,
      dangerWarnings: [
        'Never share reports with unauthorized persons',
        'Protect student privacy at all times',
        'Regular backup reports to prevent data loss',
      ],
      dangerWarningsTeluguEn: [
        'అనధికారిక వ్యక్తులతో ఎప్పుడూ నివేదికలను పంచుకోవద్దు',
        'ఎల్లప్పుడూ విద్యార్థుల గోప్యతను రక్షించండి',
        'డేటా నష్టాన్ని నివారించడానికి క్రమమైన బ్యాకప్ నివేదికలు',
      ],
    ),

    // Time Table Step
    TutorialStep(
      icon: Icons.calendar_today,
      titleEn: 'Class Schedule Management',
      titleTe: 'క్లాస్ షెడ్యూల్ నిర్వహణ',
      descriptionEn:
          'Manage your class timetable, set subject schedules, and organize daily teaching activities efficiently.',
      descriptionTe:
          'మీ క్లాస్ టైమ్‌టేబుల్‌ను నిర్వహించండి, విషయ షెడ్యూల్‌లను సెట్ చేయండి మరియు రోజువారీ బోధనా కార్యకలాపాలను సమర్థవంతంగా నిర్వహించండి.',
      features: [
        '✅ Easy drag-and-drop schedule creation',
        '✅ Subject-wise time slot allocation',
        '✅ Daily and weekly view options',
        '⚠️ WARNING: Changes affect attendance tracking',
        '⚠️ CAUTION: Coordinate with administration before major changes',
      ],
      featuresTeluguEn: [
        '✅ సులభమైన డ్రాగ్-అండ్-డ్రాప్ షెడ్యూల్ సృష్టి',
        '✅ విషయ వారీగా సమయ స్లాట్ కేటాయింపు',
        '✅ రోజువారీ మరియు వారంవారీ వీక్షణ ఎంపికలు',
        '⚠️ హెచ్చరిక: మార్పులు హాజరు ట్రాకింగ్‌ను ప్రభావితం చేస్తాయి',
        '⚠️ జాగ్రత్త: పెద్ద మార్పులకు ముందు పరిపాలనతో సమన్వయం చేసుకోండి',
      ],
      isInteractive: true,
      dangerWarnings: [
        'Do not delete active class schedules',
        'Always save changes before closing',
        'Verify schedule changes with school administration',
      ],
      dangerWarningsTeluguEn: [
        'సక్రియ క్లాస్ షెడ్యూల్‌లను తొలగించవద్దు',
        'మూసివేయడానికి ముందు ఎల్లప్పుడూ మార్పులను సేవ్ చేయండి',
        'పాఠశాల పరిపాలనతో షెడ్యూల్ మార్పులను ధృవీకరించండి',
      ],
    ),

    // Reset/Logout Warning Step
    TutorialStep(
      icon: Icons.warning,
      titleEn: 'IMPORTANT: Reset Function',
      titleTe: 'ముఖ్యమైనది: రీసెట్ ఫంక్షన్',
      descriptionEn:
          'The Reset button completely erases ALL app data including student info, attendance records, and settings. Use with EXTREME caution!',
      descriptionTe:
          'రీసెట్ బటన్ విద్యార్థుల సమాచారం, హాజరు రికార్డులు మరియు సెట్టింగ్‌లతో సహా అన్ని యాప్ డేటాను పూర్తిగా తొలగిస్తుంది. అత్యంత జాగ్రత్తతో ఉపయోగించండి!',
      features: [
        '🚨 DANGER: Permanently deletes ALL data',
        '🚨 DANGER: Cannot be undone',
        '🚨 WARNING: Requires 3-second hold to confirm',
        '✅ Useful only for complete app reset',
        '⚠️ CAUTION: Backup data before using',
      ],
      featuresTeluguEn: [
        '🚨 ప్రమాదం: అన్ని డేటాను శాశ్వతంగా తొలగిస్తుంది',
        '🚨 ప్రమాదం: రద్దు చేయలేము',
        '🚨 హెచ్చరిక: ధృవీకరించడానికి 3-సెకండ్ హోల్డ్ అవసరం',
        '✅ పూర్తి యాప్ రీసెట్ కోసం మాత్రమే ఉపయోగకరం',
        '⚠️ జాగ్రత్త: ఉపయోగించడానికి ముందు డేటాను బ్యాకప్ చేయండి',
      ],
      isInteractive: true,
      dangerWarnings: [
        'NEVER use Reset unless absolutely necessary',
        'Always backup important data first',
        'Contact IT support before resetting',
        'This will require complete app setup again',
      ],
      dangerWarningsTeluguEn: [
        'అవసరమైతే తప్ప రీసెట్‌ను ఎప్పుడూ ఉపయోగించవద్దు',
        'ఎల్లప్పుడూ ముఖ్యమైన డేటాను ముందుగా బ్యాకప్ చేయండి',
        'రీసెట్ చేయడానికి ముందు IT మద్దతును సంప్రదించండి',
        'దీనికి మళ్లీ పూర్తి యాప్ సెటప్ అవసరం',
      ],
    ),

    // Final Tips Step
    TutorialStep(
      icon: Icons.tips_and_updates,
      titleEn: 'Best Practices & Tips',
      titleTe: 'ఉత్తమ అభ్యాసాలు & చిట్కాలు',
      descriptionEn:
          'Follow these guidelines to use the app effectively and maintain accurate attendance records.',
      descriptionTe:
          'యాప్‌ను సమర్థవంతంగా ఉపయోగించడానికి మరియు ఖచ్చితమైన హాజరు రికార్డులను నిర్వహించడానికి ఈ మార్గదర్శకాలను అనుసరించండి.',
      features: [
        '✅ Take attendance at the same time daily',
        '✅ Verify camera attendance with manual check',
        '✅ Generate weekly reports for monitoring',
        '✅ Keep the app updated for best performance',
        '✅ Train students on proper camera positioning',
      ],
      featuresTeluguEn: [
        '✅ ప్రతిరోజూ అదే సమయంలో హాజరు తీసుకోండి',
        '✅ మాన్యువల్ చెక్‌తో కెమెరా హాజరును ధృవీకరించండి',
        '✅ పర్యవేక్షణ కోసం వారంవారీ నివేదికలను రూపొందించండి',
        '✅ ఉత్తమ పనితీరు కోసం యాప్‌ను అప్‌డేట్‌గా ఉంచండి',
        '✅ సరైన కెమెరా పొజిషనింగ్‌పై విద్యార్థులకు శిక్షణ ఇవ్వండి',
      ],
      isInteractive: false,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _tutorialSteps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _goToClassSetup();
    }
  }

  void _skipTutorial() {
    _goToClassSetup();
  }

  void _goToClassSetup() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => ClassSetupPage(isTeluguLanguage: _isTeluguLanguage),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header with language toggle and skip button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Language toggle
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextButton.icon(
                      icon: const Icon(Icons.language),
                      label: Text(_isTeluguLanguage ? 'English' : 'తెలుగు'),
                      onPressed: () {
                        setState(() {
                          _isTeluguLanguage = !_isTeluguLanguage;
                        });
                      },
                    ),
                  ),
                  // Skip button
                  TextButton(
                    onPressed: _skipTutorial,
                    child: Text(
                      getTranslatedText(
                        'Skip Tutorial',
                        'ట్యుటోరియల్ దాటవేయండి',
                      ),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tutorial content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _tutorialSteps.length,
                itemBuilder: (context, index) {
                  final step = _tutorialSteps[index];
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Icon with animation
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            step.icon,
                            size: 50,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Title
                        Text(
                          getTranslatedText(step.titleEn, step.titleTe),
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),

                        // Description
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            getTranslatedText(
                              step.descriptionEn,
                              step.descriptionTe,
                            ),
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(height: 1.5),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Features list
                        if (step.features.isNotEmpty) ...[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              getTranslatedText(
                                'Key Features:',
                                'ముఖ్య లక్షణాలు:',
                              ),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...(_isTeluguLanguage
                                  ? step.featuresTeluguEn
                                  : step.features)
                              .map((feature) {
                                bool isWarning =
                                    feature.contains('⚠️') ||
                                    feature.contains('🚨');
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color:
                                        isWarning
                                            ? Colors.orange.withOpacity(0.1)
                                            : Colors.green.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color:
                                          isWarning
                                              ? Colors.orange.withOpacity(0.3)
                                              : Colors.green.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Text(
                                    feature,
                                    style: TextStyle(
                                      color:
                                          isWarning
                                              ? Colors.orange[800]
                                              : Colors.green[800],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              })
                              ,
                        ],

                        // Danger warnings
                        if (step.dangerWarnings?.isNotEmpty == true) ...[
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.warning,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      getTranslatedText(
                                        'SAFETY WARNINGS:',
                                        'భద్రతా హెచ్చరికలు:',
                                      ),
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                ...(_isTeluguLanguage
                                        ? step.dangerWarningsTeluguEn ?? []
                                        : step.dangerWarnings ?? [])
                                    .map((warning) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 4,
                                        ),
                                        child: Text(
                                          '• $warning',
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      );
                                    })
                                    ,
                              ],
                            ),
                          ),
                        ],

                        // Interactive element for some steps
                        if (step.isInteractive) ...[
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.1),
                                  Theme.of(
                                    context,
                                  ).colorScheme.secondary.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.touch_app, color: Colors.blue),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    getTranslatedText(
                                      'This feature requires user interaction and careful attention to safety guidelines.',
                                      'ఈ ఫీచర్‌కు వినియోగదారు ఇంటరాక్షన్ మరియు భద్రతా మార్గదర్శకాలపై జాగ్రత్తగా దృష్టి అవసరం.',
                                    ),
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),

            // Page indicators and navigation
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _tutorialSteps.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 30 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color:
                              _currentPage == index
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Progress text
                  Text(
                    '${getTranslatedText('Step', 'దశ')} ${_currentPage + 1} ${getTranslatedText('of', 'లో')} ${_tutorialSteps.length}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Next/Finish button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _currentPage == _tutorialSteps.length - 1
                            ? getTranslatedText(
                              'Start Setup',
                              'సెటప్ ప్రారంభించండి',
                            )
                            : getTranslatedText('Next', 'తదుపరి'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class TutorialStep {
  final IconData icon;
  final String titleEn;
  final String titleTe;
  final String descriptionEn;
  final String descriptionTe;
  final List<String> features;
  final List<String> featuresTeluguEn;
  final bool isInteractive;
  final List<String>? dangerWarnings;
  final List<String>? dangerWarningsTeluguEn;

  TutorialStep({
    required this.icon,
    required this.titleEn,
    required this.titleTe,
    required this.descriptionEn,
    required this.descriptionTe,
    this.features = const [],
    this.featuresTeluguEn = const [],
    this.isInteractive = false,
    this.dangerWarnings,
    this.dangerWarningsTeluguEn,
  });
}
