import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/upgrade_data.dart';
import '../../data/repositories/game_repository.dart';

class UpgradeScreen extends ConsumerStatefulWidget {
  const UpgradeScreen({super.key});

  @override
  ConsumerState<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends ConsumerState<UpgradeScreen> {
  final GameRepository _repository = GameRepository();
  int _airTokens = 0;
  List<UpgradeData> _upgrades = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final tokens = await _repository.getAirTokens();
    final upgrades = await _repository.getUpgrades();
    
    setState(() {
      _airTokens = tokens;
      _upgrades = upgrades;
      _isLoading = false;
    });
  }

  Future<void> _purchaseUpgrade(UpgradeData upgrade) async {
    if (_airTokens < upgrade.cost || upgrade.isMaxLevel) return;
    
    // Deduct tokens
    final newTokens = _airTokens - upgrade.cost;
    await _repository.saveAirTokens(newTokens);
    
    // Upgrade level
    final upgradedList = _upgrades.map((u) {
      if (u.type == upgrade.type) {
        return u.copyWith(
          level: u.level + 1,
          cost: (u.cost * 1.5).toInt(), // Increase cost for next level
        );
      }
      return u;
    }).toList();
    
    await _repository.saveUpgrades(upgradedList);
    
    // Reload data
    await _loadData();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✨ ${upgrade.name} upgraded to level ${upgrade.level + 1}!'),
          backgroundColor: AppColors.primaryBrass,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full screen background image
          Positioned.fill(
            child: Transform.scale(
              scale: 1.5,
              child: Image.asset(
                'assets/images/ui/menu_background.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
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
                            size: 24,
                          ),
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Title
                      Text(
                        'UPGRADES',
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
                      
                      // Air tokens display
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
                
                // Upgrades list
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.accentAmber,
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          itemCount: _upgrades.length,
                          itemBuilder: (context, index) {
                            final upgrade = _upgrades[index];
                            return _UpgradeCard(
                              upgrade: upgrade,
                              airTokens: _airTokens,
                              onPurchase: () => _purchaseUpgrade(upgrade),
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

// Upgrade card widget
class _UpgradeCard extends StatefulWidget {
  final UpgradeData upgrade;
  final int airTokens;
  final VoidCallback onPurchase;

  const _UpgradeCard({
    required this.upgrade,
    required this.airTokens,
    required this.onPurchase,
  });

  @override
  State<_UpgradeCard> createState() => _UpgradeCardState();
}

class _UpgradeCardState extends State<_UpgradeCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final canAfford = widget.airTokens >= widget.upgrade.cost;
    final isMaxLevel = widget.upgrade.isMaxLevel;
    final isEnabled = canAfford && !isMaxLevel;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/ui/dialogue_box.png'),
          fit: BoxFit.fill,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          
          // Title and description - centered
          Column(
            children: [
              Text(
                widget.upgrade.name.toUpperCase(),
                textAlign: TextAlign.center,
                style: GoogleFonts.russoOne(
                  fontSize: 18,
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
              const SizedBox(height: 6),
              Text(
                widget.upgrade.description,
                textAlign: TextAlign.center,
                style: GoogleFonts.exo2(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.75),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 14),
          
          // Level progress - narrower width
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'LEVEL ${widget.upgrade.level}/${widget.upgrade.maxLevel}',
                      style: GoogleFonts.russoOne(
                        fontSize: 13,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.8),
                            offset: const Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    if (isMaxLevel)
                      Text(
                        '✓ MAXED',
                        style: GoogleFonts.russoOne(
                          fontSize: 12,
                          color: Colors.green,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.8),
                              offset: const Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: widget.upgrade.level / widget.upgrade.maxLevel,
                    minHeight: 14,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentAmber),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 14),
          
          // Upgrade button - centered and reasonable size
          Center(
            child: GestureDetector(
              onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
              onTapUp: isEnabled ? (_) {
                setState(() => _isPressed = false);
                widget.onPurchase();
              } : null,
              onTapCancel: () => setState(() => _isPressed = false),
              child: Container(
                width: 240,
                height: 56,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      isEnabled
                          ? (_isPressed
                              ? 'assets/images/ui/button_pressed.png'
                              : 'assets/images/ui/button_normal.png')
                          : 'assets/images/ui/button_normal.png',
                    ),
                    fit: BoxFit.fill,
                    colorFilter: isEnabled
                        ? null
                        : ColorFilter.mode(
                            Colors.grey.withOpacity(0.5),
                            BlendMode.srcATop,
                          ),
                  ),
                ),
                child: Center(
                  child: isMaxLevel
                      ? Text(
                          '✓ MAX LEVEL',
                          style: GoogleFonts.russoOne(
                            fontSize: 14,
                            color: Colors.green,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.8),
                                offset: const Offset(2, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'UPGRADE',
                              style: GoogleFonts.russoOne(
                                fontSize: 14,
                                color: isEnabled ? Colors.white : Colors.grey,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.8),
                                    offset: const Offset(2, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.monetization_on,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.upgrade.cost}',
                              style: GoogleFonts.russoOne(
                                fontSize: 14,
                                color: isEnabled ? Colors.white : Colors.grey,
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
            ),
          ),
        ],
      ),
    );
  }
}
