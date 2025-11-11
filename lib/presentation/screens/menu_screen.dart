import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_utils.dart';
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
    // Get responsive values
    final tokenWidth = ResponsiveUtils.getResponsiveButtonWidth(context, 140);
    final tokenHeight = ResponsiveUtils.getResponsiveButtonHeight(context, 75);
    final topPadding = ResponsiveUtils.getSafeVerticalPadding(context);
    final sidePadding = ResponsiveUtils.getSafeHorizontalPadding(context);
    
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
                top: topPadding,
                right: sidePadding,
                child: Container(
                  width: tokenWidth,
                  height: tokenHeight,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/ui/button_normal.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.monetization_on,
                        color: Colors.amber,
                        size: ResponsiveUtils.getResponsiveIconSize(context, 20),
                      ),
                      SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 8)),
                      Flexible(
                        child: Text(
                          '$_airTokens',
                          style: GoogleFonts.russoOne(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.8),
                                offset: const Offset(2, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Main menu content
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    sidePadding,
                    ResponsiveUtils.isTablet(context) 
                        ? MediaQuery.of(context).size.height * 0.15  // 15% from top on iPad
                        : MediaQuery.of(context).size.height * 0.2,  // 20% from top on phones (centered)
                    sidePadding,
                    topPadding,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Game title
                      Text(
                        'AVIAROLL',
                        style: GoogleFonts.russoOne(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 48),
                          color: AppColors.accentAmber,
                          shadows: [
                            const Shadow(
                              color: Colors.black45,
                              offset: Offset(4, 4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'HIGH',
                        style: GoogleFonts.russoOne(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 56),
                          color: Colors.white,
                          shadows: [
                            const Shadow(
                              color: Colors.black45,
                              offset: Offset(4, 4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
                      Text(
                        'Soar to the Skies',
                        style: GoogleFonts.exo2(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 24),
                          color: AppColors.accentAmber.withOpacity(0.8),
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 60)),
                      
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
                      
                      SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 40)),
                      
                      // Secondary options in a row
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width - (sidePadding * 2),
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: ResponsiveUtils.getResponsiveSpacing(context, 12),
                          runSpacing: ResponsiveUtils.getResponsiveSpacing(context, 12),
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
                      ),
                      
                      SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 12)),
                      
                      // Bottom options in a row
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width - (sidePadding * 2),
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: ResponsiveUtils.getResponsiveSpacing(context, 12),
                          runSpacing: ResponsiveUtils.getResponsiveSpacing(context, 12),
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
                      ),
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
    final buttonWidth = ResponsiveUtils.getResponsiveButtonWidth(context, 280);
    final buttonHeight = ResponsiveUtils.getResponsiveButtonHeight(context, 150);
    
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Container(
        width: buttonWidth,
        height: buttonHeight,
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: Colors.white,
                size: ResponsiveUtils.getResponsiveIconSize(context, 24),
              ),
              SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12)),
              Flexible(
                child: Text(
                  widget.label,
                  style: GoogleFonts.russoOne(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 28),
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.8),
                        offset: const Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
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
    // Make buttons smaller for smaller screens to prevent overflow
    final screenWidth = MediaQuery.of(context).size.width;
    final baseWidth = screenWidth < 375 ? 160.0 : 192.0;
    final baseHeight = screenWidth < 375 ? 80.0 : 96.0;
    
    final buttonWidth = ResponsiveUtils.getResponsiveButtonWidth(context, baseWidth);
    final buttonHeight = ResponsiveUtils.getResponsiveButtonHeight(context, baseHeight);
    
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Container(
        width: buttonWidth,
        height: buttonHeight,
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
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.getSafeHorizontalPadding(context) * 0.25,
            ),
            child: Text(
              widget.label,
              style: GoogleFonts.russoOne(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.8),
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
        ),
      ),
    );
  }
}
