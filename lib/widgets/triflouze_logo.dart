import 'package:flutter/material.dart';
import '../theme/triflouze_theme.dart';

/// Icône carrée arrondie Triflouze (trois membres + pièce centrale)
class TriflouzeIcon extends StatelessWidget {
  final double size;

  const TriflouzeIcon({super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _IconPainter()),
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

// ─────────────────────────────────────────────────────────────────────────────

class _IconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final white = Paint()..color = Colors.white;

    // Fond arrondi vert sauge
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, w, h),
        Radius.circular(w * 0.219),
      ),
      Paint()..color = TriflouzeTheme.primary,
    );

    // Barre horizontale du T (pill)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.156, h * 0.195, w * 0.688, h * 0.156),
        Radius.circular(h * 0.078),
      ),
      white,
    );

    // Tige verticale
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.422, h * 0.273, w * 0.156, h * 0.531),
        Radius.circular(w * 0.070),
      ),
      white,
    );

    // Connecteurs (fils suspendus)
    final connectorPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = w * 0.022
      ..strokeCap = StrokeCap.round;
    final connectorTop = h * 0.352;
    final connectorBot = h * 0.445;
    canvas.drawLine(
        Offset(w * 0.234, connectorTop), Offset(w * 0.234, connectorBot), connectorPaint);
    canvas.drawLine(
        Offset(w * 0.766, connectorTop), Offset(w * 0.766, connectorBot), connectorPaint);

    // Pièces d'or
    final coinPaint = Paint()..color = TriflouzeTheme.accent;
    final rimPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.010;
    final coinR = w * 0.094;
    final rimR = w * 0.066;
    final coinCy = h * 0.539;

    for (final cx in [w * 0.234, w * 0.766]) {
      canvas.drawCircle(Offset(cx, coinCy), coinR, coinPaint);
      canvas.drawCircle(Offset(cx, coinCy), rimR, rimPaint);
    }
  }

  @override
  bool shouldRepaint(_IconPainter old) => false;
}
