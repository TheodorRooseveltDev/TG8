import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/responsive_utils.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;
    final sidePadding = ResponsiveUtils.getSafeHorizontalPadding(context);
    
    return Material(
      type: MaterialType.transparency,
      child: SizedBox.expand(
        child: Container(
          width: screenWidth,
          height: screenHeight,
          // Completely transparent - no background image
          color: Colors.transparent,
          padding: EdgeInsets.fromLTRB(
            sidePadding * 1.5,
            ResponsiveUtils.getSafeVerticalPadding(context) * 3,
            sidePadding * 1.5,
            ResponsiveUtils.getSafeVerticalPadding(context) * 2,
          ),
          child: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  Text(
                    'FLIGHT ENDED',
                    style: GoogleFonts.russoOne(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 28),
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
                  
                  // Stats
                  _StatRow(label: 'SCORE', value: score.toString()),
                  _StatRow(label: 'DISTANCE', value: '${distance}m'),
                  
                  Divider(
                    color: Colors.white24,
                    thickness: 2,
                    height: ResponsiveUtils.getResponsiveSpacing(context, 24),
                  ),
                  
                  // Token breakdown - COMPACT
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: ResponsiveUtils.getResponsiveSpacing(context, 2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'Collected',
                            style: GoogleFonts.russoOne(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                              color: Colors.white60,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: ResponsiveUtils.getResponsiveIconSize(context, 14),
                            ),
                            SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 4)),
                            Text(
                              '+$collectibleTokens',
                              style: GoogleFonts.russoOne(
                                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: ResponsiveUtils.getResponsiveSpacing(context, 2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'Distance',
                            style: GoogleFonts.russoOne(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                              color: Colors.white60,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.flight,
                              color: Colors.lightBlue,
                              size: ResponsiveUtils.getResponsiveIconSize(context, 14),
                            ),
                            SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 4)),
                            Text(
                              '+$distanceBonus',
                              style: GoogleFonts.russoOne(
                                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  Divider(
                    color: Colors.white24,
                    thickness: 2,
                    height: ResponsiveUtils.getResponsiveSpacing(context, 16),
                  ),
                  
                  _StatRow(
                    label: 'TOTAL EARNED',
                    value: airTokensEarned.toString(),
                    icon: Icons.monetization_on,
                  ),
                  
                  SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 20)),
                  
                  // Buttons - COMPACT
                  _GameOverButton(
                    label: 'TRY AGAIN',
                    icon: Icons.refresh,
                    color: Colors.orange,
                    onPressed: onRestart,
                  ),
                  
                  SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 6)),
                  
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
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveUtils.getResponsiveSpacing(context, 8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 3,
            child: Text(
              label,
              style: GoogleFonts.russoOne(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                color: Colors.white70,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 8)),
          Flexible(
            flex: 2,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: Colors.white,
                    size: ResponsiveUtils.getResponsiveIconSize(context, 20),
                  ),
                  SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 8)),
                ],
                Flexible(
                  child: Text(
                    value,
                    style: GoogleFonts.russoOne(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 22),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
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
        width: ResponsiveUtils.getResponsiveButtonWidth(context, 200),
        height: ResponsiveUtils.getResponsiveButtonHeight(context, 70),
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
                size: ResponsiveUtils.getResponsiveIconSize(context, 20),
              ),
              SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 10)),
              Flexible(
                child: Text(
                  widget.label,
                  style: GoogleFonts.exo2(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
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
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
