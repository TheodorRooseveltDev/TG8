import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flame/components.dart';
import 'dart:math' as math;
import '../../core/constants/app_colors.dart';
import '../../game/systems/replay_system.dart';

/// Replay viewer screen with playback controls
class ReplayViewerScreen extends StatefulWidget {
  final List<ReplayFrame> replayData;
  final int finalScore;
  final double finalDistance;

  const ReplayViewerScreen({
    super.key,
    required this.replayData,
    required this.finalScore,
    required this.finalDistance,
  });

  @override
  State<ReplayViewerScreen> createState() => _ReplayViewerScreenState();
}

class _ReplayViewerScreenState extends State<ReplayViewerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isPlaying = false;
  double _playbackSpeed = 1.0;
  int _currentFrameIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: (widget.replayData.length * (1000 / 30)).toInt(),
      ),
    );

    _animationController.addListener(() {
      setState(() {
        _currentFrameIndex =
            (_animationController.value * (widget.replayData.length - 1))
                .round()
                .clamp(0, widget.replayData.length - 1);
      });
    });

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _animationController.stop();
        _isPlaying = false;
      } else {
        if (_animationController.isCompleted) {
          _animationController.reset();
        }
        _animationController.forward();
        _isPlaying = true;
      }
    });
  }

  void _restart() {
    setState(() {
      _animationController.reset();
      _animationController.forward();
      _isPlaying = true;
    });
  }

  void _changeSpeed() {
    setState(() {
      if (_playbackSpeed == 1.0) {
        _playbackSpeed = 0.5;
      } else if (_playbackSpeed == 0.5) {
        _playbackSpeed = 2.0;
      } else {
        _playbackSpeed = 1.0;
      }

      // Update animation duration
      _animationController.duration = Duration(
        milliseconds:
            (widget.replayData.length * (1000 / 30) / _playbackSpeed).toInt(),
      );
    });
  }

  void _seekToFrame(double value) {
    setState(() {
      _currentFrameIndex = (value * (widget.replayData.length - 1))
          .round()
          .clamp(0, widget.replayData.length - 1);
      _animationController.value = value;
    });
  }

  ReplayFrame get _currentFrame {
    if (widget.replayData.isEmpty) {
      return ReplayFrame(
        timestamp: DateTime.now(),
        balloonPosition: Vector2.zero(),
        pressure: 50,
        speed: 0,
      );
    }
    return widget.replayData[_currentFrameIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.secondaryWood, AppColors.primaryBrass],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context),

              // Replay visualization area
              Expanded(
                child: _buildReplayVisualization(),
              ),

              // Timeline scrubber
              _buildTimeline(),

              // Controls
              _buildControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          Text(
            'REPLAY',
            style: GoogleFonts.russoOne(
              fontSize: 24,
              color: AppColors.accentAmber,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accentAmber,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${widget.replayData.length} frames',
              style: GoogleFonts.exo2(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplayVisualization() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryBrass.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            // Game visualization
            CustomPaint(
              painter: _ReplayPainter(
                currentFrame: _currentFrame,
                allFrames: widget.replayData,
                currentIndex: _currentFrameIndex,
              ),
              size: Size.infinite,
            ),

            // Stats overlay
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: _buildStatsOverlay(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsOverlay() {
    final frame = _currentFrame;
    final pressurePercent = frame.pressure;
    final pressureColor = _getPressureColor(pressurePercent);
    
    // Calculate elapsed time from first frame
    final elapsedMs = widget.replayData.isEmpty ? 0 :
      frame.timestamp.difference(widget.replayData.first.timestamp).inMilliseconds;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Speed
        _StatBadge(
          icon: Icons.speed,
          label: 'Speed',
          value: '${frame.speed.toStringAsFixed(1)}x',
          color: AppColors.accentAmber,
        ),
        const SizedBox(height: 8),

        // Pressure
        _StatBadge(
          icon: Icons.thermostat,
          label: 'Pressure',
          value: '${pressurePercent.toStringAsFixed(0)}%',
          color: pressureColor,
        ),
        const SizedBox(height: 8),

        // Timestamp
        _StatBadge(
          icon: Icons.timer,
          label: 'Time',
          value: '${(elapsedMs / 1000).toStringAsFixed(1)}s',
          color: Colors.white,
        ),
      ],
    );
  }

  Color _getPressureColor(double pressure) {
    if (pressure < 40) return AppColors.pressureLow;
    if (pressure < 70) return AppColors.pressureOptimal;
    if (pressure < 85) return AppColors.pressureHigh;
    return AppColors.pressureCritical;
  }

  Widget _buildTimeline() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // Progress bar
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.accentAmber,
              inactiveTrackColor: Colors.white24,
              thumbColor: AppColors.accentAmber,
              overlayColor: AppColors.accentAmber.withOpacity(0.3),
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 8,
              ),
              trackHeight: 4,
            ),
            child: Slider(
              value: widget.replayData.isEmpty
                  ? 0
                  : _currentFrameIndex / (widget.replayData.length - 1),
              onChanged: _seekToFrame,
              onChangeStart: (_) {
                if (_isPlaying) {
                  _animationController.stop();
                }
              },
              onChangeEnd: (_) {
                if (_isPlaying) {
                  _animationController.forward(
                    from: _currentFrameIndex / (widget.replayData.length - 1),
                  );
                }
              },
            ),
          ),

          // Time labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatTime(
                    widget.replayData.isEmpty ? 0 :
                    _currentFrame.timestamp.difference(widget.replayData.first.timestamp).inMilliseconds / 1000,
                  ),
                  style: GoogleFonts.exo2(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  _formatTime(
                    widget.replayData.isEmpty
                        ? 0
                        : widget.replayData.last.timestamp.difference(widget.replayData.first.timestamp).inMilliseconds / 1000,
                  ),
                  style: GoogleFonts.exo2(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(double seconds) {
    final minutes = seconds ~/ 60;
    final secs = (seconds % 60).toStringAsFixed(1);
    return minutes > 0 ? '$minutes:${secs.padLeft(4, '0')}' : '${secs}s';
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Main controls row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Restart button
              _ControlButton(
                icon: Icons.replay,
                onPressed: _restart,
                label: 'Restart',
              ),

              const SizedBox(width: 16),

              // Play/Pause button (larger)
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentAmber,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentAmber.withOpacity(0.5),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 32,
                  ),
                  color: Colors.white,
                  onPressed: _togglePlayPause,
                ),
              ),

              const SizedBox(width: 16),

              // Speed control
              _ControlButton(
                icon: Icons.speed,
                onPressed: _changeSpeed,
                label: '${_playbackSpeed}x',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Final stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondaryWood.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryBrass.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _FinalStat(
                  icon: Icons.emoji_events,
                  label: 'Final Score',
                  value: widget.finalScore.toString(),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white24,
                ),
                _FinalStat(
                  icon: Icons.straighten,
                  label: 'Distance',
                  value: '${widget.finalDistance.toInt()}m',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatBadge({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.exo2(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: GoogleFonts.exo2(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String label;

  const _ControlButton({
    required this.icon,
    required this.onPressed,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryBrass,
          ),
          child: IconButton(
            icon: Icon(icon, size: 24),
            color: Colors.white,
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.exo2(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

class _FinalStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _FinalStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.accentAmber, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.exo2(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.exo2(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.accentAmber,
          ),
        ),
      ],
    );
  }
}

class _ReplayPainter extends CustomPainter {
  final ReplayFrame currentFrame;
  final List<ReplayFrame> allFrames;
  final int currentIndex;

  _ReplayPainter({
    required this.currentFrame,
    required this.allFrames,
    required this.currentIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw trail (last 30 frames)
    _drawTrail(canvas, size);

    // Draw balloon at current position
    _drawBalloon(canvas, size);

    // Draw pressure gauge around balloon
    _drawPressureGauge(canvas, size);
  }

  void _drawTrail(Canvas canvas, Size size) {
    if (allFrames.length < 2) return;

    final trailPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Draw last 30 frames as a trail
    final startIndex = math.max(0, currentIndex - 30);
    for (int i = startIndex; i < currentIndex; i++) {
      final frame = allFrames[i];
      final normalizedPos = Offset(
        frame.balloonPosition.x / 800 * size.width,
        frame.balloonPosition.y / 1200 * size.height,
      );

      final alpha = ((i - startIndex) / 30).clamp(0.0, 1.0);
      trailPaint.color = Colors.white.withOpacity(alpha * 0.3);

      if (i > startIndex) {
        final prevFrame = allFrames[i - 1];
        final prevPos = Offset(
          prevFrame.balloonPosition.x / 800 * size.width,
          prevFrame.balloonPosition.y / 1200 * size.height,
        );
        canvas.drawLine(prevPos, normalizedPos, trailPaint);
      }
    }
  }

  void _drawBalloon(Canvas canvas, Size size) {
    final normalizedPos = Offset(
      currentFrame.balloonPosition.x / 800 * size.width,
      currentFrame.balloonPosition.y / 1200 * size.height,
    );

    final pressure = currentFrame.pressure;
    final balloonSize = 20 + (pressure / 100 * 10);

    // Balloon shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(
      normalizedPos.translate(2, 2),
      balloonSize,
      shadowPaint,
    );

    // Balloon body
    final balloonPaint = Paint()
      ..color = _getBalloonColor(pressure)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(normalizedPos, balloonSize, balloonPaint);

    // Balloon highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      normalizedPos.translate(-balloonSize * 0.3, -balloonSize * 0.3),
      balloonSize * 0.4,
      highlightPaint,
    );
  }

  void _drawPressureGauge(Canvas canvas, Size size) {
    final normalizedPos = Offset(
      currentFrame.balloonPosition.x / 800 * size.width,
      currentFrame.balloonPosition.y / 1200 * size.height,
    );

    final pressure = currentFrame.pressure;
    final gaugeRadius = 35.0;

    // Background ring
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(normalizedPos, gaugeRadius, bgPaint);

    // Pressure arc
    final arcPaint = Paint()
      ..color = _getPressureColor(pressure)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (pressure / 100) * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: normalizedPos, radius: gaugeRadius),
      -math.pi / 2,
      sweepAngle,
      false,
      arcPaint,
    );
  }

  Color _getBalloonColor(double pressure) {
    if (pressure < 40) return Colors.blue;
    if (pressure < 70) return Colors.green;
    if (pressure < 85) return Colors.yellow;
    return Colors.red;
  }

  Color _getPressureColor(double pressure) {
    if (pressure < 40) return AppColors.pressureLow;
    if (pressure < 70) return AppColors.pressureOptimal;
    if (pressure < 85) return AppColors.pressureHigh;
    return AppColors.pressureCritical;
  }

  @override
  bool shouldRepaint(_ReplayPainter oldDelegate) {
    return currentIndex != oldDelegate.currentIndex;
  }
}
