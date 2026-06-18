import 'package:flutter/material.dart';

class WorldCupColors {
  // Paleta oficial Mundial 2026
  static const Color green = Color(0xFF00A651);   // Verde FIFA
  static const Color red = Color(0xFFE53935);     // Rojo FIFA
  static const Color blue = Color(0xFF0066CC);    // Azul FIFA
  static const Color gold = Color(0xFFD4AF37);    // Dorado FIFA
  static const Color white = Color(0xFFFFFFFF);

  // Roles semánticos — usar estos en el código de UI
  static const Color primary  = blue;    // AppBar, headers, estructura
  static const Color accent   = gold;    // selección, destacados, CTA
  static const Color live     = red;     // EN VIVO + mensajes de error
  static const Color positive = green;  // marcador activo, lado visitante

  // Neutros — sin cambios
  static const Color dark        = Color(0xFF111827);
  static const Color gray        = Color(0xFF6B7280);
  static const Color lightGray   = Color(0xFFF3F4F6);
  static const Color bg          = Color(0xFFFAFAFA);
  static const Color cardBackground = Colors.white;
  static const Color textDark    = Color(0xFF111827);
  static const Color textMuted   = Color(0xFF6B7280);
}
