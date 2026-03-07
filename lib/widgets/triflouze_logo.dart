import 'package:flutter/material.dart';
import '../theme/triflouze_theme.dart';

/// Icône carrée arrondie Triflouze
class TriflouzeIcon extends StatelessWidget {
  final double size;

  const TriflouzeIcon({super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo/icon.png',
      width: size,
      height: size,
    );
  }
}

/// Icône + texte "Triflouze" côte à côte
class TriflouzeWordmark extends StatelessWidget {
  final double iconSize;

  const TriflouzeWordmark({super.key, this.iconSize = 48});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TriflouzeIcon(size: iconSize),
        SizedBox(width: iconSize * 0.22),
        Text(
          'Triflouze',
          style: TextStyle(
            fontSize: iconSize * 0.60,
            fontWeight: FontWeight.w800,
            color: TriflouzeTheme.primary,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

/// Version verticale : icône au-dessus du nom (pour splash / login)
class TriflouzeLogoVertical extends StatelessWidget {
  final double iconSize;

  const TriflouzeLogoVertical({super.key, this.iconSize = 80});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TriflouzeIcon(size: iconSize),
        SizedBox(height: iconSize * 0.16),
        Text(
          'Triflouze',
          style: TextStyle(
            fontSize: iconSize * 0.50,
            fontWeight: FontWeight.w800,
            color: TriflouzeTheme.primary,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: iconSize * 0.06),
        Text(
          'Gérez vos dépenses en famille',
          style: TextStyle(
            fontSize: iconSize * 0.195,
            fontWeight: FontWeight.w500,
            color: TriflouzeTheme.textMedium,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

