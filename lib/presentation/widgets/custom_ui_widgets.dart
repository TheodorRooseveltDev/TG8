import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

/// Custom button that uses the game's UI assets
class CustomGameButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool enabled;
  final double width;
  final double height;

  const CustomGameButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.enabled = true,
    this.width = 300,
    this.height = 70,
  });

  @override
  State<CustomGameButton> createState() => _CustomGameButtonState();
}

class _CustomGameButtonState extends State<CustomGameButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.enabled ? (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      } : null,
      onTapCancel: () => setState(() => _isPressed = false),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              _isPressed 
                ? 'assets/images/ui/button_pressed.png'
                : 'assets/images/ui/button_normal.png',
            ),
            fit: BoxFit.fill,
            opacity: widget.enabled ? 1.0 : 0.5,
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
              ],
              Text(
                widget.label,
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
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom dialogue box using game assets
class CustomDialogueBox extends StatelessWidget {
  final String title;
  final String message;
  final List<Widget> actions;

  const CustomDialogueBox({
    super.key,
    required this.title,
    required this.message,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assets/images/ui/dialogue_box.png'),
            fit: BoxFit.fill,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              title,
              style: GoogleFonts.russoOne(
                fontSize: 28,
                color: AppColors.accentAmber,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.8),
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            // Message
            Text(
              message,
              style: GoogleFonts.exo2(
                fontSize: 16,
                color: Colors.white,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            
            // Actions
            if (actions.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: actions,
              ),
          ],
        ),
      ),
    );
  }
}

/// Custom progress bar using game assets
class CustomProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double width;
  final double height;
  final Color? fillColor;

  const CustomProgressBar({
    super.key,
    required this.progress,
    this.width = 200,
    this.height = 30,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          // Background
          Image.asset(
            'assets/images/ui/progress_bar.png',
            width: width,
            height: height,
            fit: BoxFit.fill,
          ),
          
          // Fill
          Positioned(
            left: 5,
            top: 5,
            bottom: 5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: (width - 10) * progress.clamp(0.0, 1.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      fillColor ?? AppColors.accentAmber,
                      (fillColor ?? AppColors.accentAmber).withOpacity(0.6),
                    ],
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

/// Star rating display
class StarRating extends StatelessWidget {
  final int stars; // 0 to 3
  final double size;

  const StarRating({
    super.key,
    required this.stars,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Image.asset(
            'assets/images/ui/star.png',
            width: size,
            height: size,
            color: index < stars ? null : Colors.grey,
            colorBlendMode: index < stars ? null : BlendMode.saturation,
          ),
        );
      }),
    );
  }
}

/// Lock icon for locked content
class LockIcon extends StatelessWidget {
  final double size;

  const LockIcon({
    super.key,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/ui/lock.png',
      width: size,
      height: size,
    );
  }
}

/// Checkpoint icon
class CheckpointIcon extends StatelessWidget {
  final double size;

  const CheckpointIcon({
    super.key,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/ui/checkpoint_icon.png',
      width: size,
      height: size,
    );
  }
}
