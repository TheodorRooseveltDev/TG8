# AviaRoll High ✈️

An aviation-themed endless flight game built with Flutter and Flame engine. Pilot your plane through atmospheric layers, avoiding obstacles and managing fuel as you ascend from the ground to the edge of space!

## 🎮 Game Features

### Core Mechanics
- **Physics-Based Flight**: Natural plane ascent with drift, environmental airflow influence
- **Fuel Management**: Balance boost/consumption to maintain optimal fuel (40-70%)
- **Touch Controls**: 
  - Tap and hold to boost plane
  - Swipe left/right for horizontal movement
- **Dynamic Acceleration**: Game speed increases over time, reaching up to 400m/s

### Environmental Hazards
- **6 Obstacle Types**:
  - Rotating Fans (creates turbulence)
  - Buildings (sharp stationary)
  - Spikes (ceiling hazards)
  - Barbed Wire (horizontal barriers)
  - Fire hazards (heat causes fuel issues)
  - Storm Clouds (erratic wind patterns)

### Environmental Effects
- **Thermals**: Rising air currents that lift the plane
- **Dust Clouds**: Reduce visibility (rely on audio cues)
- **Electric Storms**: Disrupt physics with random force vectors

### Progression System
- **Vertical Biomes**: 
  - Ground Level (0-1000m)
  - Sky Zone (1000-3000m)
  - Stratosphere (3000-8000m)
  - Mesosphere (8000-15000m)
  - Deep Space (15000m+)
  
- **Checkpoints**: Air stations spawn every 500m to refill fuel
- **Collectibles**:
  - 💍 Air Rings: Award 10 tokens
  - ⚡ Fuel Boosters: +20% fuel
  - ⏰ Time Slowers: Slow-mo effect

### Upgrade System
- **4 Upgrade Paths** (10 levels each):
  - ✈️ **Maneuverability**: Increase aircraft agility and responsiveness
  - 🎮 **Precision Control**: Improve flight control precision
  - 💨 **Turbulence Handling**: Resist wind and environmental turbulence
  - ⚙️ **Fuel Efficiency**: Slower fuel consumption
- **Currency**: Earn Air Tokens (1 token per 10 points)
- **Persistent Progress**: Local storage with SharedPreferences

### Scoring & Combos
- **Distance-Based**: 10 points per meter traveled
- **Near-Miss Bonus**: 50 points (with 1.5x combo multiplier)
- **Checkpoint Bonus**: 100 points
- **Fuel Mastery**: Passive score gain in optimal zone

### Advanced Features
- **Procedural Generation**: Altitude-based spawning with difficulty scaling
- **Failure Modes**:
  - 💥 Crash (instant)
  - � Fuel depletion (gradual power loss)
  - 🪂 Out-of-Fuel Stall (uncontrolled descent)

## 🎨 Visual Style

**Aviation-Themed Aesthetic**:
- 60:30:10 color scheme (Brass #B8860B, Wood #3E2723, Amber #FFA726)
- Parallax scrolling backgrounds (3 layers)
- Soft volumetric lighting for airflow
- Minimal HUD with color-coded fuel gauge

## 🛠️ Technical Stack

- **Flutter SDK**: ^3.9.2
- **Flame Engine**: 1.18.0 (2D game framework)
- **State Management**: Riverpod 2.5.1
- **Typography**: Google Fonts (Bungee titles, Fredoka body)
- **Local Storage**: SharedPreferences + Hive 2.2.3
- **Audio**: AudioPlayers 6.0.0 + Flame Audio 2.1.7
- **Architecture**: Clean architecture, feature-based structure

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/      # Game constants, colors, asset paths
│   └── theme/          # App theme with Google Fonts
├── data/
│   ├── models/         # Upgrade data, game state models
│   └── repositories/   # Game repository for persistence
├── game/
│   ├── components/     # Plane, obstacles, collectibles, etc.
│   ├── systems/        # Spawners, combo system, environment
│   └── aviaroll_high_game.dart  # Main game class
└── presentation/
    ├── screens/        # Menu, game, upgrade screens
    └── widgets/        # Game over dialog, reusable UI components
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.9.2 or higher
- Dart 3.0+
- iOS Simulator / Android Emulator / Physical Device

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/aviaroll-high.git
cd aviaroll-high
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the game:
```bash
flutter run
```

### Controls
- **Tap & Hold**: Boost plane (increase speed)
- **Swipe Left/Right**: Move plane horizontally
- **Release**: Stop boosting (fuel decays naturally)

## 🎯 Game Tips

1. **Maintain Optimal Fuel** (40-70%): Green gauge = safe zone
2. **Use Checkpoints Wisely**: Refill fuel every 500m
3. **Risk vs Reward**: Fuel Boosters give points but increase risk
4. **Watch Your Speed**: Game accelerates over time - anticipate obstacles
5. **Upgrade Strategically**: Balance durability for survival vs control for precision

## 📊 Achievements & Statistics

Track your progress:
- High Score
- Total Distance Traveled
- Air Tokens Earned
- Games Played
- Highest Altitude Reached

## 📝 Roadmap

- [ ] Audio integration (wind ambience, engine sounds, music)
- [ ] Daily Winds Mode (global leaderboards with seeded wind patterns)
- [ ] Plane variants (Fighter, Jet, Cargo)
- [ ] Safe Zone Spin mini-wheel at checkpoints
- [ ] Boss levels with wind tunnel sequences
- [ ] Particle effects for visual polish
- [ ] Analytics and telemetry

## ⚠️ Known Issues

- Time Slower collectible effect not active
- Biome visual transitions need smoothing

## 📄 License

This project is licensed under the MIT License - see LICENSE file for details.

## 👨‍💻 Development

Built with ❤️ using Flutter & Flame

**Game Design**: Aviation-themed endless vertical scroller  
**Physics**: Custom plane flight model with fuel management  
**Architecture**: Clean architecture with feature-based organization  

---

**Happy Flying! ✈️✨**
