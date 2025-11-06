import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/audio/audio_manager.dart';
import '../../data/repositories/game_repository.dart';
import '../../data/models/user_profile.dart';
import 'webview_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AudioManager _audioManager = AudioManager.instance;
  final GameRepository _repository = GameRepository();
  
  late bool _musicEnabled;
  late bool _sfxEnabled;
  late double _musicVolume;
  late double _sfxVolume;
  late double _ambienceVolume;
  
  UserProfile? _userProfile;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadUserProfile();
  }
  
  void _loadSettings() {
    _musicEnabled = _audioManager.isMusicEnabled;
    _sfxEnabled = _audioManager.isSfxEnabled;
    _musicVolume = _audioManager.musicVolume;
    _sfxVolume = _audioManager.sfxVolume;
    _ambienceVolume = _audioManager.ambienceVolume;
  }
  
  Future<void> _loadUserProfile() async {
    final profile = await _repository.getUserProfile();
    if (mounted) {
      setState(() => _userProfile = profile);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full screen background image
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
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/ui/button_normal.png'),
                              fit: BoxFit.fill,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Title
                      Text(
                        'SETTINGS',
                        style: GoogleFonts.russoOne(
                          fontSize: 32,
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
                      
                      const Spacer(),
                      
                      const SizedBox(width: 60), // Balance back button
                    ],
                  ),
                ),
                
                // Settings content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      children: [
                        // Music Settings Card
                        _SettingCard(
                          title: 'MUSIC',
                          height: 240,
                          child: Column(
                            children: [
                              _SettingRow(
                                label: 'Enabled',
                                child: Switch(
                                  value: _musicEnabled,
                                  onChanged: (value) {
                                    setState(() => _musicEnabled = value);
                                    _audioManager.toggleMusic(value);
                                  },
                                  activeColor: AppColors.accentAmber,
                                ),
                              ),
                              
                              if (_musicEnabled) ...[
                                const SizedBox(height: 16),
                                _VolumeSlider(
                                  label: 'Volume',
                                  value: _musicVolume,
                                  onChanged: (value) {
                                    setState(() => _musicVolume = value);
                                    _audioManager.setMusicVolume(value);
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Sound Effects Card
                        _SettingCard(
                          title: 'SOUND EFFECTS',
                          height: 240,
                          child: Column(
                            children: [
                              _SettingRow(
                                label: 'Enabled',
                                child: Switch(
                                  value: _sfxEnabled,
                                  onChanged: (value) {
                                    setState(() => _sfxEnabled = value);
                                    _audioManager.toggleSfx(value);
                                  },
                                  activeColor: AppColors.accentAmber,
                                ),
                              ),
                              
                              if (_sfxEnabled) ...[
                                const SizedBox(height: 16),
                                _VolumeSlider(
                                  label: 'Volume',
                                  value: _sfxVolume,
                                  onChanged: (value) {
                                    setState(() => _sfxVolume = value);
                                    _audioManager.setSfxVolume(value);
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Ambience Card
                        _SettingCard(
                          title: 'AMBIENCE',
                          child: _VolumeSlider(
                            label: 'Wind Volume',
                            value: _ambienceVolume,
                            onChanged: (value) {
                              setState(() => _ambienceVolume = value);
                              _audioManager.setAmbienceVolume(value);
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Profile Card
                        _SettingCard(
                          title: 'PILOT PROFILE',
                          height: 240,
                          child: Column(
                            children: [
                              if (_userProfile != null) ...[
                                _LinkButton(
                                  label: 'Change Pilot Name',
                                  onPressed: () => _showEditNameDialog(),
                                ),
                                const SizedBox(height: 12),
                                _LinkButton(
                                  label: 'Change Call Sign',
                                  onPressed: () => _showEditCallSignDialog(),
                                ),
                                const SizedBox(height: 12),
                                _LinkButton(
                                  label: 'Change Avatar',
                                  onPressed: () => _showEditAvatarDialog(),
                                ),
                              ] else
                                const CircularProgressIndicator(
                                  color: AppColors.accentAmber,
                                ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Game Info Card
                        _SettingCard(
                          title: 'GAME INFO',
                          child: Column(
                            children: [
                              _SettingRow(
                                label: 'Version',
                                child: Text(
                                  '1.0.0',
                                  style: GoogleFonts.exo2(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              _SettingRow(
                                label: 'Controls',
                                child: Text(
                                  'Tap to take altitude, Swipe to move',
                                  style: GoogleFonts.exo2(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Legal Card
                        _SettingCard(
                          title: 'LEGAL',
                          child: Column(
                            children: [
                              _LinkButton(
                                label: 'Privacy Policy',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const WebViewScreen(
                                        url: 'http://aviarollhigh.com/privacy/',
                                        title: 'Privacy Policy',
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              _LinkButton(
                                label: 'Terms of Service',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const WebViewScreen(
                                        url: 'http://aviarollhigh.com/terms/',
                                        title: 'Terms of Service',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Reset Button
                        _ResetButton(
                          onPressed: () => _showResetDialog(context),
                        ),
                        
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.secondaryWood,
        title: Text(
          'Delete All Data?',
          style: GoogleFonts.russoOne(color: Colors.red),
        ),
        content: Text(
          'This will permanently delete:\n\n• Your pilot profile\n• All progress and scores\n• All upgrades and unlocked planes\n• All saved statistics\n\nThis action CANNOT be undone!',
          style: GoogleFonts.exo2(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CANCEL',
              style: GoogleFonts.exo2(color: Colors.white),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAllData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              'DELETE ALL',
              style: GoogleFonts.exo2(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAllData() async {
    try {
      // Clear all SharedPreferences data
      await _repository.clearAllData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'All data deleted successfully',
              style: GoogleFonts.exo2(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate back to main/splash screen to restart
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete data: $e',
              style: GoogleFonts.exo2(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showEditNameDialog() {
    final controller = TextEditingController(text: _userProfile?.pilotName ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.secondaryWood,
        title: Text(
          'Change Pilot Name',
          style: GoogleFonts.russoOne(color: AppColors.accentAmber),
        ),
        content: TextField(
          controller: controller,
          maxLength: 20,
          style: GoogleFonts.exo2(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter new pilot name',
            hintStyle: GoogleFonts.exo2(color: Colors.white.withOpacity(0.5)),
            filled: true,
            fillColor: Colors.black.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.accentAmber),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.accentAmber.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.accentAmber, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: GoogleFonts.exo2(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Name cannot be empty', style: GoogleFonts.exo2())),
                );
                return;
              }
              
              final updated = _userProfile!.copyWith(pilotName: newName);
              await _repository.saveUserProfile(updated);
              await _loadUserProfile();
              
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Pilot name updated!', style: GoogleFonts.exo2()),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text('SAVE', style: GoogleFonts.exo2(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditCallSignDialog() {
    final controller = TextEditingController(text: _userProfile?.callSign ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.secondaryWood,
        title: Text(
          'Change Call Sign',
          style: GoogleFonts.russoOne(color: AppColors.accentAmber),
        ),
        content: TextField(
          controller: controller,
          maxLength: 15,
          textCapitalization: TextCapitalization.characters,
          style: GoogleFonts.exo2(color: Colors.white, letterSpacing: 2),
          decoration: InputDecoration(
            hintText: 'Enter new call sign',
            hintStyle: GoogleFonts.exo2(color: Colors.white.withOpacity(0.5)),
            filled: true,
            fillColor: Colors.black.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.accentAmber),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.accentAmber.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.accentAmber, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: GoogleFonts.exo2(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newCallSign = controller.text.trim().toUpperCase();
              if (newCallSign.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Call sign cannot be empty', style: GoogleFonts.exo2())),
                );
                return;
              }
              
              final updated = _userProfile!.copyWith(callSign: newCallSign);
              await _repository.saveUserProfile(updated);
              await _loadUserProfile();
              
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Call sign updated!', style: GoogleFonts.exo2()),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text('SAVE', style: GoogleFonts.exo2(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditAvatarDialog() {
    final avatarEmojis = ['✈️', '🛩️', '🚁', '🛫', '🚀', '🪂'];
    int selectedIndex = _userProfile?.avatarIndex ?? 0;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.secondaryWood,
          title: Text(
            'Choose Avatar',
            style: GoogleFonts.russoOne(color: AppColors.accentAmber),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: avatarEmojis.length,
              itemBuilder: (context, index) {
                final isSelected = index == selectedIndex;
                return GestureDetector(
                  onTap: () {
                    setDialogState(() => selectedIndex = index);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppColors.accentAmber.withOpacity(0.3)
                          : Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected 
                            ? AppColors.accentAmber
                            : Colors.white.withOpacity(0.3),
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        avatarEmojis[index],
                        style: const TextStyle(fontSize: 48),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CANCEL', style: GoogleFonts.exo2(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () async {
                final updated = _userProfile!.copyWith(avatarIndex: selectedIndex);
                await _repository.saveUserProfile(updated);
                await _loadUserProfile();
                
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Avatar updated!', style: GoogleFonts.exo2()),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: Text('SAVE', style: GoogleFonts.exo2(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final String title;
  final Widget child;
  final double? height;
  
  const _SettingCard({
    required this.title,
    required this.child,
    this.height,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 220,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/ui/dialogue_box.png'),
          fit: BoxFit.fill,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Title
          Text(
            title,
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
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String label;
  final Widget child;
  
  const _SettingRow({
    required this.label,
    required this.child,
  });
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.exo2(
            fontSize: 15,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        child,
      ],
    );
  }
}

class _LinkButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  
  const _LinkButton({
    required this.label,
    required this.onPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.exo2(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.white.withOpacity(0.6),
            size: 16,
          ),
        ],
      ),
    );
  }
}

class _ResetButton extends StatefulWidget {
  final VoidCallback onPressed;
  
  const _ResetButton({required this.onPressed});
  
  @override
  State<_ResetButton> createState() => _ResetButtonState();
}

class _ResetButtonState extends State<_ResetButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Container(
        width: 240,
        height: 56,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              _isPressed
                  ? 'assets/images/ui/button_pressed.png'
                  : 'assets/images/ui/button_normal.png',
            ),
            fit: BoxFit.fill,
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.refresh,
                color: Colors.redAccent,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'RESET DATA',
                style: GoogleFonts.russoOne(
                  fontSize: 14,
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
            ],
          ),
        ),
      ),
    );
  }
}

class _VolumeSlider extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  
  const _VolumeSlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.exo2(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: GoogleFonts.russoOne(
                fontSize: 14,
                color: AppColors.accentAmber,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.8),
                    offset: const Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.accentAmber,
            inactiveTrackColor: Colors.white.withOpacity(0.3),
            thumbColor: AppColors.accentAmber,
            overlayColor: AppColors.accentAmber.withOpacity(0.3),
            trackHeight: 8,
          ),
          child: Slider(
            value: value,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
