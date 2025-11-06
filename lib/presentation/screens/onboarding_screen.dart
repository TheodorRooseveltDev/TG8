import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/user_profile.dart';
import '../../data/repositories/game_repository.dart';
import 'menu_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final GameRepository _repository = GameRepository();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _callSignController = TextEditingController();
  int _selectedAvatarIndex = 0;
  bool _isCreating = false;

  final List<String> _avatarEmojis = ['✈️', '🛩️', '🚁', '🛫', '🚀', '🪂'];

  @override
  void dispose() {
    _nameController.dispose();
    _callSignController.dispose();
    super.dispose();
  }

  Future<void> _createProfile() async {
    final name = _nameController.text.trim();
    final callSign = _callSignController.text.trim();

    if (name.isEmpty) {
      _showError('Please enter your pilot name');
      return;
    }

    if (callSign.isEmpty) {
      _showError('Please enter your call sign');
      return;
    }

    setState(() => _isCreating = true);

    try {
      final profile = UserProfile(
        pilotName: name,
        callSign: callSign,
        accountCreated: DateTime.now(),
        avatarIndex: _selectedAvatarIndex,
      );

      await _repository.saveUserProfile(profile);
      await _repository.setFirstLaunchComplete();

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MenuScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to create profile. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Transform.scale(
              scale: 1.5,
              child: Image.asset(
                'assets/images/ui/menu_background.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title
                    Text(
                      'WELCOME, PILOT!',
                      style: GoogleFonts.russoOne(
                        fontSize: 42,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.8),
                            offset: const Offset(3, 3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      'Let\'s set up your pilot profile',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.exo2(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Avatar selection
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.accentAmber.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'CHOOSE YOUR AVATAR',
                            style: GoogleFonts.russoOne(
                              fontSize: 16,
                              color: AppColors.accentAmber,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: List.generate(_avatarEmojis.length, (index) {
                              return GestureDetector(
                                onTap: () => setState(() => _selectedAvatarIndex = index),
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: _selectedAvatarIndex == index
                                        ? AppColors.accentAmber
                                        : Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _selectedAvatarIndex == index
                                          ? Colors.white
                                          : Colors.transparent,
                                      width: 3,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _avatarEmojis[index],
                                      style: const TextStyle(fontSize: 32),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Pilot Name
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.accentAmber.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: TextField(
                        controller: _nameController,
                        style: GoogleFonts.exo2(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Pilot Name',
                          hintStyle: GoogleFonts.exo2(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.5),
                          ),
                          border: InputBorder.none,
                          icon: const Icon(Icons.person, color: AppColors.accentAmber),
                        ),
                        maxLength: 20,
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Call Sign
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.accentAmber.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: TextField(
                        controller: _callSignController,
                        style: GoogleFonts.exo2(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Call Sign (e.g., MAVERICK)',
                          hintStyle: GoogleFonts.exo2(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.5),
                          ),
                          border: InputBorder.none,
                          icon: const Icon(Icons.military_tech, color: AppColors.accentAmber),
                        ),
                        maxLength: 15,
                        textCapitalization: TextCapitalization.characters,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Create Profile Button
                    GestureDetector(
                      onTap: _isCreating ? null : _createProfile,
                      child: Container(
                        width: 280,
                        height: 80,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: const AssetImage('assets/images/ui/button_normal.png'),
                            fit: BoxFit.fill,
                            colorFilter: _isCreating
                                ? ColorFilter.mode(
                                    Colors.grey.withOpacity(0.5),
                                    BlendMode.srcATop,
                                  )
                                : null,
                          ),
                        ),
                        child: Center(
                          child: _isCreating
                              ? const CircularProgressIndicator(
                                  color: AppColors.accentAmber,
                                )
                              : Text(
                                  'START FLYING',
                                  style: GoogleFonts.russoOne(
                                    fontSize: 20,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.8),
                                        offset: const Offset(2, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                        ),
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
}
