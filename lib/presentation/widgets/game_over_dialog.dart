import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GameOverDialog extends StatelessWidget {
  final int score;
  final int distance;
  final int airTokensEarned;
  final VoidCallback onRestart;
  final VoidCallback onMainMenu;

  const GameOverDialog({
    super.key,
    required this.score,
    required this.distance,
    required this.airTokensEarned,
    required this.onRestart,
    required this.onMainMenu,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate breakdown
    final distanceBonus = (distance / 100).floor();
    final collectibleTokens = airTokensEarned - distanceBonus;
    
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.98, // Nearly full width
            height: screenHeight * 0.85, // 85% of screen height
            constraints: const BoxConstraints(
              maxWidth: 800, // Much bigger
              maxHeight: 900,
            ),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/ui/menu_background.png'),
                fit: BoxFit.fill, // Fill to take full size
              ),
            ),
            padding: const EdgeInsets.fromLTRB(100, 150, 100, 100), // Top padding 70px
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
              children: [
                // Title
                Text(
                  'FLIGHT ENDED',
                  style: GoogleFonts.russoOne(
                    fontSize: 28,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Stats
                _StatRow(label: 'SCORE', value: score.toString()),
                _StatRow(label: 'DISTANCE', value: '${distance}m'),
                
                const Divider(color: Colors.white24, thickness: 2, height: 24),
                
                // Token breakdown - COMPACT
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Collected',
                        style: GoogleFonts.russoOne(
                          fontSize: 12,
                          color: Colors.white60,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '+$collectibleTokens',
                            style: GoogleFonts.russoOne(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Distance',
                        style: GoogleFonts.russoOne(
                          fontSize: 12,
                          color: Colors.white60,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.flight, color: Colors.lightBlue, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '+$distanceBonus',
                            style: GoogleFonts.russoOne(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const Divider(color: Colors.white24, thickness: 2, height: 16),
                
                _StatRow(
                  label: 'TOTAL EARNED',
                  value: airTokensEarned.toString(),
                  icon: Icons.monetization_on,
                ),
                
                const SizedBox(height: 20), // Reduced spacing
                
                // Buttons - COMPACT
                _GameOverButton(
                  label: 'TRY AGAIN',
                  icon: Icons.refresh,
                  color: Colors.orange,
                  onPressed: onRestart,
                ),
                
                const SizedBox(height: 6), // Reduced spacing between buttons
                
                _GameOverButton(
                  label: 'MAIN MENU',
                  icon: Icons.home,
                  color: Colors.blue,
                  onPressed: onMainMenu,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const _StatRow({
    required this.label,
    required this.value,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.russoOne(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                value,
                style: GoogleFonts.russoOne(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GameOverButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _GameOverButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  State<_GameOverButton> createState() => _GameOverButtonState();
}

class _GameOverButtonState extends State<_GameOverButton> {
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
        width: 200, // Smaller button width
        height: 70, // Smaller button height
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
              Icon(widget.icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: GoogleFonts.exo2(
                  fontSize: 14, // Smaller text
                  fontWeight: FontWeight.bold,
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
