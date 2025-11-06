import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/game_constants.dart';

/// Widget showing current balloon type info
class BalloonInfoDisplay extends StatelessWidget {
  final BalloonType balloonType;
  
  const BalloonInfoDisplay({
    super.key,
    required this.balloonType,
  });

  String _getBalloonName(BalloonType type) {
    switch (type) {
      case BalloonType.standard:
        return '✈️ Basic Plane';
      case BalloonType.foil:
      case BalloonType.fighter:
        return '🛩️ Sopwith Camel';
      case BalloonType.hydrogen:
      case BalloonType.jet:
        return '✈️ P-51 Mustang';
      case BalloonType.cluster:
      case BalloonType.cargo:
        return '🚀 F-35 Lightning';
    }
  }

  String _getBalloonTrait(BalloonType type) {
    switch (type) {
      case BalloonType.standard:
        return 'Balanced';
      case BalloonType.foil:
      case BalloonType.fighter:
        return 'High Control';
      case BalloonType.hydrogen:
      case BalloonType.jet:
        return 'Very Fast';
      case BalloonType.cluster:
      case BalloonType.cargo:
        return 'Durable';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accentAmber.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getBalloonName(balloonType),
            style: GoogleFonts.exo2(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _getBalloonTrait(balloonType),
            style: GoogleFonts.exo2(
              color: AppColors.accentAmber,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
