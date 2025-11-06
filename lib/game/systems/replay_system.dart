import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../balloon_twist_game.dart';
import 'dart:collection';

/// Records and replays player movement for post-failure analysis
class ReplaySystem extends Component with HasGameRef<AviaRollHighGame> {
  static const int maxRecordingSeconds = 10;
  static const int recordingsPerSecond = 30; // 30 FPS recording
  static const int maxFrames = maxRecordingSeconds * recordingsPerSecond;
  
  final Queue<ReplayFrame> _frames = Queue<ReplayFrame>();
  bool _isRecording = true;
  bool _isReplaying = false;
  double _replayTimer = 0;
  int _currentReplayFrame = 0;
  
  @override
  void update(double dt) {
    super.update(dt);
    
    if (_isRecording && !gameRef.isGameOver) {
      _recordFrame();
    } else if (_isReplaying) {
      _updateReplay(dt);
    }
  }
  
  void _recordFrame() {
    // Record current game state
    final frame = ReplayFrame(
      balloonPosition: gameRef.balloonPosition,
      pressure: gameRef.balloonPressure,
      speed: gameRef.gameSpeed,
      timestamp: DateTime.now(),
    );
    
    _frames.add(frame);
    
    // Keep only last N frames
    if (_frames.length > maxFrames) {
      _frames.removeFirst();
    }
  }
  
  void startReplay() {
    _isRecording = false;
    _isReplaying = true;
    _replayTimer = 0;
    _currentReplayFrame = 0;
    debugPrint('🎬 Starting replay with ${_frames.length} frames');
  }
  
  void _updateReplay(double dt) {
    _replayTimer += dt;
    
    final frameTime = 1.0 / recordingsPerSecond;
    _currentReplayFrame = (_replayTimer / frameTime).floor();
    
    if (_currentReplayFrame >= _frames.length) {
      stopReplay();
    }
  }
  
  void stopReplay() {
    _isReplaying = false;
    _currentReplayFrame = 0;
    debugPrint('⏹️ Replay stopped');
  }
  
  void reset() {
    _frames.clear();
    _isRecording = true;
    _isReplaying = false;
    _replayTimer = 0;
    _currentReplayFrame = 0;
  }
  
  ReplayFrame? get currentFrame {
    if (_isReplaying && _currentReplayFrame < _frames.length) {
      return _frames.elementAt(_currentReplayFrame);
    }
    return null;
  }
  
  List<ReplayFrame> getAllFrames() {
    return _frames.toList();
  }
  
  bool get isReplaying => _isReplaying;
  int get totalFrames => _frames.length;
  int get currentFrameIndex => _currentReplayFrame;
}

/// Single frame of replay data
class ReplayFrame {
  final Vector2 balloonPosition;
  final double pressure;
  final double speed;
  final DateTime timestamp;
  
  ReplayFrame({
    required this.balloonPosition,
    required this.pressure,
    required this.speed,
    required this.timestamp,
  });
}
