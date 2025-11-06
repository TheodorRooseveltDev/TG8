import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tutorial overlay that guides new players through game mechanics
class TutorialOverlay extends StatefulWidget {
  final VoidCallback onComplete;
  
  const TutorialOverlay({
    super.key,
    required this.onComplete,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
  
  /// Check if user has completed tutorial
  static Future<bool> hasCompletedTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('tutorial_completed') ?? false;
  }
  
  /// Mark tutorial as completed
  static Future<void> markTutorialComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_completed', true);
  }
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  int _currentStep = 0;
  
  final List<TutorialStep> _steps = [
    TutorialStep(
      title: 'Welcome to AviaRoll High! ✈️',
      description: 'Pilot your plane through the skies by managing fuel and avoiding obstacles.',
      icon: Icons.celebration,
      position: TutorialPosition.center,
    ),
    TutorialStep(
      title: 'Tap to Boost �',
      description: 'Tap and hold anywhere to boost your plane. More power = faster ascent!',
      icon: Icons.touch_app,
      position: TutorialPosition.center,
    ),
    TutorialStep(
      title: 'Swipe to Steer ⬅️➡️',
      description: 'Swipe left or right to steer your plane horizontally.',
      icon: Icons.swipe,
      position: TutorialPosition.center,
    ),
    TutorialStep(
      title: 'Watch Your Fuel! ⚠️',
      description: 'Keep fuel in the optimal range (40-70%). Too low = stall! Collect fuel boosts!',
      icon: Icons.speed,
      position: TutorialPosition.bottomLeft,
    ),
    TutorialStep(
      title: 'Reach Checkpoints 🎯',
      description: 'Hit checkpoints to refill fuel and save your progress. Good luck, pilot!',
      icon: Icons.flag,
      position: TutorialPosition.center,
    ),
  ];

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      TutorialOverlay.markTutorialComplete();
      widget.onComplete();
    }
  }

  void _skipTutorial() {
    TutorialOverlay.markTutorialComplete();
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];
    
    return Material(
      color: Colors.black.withOpacity(0.85),
      child: SafeArea(
        child: Stack(
          children: [
            // Tutorial content
            _buildTutorialContent(step),
            
            // Skip button
            Positioned(
              top: 16,
              right: 16,
              child: TextButton(
                onPressed: _skipTutorial,
                child: Text(
                  'SKIP',
                  style: GoogleFonts.exo2(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorialContent(TutorialStep step) {
    Widget content = Container(
      margin: const EdgeInsets.all(32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.secondaryWood.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryBrass,
          width: 3,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Icon(
            step.icon,
            color: AppColors.accentAmber,
            size: 64,
          ),
          
          const SizedBox(height: 24),
          
          // Title
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.russoOne(
              fontSize: 24,
              color: AppColors.accentAmber,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Description
          Text(
            step.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.exo2(
              fontSize: 16,
              color: Colors.white,
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Progress indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _steps.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == _currentStep
                      ? AppColors.accentAmber
                      : Colors.white38,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Next button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentAmber,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _currentStep < _steps.length - 1 ? 'NEXT' : 'START FLYING!',
                style: GoogleFonts.exo2(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    // Position the content based on step position
    switch (step.position) {
      case TutorialPosition.center:
        return Center(child: content);
      case TutorialPosition.top:
        return Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 80),
            child: content,
          ),
        );
      case TutorialPosition.bottom:
        return Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 80),
            child: content,
          ),
        );
      case TutorialPosition.bottomLeft:
        return Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 120, left: 16),
            child: content,
          ),
        );
    }
  }
}

class TutorialStep {
  final String title;
  final String description;
  final IconData icon;
  final TutorialPosition position;

  TutorialStep({
    required this.title,
    required this.description,
    required this.icon,
    this.position = TutorialPosition.center,
  });
}

enum TutorialPosition {
  center,
  top,
  bottom,
  bottomLeft,
}
