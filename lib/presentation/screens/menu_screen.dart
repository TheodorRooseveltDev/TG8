import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../data/repositories/game_repository.dart';
import 'game_screen.dart';
import 'upgrade_screen.dart';
import 'plane_selection_screen.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';

/// Main menu screen with game options
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final GameRepository _repository = GameRepository();
  int _airTokens = 0;

  @override
  void initState() {
    super.initState();
    _loadTokens();
  }

  Future<void> _loadTokens() async {
    final tokens = await _repository.getAirTokens();
    setState(() {
      _airTokens = tokens;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full screen background image - BIGGER than screen
          Positioned.fill(
            child: Transform.scale(
              scale: 1.5, // 150% scale - bigger but not too much
              child: Image.asset(
                'assets/images/ui/menu_background.png',
                fit: BoxFit.cover, // Cover entire area
              ),
            ),
          ),
          // Content on top
          SafeArea(
            child: Stack(
              children: [
              // Air tokens display - top right
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  width: 140,
                  height: 75,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/ui/button_normal.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$_airTokens',
                        style: GoogleFonts.russoOne(
                          fontSize: 16,
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
              // Main menu content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Game title
                    Text(
                      'AVIAROLL',
                      style: GoogleFonts.russoOne(
                        fontSize: 48,
                        color: AppColors.accentAmber,
                        shadows: [
                          const Shadow(
                            color: Colors.black45,
                            offset: Offset(4, 4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'HIGH',
                      style: GoogleFonts.russoOne(
                        fontSize: 56,
                        color: Colors.white,
                        shadows: [
                          const Shadow(
                            color: Colors.black45,
                            offset: Offset(4, 4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Soar to the Skies',
                      style: GoogleFonts.exo2(
                        fontSize: 24,
                        color: AppColors.accentAmber.withOpacity(0.8),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    
                    const SizedBox(height: 60),
                    
                    // Play button - Main CTA
                    _MenuButton(
                      label: 'PLAY',
                      icon: Icons.play_arrow,
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const GameScreen(),
                          ),
                        );
                        // Reload tokens when returning from game
                        _loadTokens();
                      },
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Secondary options in a row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Planes button
                        _SmallMenuButton(
                          label: 'PLANES',
                          icon: Icons.flight,
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const PlaneSelectionScreen()),
                            );
                            _loadTokens();
                          },
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Upgrades button
                        _SmallMenuButton(
                          label: 'UPGRADES',
                          icon: Icons.upgrade,
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const UpgradeScreen()),
                            );
                            _loadTokens();
                          },
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Bottom options in a row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Settings button
                        _SmallMenuButton(
                          label: 'SETTINGS',
                          icon: Icons.settings,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SettingsScreen()),
                            );
                          },
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Statistics button
                        _SmallMenuButton(
                          label: 'STATS',
                          icon: Icons.bar_chart,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const StatisticsScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatefulWidget {
  const _MenuButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton> {
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
        width: 280, // Same width for all buttons
        height: 150, // Same height as money display
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
              Icon(
                widget.icon,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: GoogleFonts.russoOne(
                  fontSize: 28,
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

// Smaller button for secondary options
class _SmallMenuButton extends StatefulWidget {
  const _SmallMenuButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  State<_SmallMenuButton> createState() => _SmallMenuButtonState();
}

class _SmallMenuButtonState extends State<_SmallMenuButton> {
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
        width: 192, // 20% bigger (160 * 1.2)
        height: 96, // 20% bigger (80 * 1.2)
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.label,
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
    );
  }
}
