import 'package:flutter/material.dart';

class AppColors {
  static const Color bgDeep = Color(0xFF071C3D);
  static const Color bgMid = Color(0xFF0B3B73);
  static const Color bgLight = Color(0xFF1DA6E8);

  static const Color glass = Color(0x33FFFFFF);
  static const Color glassStrong = Color(0x55FFFFFF);
  static const Color textPrimary = Color(0xFFEAF6FF);
  static const Color textMuted = Color(0xFFBFD8EE);
  static const Color success = Color(0xFF66E3B4);
  static const Color danger = Color(0xFFFF8EA1);
  static const Color warning = Color(0xFFFFD089);
}

class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
}

class AppRadii {
  static const BorderRadius card = BorderRadius.all(Radius.circular(22));
  static const BorderRadius pill = BorderRadius.all(Radius.circular(28));
}
