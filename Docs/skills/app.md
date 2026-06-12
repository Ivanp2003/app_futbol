# Skills - Aplicación de Partidos Mundial 2026

Este documento detalla los requerimientos, la arquitectura y el código base para la aplicación móvil del Mundial 2026 construida en Flutter, utilizando Clean Architecture con Vertical Slicing.

---

## 🎨 Paleta de Colores Oficiales (FIFA World Cup 2026)

Mapeo de los códigos hexadecimales extraídos de la identidad oficial de la Copa del Mundo 2026 (combinando los tonos corporativos de la FIFA con la energía de Canadá, Estados Unidos y México).

```dart
// lib/core/theme/world_cup_colors.dart
import 'package:flutter/material.dart';

class WorldCupColors {
  // Tonos Principales e Institucionales
  static const Color primaryBlue = Color(0xFF1E3A8A);    // Azul Profundo (USA / FIFA)
  static const Color vibrantPurple = Color(0xFF6A0DAD);  // Morado Eléctrico
  static const Color deepGreen = Color(0xFF004D40);      // Verde Estadio Oscuro (México)
  static const Color vibrantGreen = Color(0xFF00C853);   // Verde Campo Vivo
  
  // Tonos de Acento y Alertas
  static const Color vibrantRed = Color(0xFFD50000);     // Rojo Intenso (Canadá)
  static const Color hotPink = Color(0xFFE91E63);        // Rosa Mexicano / Magenta
  static const Color neonYellow = Color(0xFFCCFF00);     // Amarillo Lima Fluorescente
  static const Color brightCyan = Color(0xFF00E5FF);     // Turquesa / Cian Claro

  // Neutros para Estructura y UI
  static const Color background = Color(0xFFF8F9FA);     // Gris Ultra Claro para Fondos
  static const Color cardBackground = Colors.white;      // Blanco Puro para Tarjetas
  static const Color textDark = Color(0xFF111827);       // Negro Grisáceo para legibilidad
  static const Color textMuted = Color(0xFF6B7280);      // Gris para subtítulos y estadios
}