import 'package:flutter/foundation.dart';
import 'dart:collection';

/// Performance monitoring system to track FPS, memory, and game metrics
class PerformanceMonitor {
  static final PerformanceMonitor instance = PerformanceMonitor._();
  PerformanceMonitor._();

  // Frame timing
  final Queue<double> _frameTimes = Queue<double>();
  final int _maxFrameSamples = 60;
  
  // Counters
  int _totalFrames = 0;
  int _droppedFrames = 0;
  double _totalGameTime = 0;
  
  // Component counts
  int _activeComponents = 0;
  int _activeCollisions = 0;
  int _activeParticles = 0;
  
  // Performance thresholds
  static const double targetFrameTime = 16.67; // 60 FPS
  static const double droppedFrameThreshold = 33.33; // < 30 FPS
  
  /// Update frame timing
  void recordFrame(double dt) {
    _totalFrames++;
    _totalGameTime += dt;
    
    final frameTimeMs = dt * 1000;
    _frameTimes.add(frameTimeMs);
    
    if (_frameTimes.length > _maxFrameSamples) {
      _frameTimes.removeFirst();
    }
    
    // Check for dropped frames
    if (frameTimeMs > droppedFrameThreshold) {
      _droppedFrames++;
    }
  }
  
  /// Update component counts
  void updateCounts({
    required int components,
    required int collisions,
    required int particles,
  }) {
    _activeComponents = components;
    _activeCollisions = collisions;
    _activeParticles = particles;
  }
  
  /// Get current FPS
  double get fps {
    if (_frameTimes.isEmpty) return 0;
    final avgFrameTime = _frameTimes.reduce((a, b) => a + b) / _frameTimes.length;
    return avgFrameTime > 0 ? 1000 / avgFrameTime : 0;
  }
  
  /// Get average frame time in milliseconds
  double get avgFrameTime {
    if (_frameTimes.isEmpty) return 0;
    return _frameTimes.reduce((a, b) => a + b) / _frameTimes.length;
  }
  
  /// Get min frame time in milliseconds
  double get minFrameTime {
    if (_frameTimes.isEmpty) return 0;
    return _frameTimes.reduce((a, b) => a < b ? a : b);
  }
  
  /// Get max frame time in milliseconds
  double get maxFrameTime {
    if (_frameTimes.isEmpty) return 0;
    return _frameTimes.reduce((a, b) => a > b ? a : b);
  }
  
  /// Get dropped frame percentage
  double get droppedFramePercentage {
    return _totalFrames > 0 ? (_droppedFrames / _totalFrames) * 100 : 0;
  }
  
  /// Check if performance is good
  bool get isPerformanceGood => fps >= 55;
  
  /// Check if performance is acceptable
  bool get isPerformanceAcceptable => fps >= 30;
  
  /// Get performance report
  Map<String, dynamic> getReport() {
    return {
      'fps': fps.toStringAsFixed(1),
      'avgFrameTime': avgFrameTime.toStringAsFixed(2),
      'minFrameTime': minFrameTime.toStringAsFixed(2),
      'maxFrameTime': maxFrameTime.toStringAsFixed(2),
      'totalFrames': _totalFrames,
      'droppedFrames': _droppedFrames,
      'droppedPercentage': droppedFramePercentage.toStringAsFixed(2),
      'totalGameTime': _totalGameTime.toStringAsFixed(2),
      'activeComponents': _activeComponents,
      'activeCollisions': _activeCollisions,
      'activeParticles': _activeParticles,
      'performanceStatus': isPerformanceGood
          ? 'Good'
          : isPerformanceAcceptable
              ? 'Acceptable'
              : 'Poor',
    };
  }
  
  /// Print performance report to console
  void printReport() {
    if (!kDebugMode) return;
    
    final report = getReport();
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('📊 Performance Report');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('FPS: ${report['fps']} (${report['performanceStatus']})');
    debugPrint('Frame Time: ${report['avgFrameTime']}ms (min: ${report['minFrameTime']}ms, max: ${report['maxFrameTime']}ms)');
    debugPrint('Dropped Frames: ${report['droppedFrames']} (${report['droppedPercentage']}%)');
    debugPrint('Total Frames: ${report['totalFrames']}');
    debugPrint('Game Time: ${report['totalGameTime']}s');
    debugPrint('Active Components: ${report['activeComponents']}');
    debugPrint('Active Collisions: ${report['activeCollisions']}');
    debugPrint('Active Particles: ${report['activeParticles']}');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }
  
  /// Reset all metrics
  void reset() {
    _frameTimes.clear();
    _totalFrames = 0;
    _droppedFrames = 0;
    _totalGameTime = 0;
    _activeComponents = 0;
    _activeCollisions = 0;
    _activeParticles = 0;
  }
  
  /// Get recommendations for performance improvement
  List<String> getRecommendations() {
    final recommendations = <String>[];
    
    if (!isPerformanceGood) {
      if (_activeParticles > 100) {
        recommendations.add('Reduce particle count (current: $_activeParticles)');
      }
      
      if (_activeComponents > 100) {
        recommendations.add('Too many active components (current: $_activeComponents)');
      }
      
      if (maxFrameTime > 50) {
        recommendations.add('Frame spikes detected - check for expensive operations');
      }
      
      if (droppedFramePercentage > 10) {
        recommendations.add('High frame drop rate - consider reducing visual effects');
      }
    }
    
    return recommendations;
  }
}
