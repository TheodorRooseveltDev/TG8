export 'audio_manager.dart' show SoundEffect;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Audio manager for handling game sounds and music
class AudioManager {
  AudioManager._();
  
  static final AudioManager instance = AudioManager._();
  
  // Audio players
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _ambiencePlayer = AudioPlayer();
  
  // Volume settings
  double _musicVolume = 0.7;
  double _sfxVolume = 0.8;
  double _ambienceVolume = 0.5;
  
  bool _isMusicEnabled = true;
  bool _isSfxEnabled = true;
  
  // Getters
  bool get isMusicEnabled => _isMusicEnabled;
  bool get isSfxEnabled => _isSfxEnabled;
  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;
  double get ambienceVolume => _ambienceVolume;
  
  /// Initialize audio players
  Future<void> initialize() async {
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _ambiencePlayer.setReleaseMode(ReleaseMode.loop);
    
    await _musicPlayer.setVolume(_musicVolume);
    await _sfxPlayer.setVolume(_sfxVolume);
    await _ambiencePlayer.setVolume(_ambienceVolume);
    
    debugPrint('🔊 Audio Manager initialized');
  }
  
  /// Play background music
  Future<void> playMusic(String trackName) async {
    if (!_isMusicEnabled) return;
    
    try {
      await _musicPlayer.stop();
      // In production, use actual audio assets
      // await _musicPlayer.play(AssetSource('audio/music/$trackName.mp3'));
      debugPrint('🎵 Playing music: $trackName');
    } catch (e) {
      debugPrint('⚠️ Failed to play music: $e');
    }
  }
  
  /// Play ambient wind sound based on speed
  Future<void> playWindAmbience(double intensity) async {
    if (!_isMusicEnabled) return;
    
    try {
      final volume = (intensity * _ambienceVolume).clamp(0.0, 1.0);
      await _ambiencePlayer.setVolume(volume);
      
      // In production, use actual wind audio assets
      // if (_ambiencePlayer.state != PlayerState.playing) {
      //   await _ambiencePlayer.play(AssetSource('audio/ambience/wind.mp3'));
      // }
      debugPrint('💨 Wind ambience: ${(intensity * 100).toInt()}%');
    } catch (e) {
      debugPrint('⚠️ Failed to play wind ambience: $e');
    }
  }
  
  /// Stop ambient sounds
  Future<void> stopAmbience() async {
    await _ambiencePlayer.stop();
  }
  
  /// Play sound effect
  Future<void> playSfx(SoundEffect effect) async {
    if (!_isSfxEnabled) return;
    
    try {
      // In production, use actual audio assets
      // await _sfxPlayer.play(AssetSource('audio/sfx/${effect.fileName}'));
      debugPrint('🔊 SFX: ${effect.name}');
    } catch (e) {
      debugPrint('⚠️ Failed to play SFX: $e');
    }
  }
  
  /// Set music volume
  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume.clamp(0.0, 1.0);
    await _musicPlayer.setVolume(_musicVolume);
  }
  
  /// Set SFX volume
  Future<void> setSfxVolume(double volume) async {
    _sfxVolume = volume.clamp(0.0, 1.0);
    await _sfxPlayer.setVolume(_sfxVolume);
  }
  
  /// Set ambience volume
  Future<void> setAmbienceVolume(double volume) async {
    _ambienceVolume = volume.clamp(0.0, 1.0);
    await _ambiencePlayer.setVolume(_ambienceVolume);
  }
  
  /// Toggle music on/off
  void toggleMusic(bool enabled) {
    _isMusicEnabled = enabled;
    if (!enabled) {
      _musicPlayer.pause();
      _ambiencePlayer.pause();
    } else {
      _musicPlayer.resume();
      _ambiencePlayer.resume();
    }
  }
  
  /// Toggle SFX on/off
  void toggleSfx(bool enabled) {
    _isSfxEnabled = enabled;
  }
  
  /// Pause all audio
  Future<void> pauseAll() async {
    await _musicPlayer.pause();
    await _ambiencePlayer.pause();
  }
  
  /// Resume all audio
  Future<void> resumeAll() async {
    if (_isMusicEnabled) {
      await _musicPlayer.resume();
      await _ambiencePlayer.resume();
    }
  }
  
  /// Stop all audio
  Future<void> stopAll() async {
    await _musicPlayer.stop();
    await _sfxPlayer.stop();
    await _ambiencePlayer.stop();
  }
  
  /// Dispose audio players
  Future<void> dispose() async {
    await _musicPlayer.dispose();
    await _sfxPlayer.dispose();
    await _ambiencePlayer.dispose();
  }
}

/// Sound effect enumeration
enum SoundEffect {
  // Aircraft sounds (Aviation Theme)
  accelerate('inflate.mp3'), // Engine boost
  decelerate('deflate.mp3'), // Engine brake
  crash('burst.mp3'), // Crash/explosion
  damage('puncture.mp3'), // Take damage
  overspeed('pressure_high.mp3'), // Speed warning
  lowFuel('pressure_low.mp3'), // Low fuel warning
  
  // Legacy sound aliases (deprecated - audio files reused)
  @Deprecated('Use accelerate instead')
  inflate('inflate.mp3'),
  @Deprecated('Use decelerate instead')
  deflate('deflate.mp3'),
  @Deprecated('Use crash instead')
  burst('burst.mp3'),
  @Deprecated('Use damage instead')
  puncture('puncture.mp3'),
  @Deprecated('Use overspeed instead')
  pressureHigh('pressure_high.mp3'),
  @Deprecated('Use lowFuel instead')
  pressureLow('pressure_low.mp3'),
  
  // Collectibles
  collectRing('collect_ring.mp3'),
  collectBooster('collect_booster.mp3'),
  collectSlower('collect_slower.mp3'),
  checkpoint('checkpoint.mp3'),
  
  // Obstacles
  hitObstacle('hit_obstacle.mp3'),
  nearMiss('near_miss.mp3'),
  
  // Environmental
  thermal('thermal.mp3'),
  electricStorm('electric_storm.mp3'),
  dustCloud('dust_cloud.mp3'),
  
  // UI
  buttonClick('button_click.mp3'),
  upgrade('upgrade.mp3'),
  achievement('achievement.mp3'),
  gameOver('game_over.mp3');
  
  const SoundEffect(this.fileName);
  final String fileName;
}
