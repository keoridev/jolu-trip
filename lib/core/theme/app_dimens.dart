import 'package:flutter/material.dart';

class AppDimens {
  const AppDimens._();

  // ─── Spacing (8pt grid) ───────────────────────
  static const double space0 = 0;
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space40 = 40;
  static const double space48 = 48;
  static const double space56 = 56;
  static const double space64 = 64;
  static const double space80 = 80;
  static const double space96 = 96;

  // ─── Radii ─────────────────────────────────────
  static const double radius4 = 4;
  static const double radius8 = 8;
  static const double radius12 = 12;
  static const double radius14 = 14;
  static const double radius16 = 16;
  static const double radius20 = 20;
  static const double radius24 = 24;
  static const double radius32 = 32;
  static const double radiusRound = 999;

  // ─── Radii (Named for convenience) ──────────────
  static const double radiusS = radius8;
  static const double radiusM = radius14;
  static const double radiusL = radius24;

  // ─── Avatar Sizes ──────────────────────────────
  static const double avatar32 = 32;
  static const double avatar40 = 40;
  static const double avatar48 = 48;
  static const double avatar56 = 56;
  static const double avatar64 = 64;
  static const double avatar80 = 80;

  // ─── Icon Sizes ────────────────────────────────
  static const double icon16 = 16;
  static const double icon20 = 20;
  static const double icon24 = 24;
  static const double icon28 = 28;
  static const double icon32 = 32;

  // ─── Stroke ────────────────────────────────────
  static const double strokeHairline = 0.5;
  static const double strokeThin = 1;
  static const double strokeDefault = 1.5;

  // ─── Component-specific ────────────────────────
  static const double buttonMinHeight = 48;
  static const double tabBarHeight = 64;
  static const double bottomNavHeight = 72;

  // ─── Global Padding ────────────────────────────
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: space16,
    vertical: space24,
  );

  static const EdgeInsets cardPadding = EdgeInsets.all(space16);
  static const EdgeInsets photoCardPadding = EdgeInsets.fromLTRB(
    space16,
    0,
    space16,
    space12,
  );

  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: space24,
    vertical: space16,
  );

  static const EdgeInsets tabBarPadding = EdgeInsets.only(
    bottom: space8,
    top: space4,
  );
}
