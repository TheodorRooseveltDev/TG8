import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/game_constants.dart';
import '../../data/repositories/game_repository.dart';
import 'game_screen.dart';

class PlaneSelectionScreen extends StatefulWidget {
  const PlaneSelectionScreen({super.key});

  @override
  State<PlaneSelectionScreen> createState() => _PlaneSelectionScreenState();
}

class _PlaneSelectionScreenState extends State<PlaneSelectionScreen> {
  final GameRepository _repository = GameRepository();
  List<PlaneType> _unlockedPlanes = [];
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  int _airTokens = 0;
  bool _isLoading = true;

  final List<PlaneType> _allPlanes = [
    PlaneType.standard,
    PlaneType.foil,
    PlaneType.hydrogen,
    PlaneType.cluster,
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
    final unlocked = await _repository.getUnlockedPlanes();
    final tokens = await _repository.getAirTokens();
    
    setState(() {
      _unlockedPlanes = unlocked;
      _airTokens = tokens;
      _isLoading = false;
    });
  }

  Future<void> _unlockPlane(PlaneType type, int cost) async {
    if (_airTokens < cost) return;
    
    // Deduct tokens
    await _repository.saveAirTokens(_airTokens - cost);
    
    // Unlock plane
    _unlockedPlanes.add(type);
    await _repository.saveUnlockedPlanes(_unlockedPlanes);
    
    // Reload data
    await _loadData();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✨ ${_getPlaneName(type)} unlocked!'),
          backgroundColor: AppColors.accentAmber,
        ),
      );
    }
  }

  String _getPlaneName(PlaneType type) {
    switch (type) {
      case PlaneType.standard:
        return 'BASIC PLANE';
      case PlaneType.foil:
      case PlaneType.fighter:
        return 'SOPWITH CAMEL';
      case PlaneType.hydrogen:
      case PlaneType.jet:
        return 'P-51 MUSTANG';
      case PlaneType.cluster:
      case PlaneType.cargo:
        return 'F-35 LIGHTNING';
    }
  }

  String _getPlaneDescription(PlaneType type) {
    switch (type) {
      case PlaneType.standard:
        return 'Balanced performance • Easy to fly';
      case PlaneType.foil:
      case PlaneType.fighter:
        return 'WWI Biplane • High control & stability';
      case PlaneType.hydrogen:
      case PlaneType.jet:
        return 'WWII Fighter • Super fast & agile';
      case PlaneType.cluster:
      case PlaneType.cargo:
        return 'Modern Jet • High durability';
    }
  }

  int _getUnlockCost(PlaneType type) {
    switch (type) {
      case PlaneType.standard:
        return 0;
      case PlaneType.foil:
      case PlaneType.fighter:
        return 500;
      case PlaneType.hydrogen:
      case PlaneType.jet:
        return 1000;
      case PlaneType.cluster:
      case PlaneType.cargo:
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
                        'AIRCRAFT',
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
              
              // Planes Display - Swipeable PageView
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
                          
                          // Plane name - BIG at top
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              _getPlaneName(_allPlanes[_currentIndex]),
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
                          
                          // PageView with planes - SWIPEABLE
                          Expanded(
                            flex: 3,
                            child: PageView.builder(
                              controller: _pageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentIndex = index;
                                });
                              },
                              itemCount: _allPlanes.length,
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
                                          child: _PlaneImage(
                                            type: _allPlanes[index],
                                            isUnlocked: _unlockedPlanes.contains(_allPlanes[index]) ||
                                                _allPlanes[index] == PlaneType.standard,
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
                                      _getPlaneDescription(_allPlanes[_currentIndex]),
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
                                        child: _unlockedPlanes.contains(_allPlanes[_currentIndex]) ||
                                            _allPlanes[_currentIndex] == PlaneType.standard
                                          ? _StatsDisplayHorizontal(type: _allPlanes[_currentIndex])
                                          : _UnlockButton(
                                              cost: _getUnlockCost(_allPlanes[_currentIndex]),
                                              canAfford: _airTokens >= _getUnlockCost(_allPlanes[_currentIndex]),
                                              onPressed: () => _unlockPlane(
                                                _allPlanes[_currentIndex],
                                                _getUnlockCost(_allPlanes[_currentIndex]),
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
                              _allPlanes.length,
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
                  isEnabled: _unlockedPlanes.contains(_allPlanes[_currentIndex]) ||
                      _allPlanes[_currentIndex] == PlaneType.standard,
                  onPressed: () {
                    // Return to menu with selected plane and start game
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GameScreen(
                          selectedPlaneType: _allPlanes[_currentIndex],
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

// Plane image widget
class _PlaneImage extends StatelessWidget {
  final PlaneType type;
  final bool isUnlocked;

  const _PlaneImage({
    required this.type,
    required this.isUnlocked,
  });

  String _getPlaneImage(PlaneType type) {
    switch (type) {
      case PlaneType.standard:
        return 'assets/images/planes/standart_plane.png'; // Note: keeping original typo from asset filename
      case PlaneType.foil:
      case PlaneType.fighter:
        return 'assets/images/planes/sopwith_plane.png'; // WWI biplane
      case PlaneType.hydrogen:
      case PlaneType.jet:
        return 'assets/images/planes/p-51.png'; // WWII fighter
      case PlaneType.cluster:
      case PlaneType.cargo:
        return 'assets/images/planes/f-35.png'; // Modern jet
    }
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _getPlaneImage(type),
      height: 300,
      fit: BoxFit.contain,
    );
  }
}

// Horizontal stats display - cleaner
class _StatsDisplayHorizontal extends StatelessWidget {
  final PlaneType type;

  const _StatsDisplayHorizontal({required this.type});

  @override
  Widget build(BuildContext context) {
    final stats = GameConstants.planeStats[type.name]!;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatColumn(label: 'SPEED', emoji: '⚡', value: stats['speed']!),
          _StatColumn(label: 'CONTROL', emoji: '🎮', value: stats['control']!),
          _StatColumn(label: 'AGILITY', emoji: '✈️', value: stats['agility']!),
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
