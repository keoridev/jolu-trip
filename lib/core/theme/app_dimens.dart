import 'package:flutter/material.dart';

class AppDimens {
  const AppDimens._();

  // ─── Spacing ───────────────────────────────────
  static const double spaceXS = 8.0;
  static const double spaceS = 12.0;
  static const double spaceM = 16.0;
  static const double spaceL = 24.0;
  static const double spaceXL = 32.0;

  // ─── Radii ─────────────────────────────────────
  static const double radiusS = 8.0;
  static const double radiusM = 14.0;
  static const double radiusL = 24.0;
  static const double radiusRound = 99.0;

  // ─── Sizes ─────────────────────────────────────
  static const double avatarSize = 48.0;
  static const double iconS = 20.0;
  static const double iconM = 22.0;
  static const double iconSize = 24.0;

  // ─── Stroke ────────────────────────────────────
  static const double strokeThin = 1.0;

  // ─── Padding ─────────────────────────────────────
  static const EdgeInsets screenPadding = EdgeInsets.all(spaceM);
  static const EdgeInsets cardContentPadding = EdgeInsets.symmetric(
    horizontal: spaceM,
    vertical: spaceM,
  );
}