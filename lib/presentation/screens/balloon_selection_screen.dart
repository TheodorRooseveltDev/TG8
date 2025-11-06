import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/game_constants.dart';
import '../../data/repositories/game_repository.dart';
import 'game_screen.dart';

class BalloonSelectionScreen extends StatefulWidget {
  const BalloonSelectionScreen({super.key});

  @override
  State<BalloonSelectionScreen> createState() => _BalloonSelectionScreenState();
}

class _BalloonSelectionScreenState extends State<BalloonSelectionScreen> {
  final GameRepository _repository = GameRepository();
  List<BalloonType> _unlockedBalloons = [];
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  int _airTokens = 0;
  bool _isLoading = true;

  final List<BalloonType> _allBalloons = [
    BalloonType.standard,
    BalloonType.foil,
    BalloonType.hydrogen,
    BalloonType.cluster,
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final unlocked = await _repository.getUnlockedBalloons();
    final tokens = await _repository.getAirTokens();
    
    setState(() {
      _unlockedBalloons = unlocked;
      _airTokens = tokens;
      _isLoading = false;
    });
  }

  Future<void> _unlockBalloon(BalloonType type, int cost) async {
    if (_airTokens < cost) return;
    
    // Deduct tokens
    await _repository.saveAirTokens(_airTokens - cost);
    
    // Unlock balloon
    _unlockedBalloons.add(type);
    await _repository.saveUnlockedBalloons(_unlockedBalloons);
    
    // Reload data
    await _loadData();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✨ ${_getBalloonName(type)} unlocked!'),
          backgroundColor: AppColors.accentAmber,
        ),
      );
    }
  }

  String _getBalloonName(BalloonType type) {
    switch (type) {
      case BalloonType.standard:
        return 'BASIC PLANE';
      case BalloonType.foil:
      case BalloonType.fighter:
        return 'SOPWITH CAMEL';
      case BalloonType.hydrogen:
      case BalloonType.jet:
        return 'P-51 MUSTANG';
      case BalloonType.cluster:
      case BalloonType.cargo:
        return 'F-35 LIGHTNING';
    }
  }

  String _getBalloonDescription(BalloonType type) {
    switch (type) {
      case BalloonType.standard:
        return 'Balanced performance • Easy to fly';
      case BalloonType.foil:
      case BalloonType.fighter:
        return 'WWI Biplane • High control & stability';
      case BalloonType.hydrogen:
      case BalloonType.jet:
        return 'WWII Fighter • Super fast & agile';
      case BalloonType.cluster:
      case BalloonType.cargo:
        return 'Modern Jet • High durability';
    }
  }

  int _getUnlockCost(BalloonType type) {
    switch (type) {
      case BalloonType.standard:
        return 0;
      case BalloonType.foil:
      case BalloonType.fighter:
        return 500;
      case BalloonType.hydrogen:
      case BalloonType.jet:
        return 1000;
      case BalloonType.cluster:
      case BalloonType.cargo:
        return 1500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full screen background image - scaled
          Positioned.fill(
            child: Transform.scale(
              scale: 1.5,
              child: Image.asset(
                'assets/images/ui/menu_background.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content on top
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/ui/button_normal.png'),
                              fit: BoxFit.fill,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'BALLOONS',
                        style: GoogleFonts.russoOne(
                          fontSize: 32,
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
                      const Spacer(),
                      // Air Tokens display
                      Container(
                        width: 140,
                        height: 60,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/ui/button_normal.png'),
                            fit: BoxFit.fill,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.monetization_on,
                              color: Colors.amber,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$_airTokens',
                              style: GoogleFonts.russoOne(
                                fontSize: 16,
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
                    ],
                  ),
                ),
              
              // Balloons Display - Swipeable PageView
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accentAmber,
                        ),
                      )
                    : Column(
                        children: [
                          const SizedBox(height: 20),
                          
                          // Balloon name - BIG at top
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              _getBalloonName(_allBalloons[_currentIndex]),
                              key: ValueKey(_currentIndex),
                              style: GoogleFonts.russoOne(
                                fontSize: 40,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.8),
                                    offset: const Offset(3, 3),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 10),
                          
                          // PageView with balloons - SWIPEABLE
                          Expanded(
                            flex: 3,
                            child: PageView.builder(
                              controller: _pageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentIndex = index;
                                });
                              },
                              itemCount: _allBalloons.length,
                              itemBuilder: (context, index) {
                                return AnimatedBuilder(
                                  animation: _pageController,
                                  builder: (context, child) {
                                    double value = 1.0;
                                    if (_pageController.position.haveDimensions) {
                                      value = _pageController.page! - index;
                                      value = (1 - (value.abs() * 0.3)).clamp(0.7, 1.0);
                                    }
                                    return Center(
                                      child: Transform.scale(
                                        scale: value,
                                        child: Opacity(
                                          opacity: value,
                                          child: _BalloonImage(
                                            type: _allBalloons[index],
                                            isUnlocked: _unlockedBalloons.contains(_allBalloons[index]) ||
                                                _allBalloons[index] == BalloonType.standard,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          
                          // Description & Stats in dialogue box
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 30),
                              child: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage('assets/images/ui/dialogue_box.png'),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Description
                                    Text(
                                      _getBalloonDescription(_allBalloons[_currentIndex]),
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.exo2(
                                        fontSize: 14,
                                        color: Colors.white,
                                        height: 1.4,
                                      ),
                                    ),
                                    
                                    const SizedBox(height: 16),
                                    
                                    // Stats or unlock button - same height for both
                                    SizedBox(
                                      height: 90,
                                      child: Center(
                                        child: _unlockedBalloons.contains(_allBalloons[_currentIndex]) ||
                                            _allBalloons[_currentIndex] == BalloonType.standard
                                          ? _StatsDisplayHorizontal(type: _allBalloons[_currentIndex])
                                          : _UnlockButton(
                                              cost: _getUnlockCost(_allBalloons[_currentIndex]),
                                              canAfford: _airTokens >= _getUnlockCost(_allBalloons[_currentIndex]),
                                              onPressed: () => _unlockBalloon(
                                                _allBalloons[_currentIndex],
                                                _getUnlockCost(_allBalloons[_currentIndex]),
                                              ),
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Page indicators
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _allBalloons.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: index == _currentIndex ? 24 : 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: index == _currentIndex
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.3),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                        ],
                      ),
              ),
              
              // Select Button
              Padding(
                padding: const EdgeInsets.all(20),
                child: _SelectButton(
                  isEnabled: _unlockedBalloons.contains(_allBalloons[_currentIndex]) ||
                      _allBalloons[_currentIndex] == BalloonType.standard,
                  onPressed: () {
                    // Return to menu with selected balloon and start game
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GameScreen(
                          selectedPlaneType: _allBalloons[_currentIndex],
                        ),
                      ),
                    );
                  },
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

// Balloon image widget
class _BalloonImage extends StatelessWidget {
  final BalloonType type;
  final bool isUnlocked;

  const _BalloonImage({
    required this.type,
    required this.isUnlocked,
  });

  String _getBalloonImage(BalloonType type) {
    switch (type) {
      case BalloonType.standard:
        return 'assets/images/balloons/standart_balloon.png';
      case BalloonType.foil:
      case BalloonType.fighter:
        return 'assets/images/balloons/foil_balloon.png';
      case BalloonType.hydrogen:
      case BalloonType.jet:
        return 'assets/images/balloons/hydrogen_balloon.png';
      case BalloonType.cluster:
      case BalloonType.cargo:
        return 'assets/images/balloons/cluster_balloon.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _getBalloonImage(type),
      height: 300,
      fit: BoxFit.contain,
    );
  }
}

// Horizontal stats display - cleaner
class _StatsDisplayHorizontal extends StatelessWidget {
  final BalloonType type;

  const _StatsDisplayHorizontal({required this.type});

  @override
  Widget build(BuildContext context) {
    final stats = GameConstants.balloonStats[type.name]!;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatColumn(label: 'SPEED', emoji: '⚡', value: stats['speed']!),
          _StatColumn(label: 'CONTROL', emoji: '🎮', value: stats['control']!),
          _StatColumn(label: 'ELASTIC', emoji: '💪', value: stats['elasticity']!),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String emoji;
  final double value;

  const _StatColumn({
    required this.label,
    required this.emoji,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final barCount = (value * 5).round(); // 0-5 bars
    
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 4),
        // Vertical bars
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(
            5,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              width: 8,
              height: 30,
              decoration: BoxDecoration(
                color: index < barCount
                    ? AppColors.accentAmber
                    : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.exo2(
            fontSize: 10,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _SelectButton extends StatefulWidget {
  final bool isEnabled;
  final VoidCallback onPressed;

  const _SelectButton({
    required this.isEnabled,
    required this.onPressed,
  });

  @override
  State<_SelectButton> createState() => _SelectButtonState();
}

class _SelectButtonState extends State<_SelectButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.isEnabled ? (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      } : null,
      onTapCancel: () => setState(() => _isPressed = false),
      child: Container(
        width: 250,
        height: 120,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              widget.isEnabled
                  ? (_isPressed
                      ? 'assets/images/ui/button_pressed.png'
                      : 'assets/images/ui/button_normal.png')
                  : 'assets/images/ui/button_normal.png',
            ),
            fit: BoxFit.fill,
            colorFilter: widget.isEnabled
                ? null
                : ColorFilter.mode(
                    Colors.grey.withOpacity(0.5),
                    BlendMode.srcATop,
                  ),
          ),
        ),
        child: Center(
          child: Text(
            'SELECT',
            style: GoogleFonts.russoOne(
              fontSize: 24,
              color: widget.isEnabled ? Colors.white : Colors.grey,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.8),
                  offset: const Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UnlockButton extends StatefulWidget {
  final int cost;
  final bool canAfford;
  final VoidCallback onPressed;

  const _UnlockButton({
    required this.cost,
    required this.canAfford,
    required this.onPressed,
  });

  @override
  State<_UnlockButton> createState() => _UnlockButtonState();
}

class _UnlockButtonState extends State<_UnlockButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.canAfford ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.canAfford ? (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      } : null,
      onTapCancel: () => setState(() => _isPressed = false),
      child: Container(
        width: 180,
        height: 60,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              widget.canAfford
                  ? (_isPressed
                      ? 'assets/images/ui/button_pressed.png'
                      : 'assets/images/ui/button_normal.png')
                  : 'assets/images/ui/button_normal.png',
            ),
            fit: BoxFit.fill,
            colorFilter: widget.canAfford
                ? null
                : ColorFilter.mode(
                    Colors.grey.withOpacity(0.5),
                    BlendMode.srcATop,
                  ),
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.monetization_on,
                color: Colors.amber,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '${widget.cost}',
                style: GoogleFonts.russoOne(
                  fontSize: 18,
                  color: widget.canAfford ? Colors.white : Colors.grey,
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
