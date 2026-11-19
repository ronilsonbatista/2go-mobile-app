import 'package:flutter/material.dart';

/// Illustrated hero for the "Gerando seu roteiro…" loading screen.
///
/// Soft circle + globe + sparkles with a gentle globe breathe and sparkle pulse.
class GerandoRoteiroHero extends StatefulWidget {
  const GerandoRoteiroHero({super.key, this.size = 220});

  final double size;

  static const package = 'twogo_planning';
  static const circleLight = 'assets/gerando/circle-light.png';
  static const circleWhite = 'assets/gerando/circle-white.png';
  static const globe = 'assets/gerando/globe.png';
  static const sparkles = 'assets/gerando/sparkles.png';

  @override
  State<GerandoRoteiroHero> createState() => _GerandoRoteiroHeroState();
}

class _GerandoRoteiroHeroState extends State<GerandoRoteiroHero>
    with TickerProviderStateMixin {
  late final AnimationController _globeController;
  late final AnimationController _sparkleController;
  late final Animation<double> _globeScale;
  late final Animation<double> _globeOpacity;
  late final Animation<double> _sparkleScale;
  late final Animation<double> _sparkleOpacity;

  @override
  void initState() {
    super.initState();
    _globeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _globeScale = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _globeController, curve: Curves.easeInOut),
    );
    _globeOpacity = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _globeController, curve: Curves.easeInOut),
    );
    _sparkleScale = Tween<double>(begin: 0.86, end: 1.12).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.easeInOut),
    );
    _sparkleOpacity = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _globeController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    return Semantics(
      label: 'Gerando seu roteiro',
      child: SizedBox(
        width: size,
        height: size,
        child: AnimatedBuilder(
          animation: Listenable.merge([_globeController, _sparkleController]),
          builder: (context, _) {
            return Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Image.asset(
                  GerandoRoteiroHero.circleLight,
                  package: GerandoRoteiroHero.package,
                  width: size,
                  height: size,
                  fit: BoxFit.contain,
                ),
                Image.asset(
                  GerandoRoteiroHero.circleWhite,
                  package: GerandoRoteiroHero.package,
                  width: size * 0.72,
                  height: size * 0.72,
                  fit: BoxFit.contain,
                ),
                Opacity(
                  opacity: _globeOpacity.value,
                  child: Transform.scale(
                    scale: _globeScale.value,
                    child: Image.asset(
                      GerandoRoteiroHero.globe,
                      package: GerandoRoteiroHero.package,
                      width: size * 0.42,
                      height: size * 0.55,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Positioned(
                  top: size * 0.18,
                  right: size * 0.18,
                  child: Opacity(
                    opacity: _sparkleOpacity.value,
                    child: Transform.scale(
                      scale: _sparkleScale.value,
                      child: Image.asset(
                        GerandoRoteiroHero.sparkles,
                        package: GerandoRoteiroHero.package,
                        width: size * 0.22,
                        height: size * 0.18,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
