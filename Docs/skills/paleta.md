🎨 Skill: Paleta Oficial Mundial 2026 (estilo FIFA)

## Paleta

🟢 Verde `#00A651` · 🔴 Rojo `#E53935` · 🔵 Azul `#0066CC` · 🟡 Dorado `#D4AF37` · ⚪ Blanco `#FFFFFF`

## Por qué no alcanza con cambiar los hex a mano

`WorldCupColors` ya existe (`lib/core/theme/world_cup_colors.dart`) y se usa en **6 archivos**: `home_screen.dart`, `filter_screen.dart`, `date_selector_bar.dart`, `match_card_widget.dart`, `detail_screen.dart` y `app_theme.dart`. El color que hoy hace de acento de marca es `magenta` (`#E4007C`), y se usa para cosas semánticamente distintas: el badge "EN VIVO", la fecha seleccionada, los chips de filtro, el botón "Aplicar Filtros", el ícono de "Clasificación" y — esto es un bug de diseño que ya existía — el mensaje de error del `FutureBuilder`, que usa magenta como si fuera un color de error.

La nueva paleta no tiene magenta, así que no es un simple find-and-replace de hex: hay que decidir qué rol cumple cada uso y asignarle el color correcto de la paleta nueva. Abajo está esa decisión ya tomada, archivo por archivo.

## Roles semánticos (lo que reemplaza a `magenta`)

| Rol | Color | Para qué se usa |
|---|---|---|
| `primary` | 🔵 Azul `#0066CC` | AppBar, headers, gradiente del detalle — estructura principal. Ya era azul, solo cambia el hex. |
| `accent` | 🟡 Dorado `#D4AF37` | Selección y destacados: fecha elegida, chip de filtro activo, botón "Aplicar Filtros", tab seleccionado, ícono de "Clasificación", indicador de carga, lado local de las barras de posesión/estadísticas. |
| `live` | 🔴 Rojo `#E53935` | Badge "EN VIVO" / minuto en juego, **y** mensajes de error (corrige el mal uso de magenta como color de error). |
| `positive` | 🟢 Verde `#00A651` | Marcador cuando el partido ya empezó, lado visitante de las barras comparativas, ícono de estadio. Ya era verde, solo cambia el hex. |
| neutros | sin cambio | `dark`, `gray`, `lightGray`, `bg`, `textDark`, `textMuted` no forman parte de esta paleta — se mantienen igual. |

## 1. Reemplazar `lib/core/theme/world_cup_colors.dart`

```dart
import 'package:flutter/material.dart';

class WorldCupColors {
  // Paleta oficial Mundial 2026
  static const Color green = Color(0xFF00A651);
  static const Color red = Color(0xFFE53935);
  static const Color blue = Color(0xFF0066CC);
  static const Color gold = Color(0xFFD4AF37);
  static const Color white = Color(0xFFFFFFFF);

  // Roles semánticos construidos sobre la paleta anterior.
  // Usar estos nombres en el código de UI en vez de los colores "crudos".
  static const Color primary = blue;   // AppBar, headers, estructura
  static const Color accent = gold;    // selección, destacados, CTA
  static const Color live = red;       // EN VIVO + mensajes de error
  static const Color positive = green; // marcador activo, lado visitante

  // Neutros — sin cambios respecto a la versión anterior
  static const Color dark = Color(0xFF111827);
  static const Color gray = Color(0xFF6B7280);
  static const Color lightGray = Color(0xFFF3F4F6);
  static const Color bg = Color(0xFFFAFAFA);
  static const Color cardBackground = Colors.white;
  static const Color textDark = Color(0xFF111827);
  static const Color textMuted = Color(0xFF6B7280);
}
```

Nota: quité `primaryBlue`, `vibrantPurple`, `deepGreen`, `vibrantGreen`, `vibrantRed`, `hotPink`, `neonYellow`, `brightCyan` y `background` — son restos de la paleta vieja (la que describe `Docs/skills/app.md`) que no se usan en ningún archivo real del proyecto. Si algo en tu código sí los referencia, avísame y los agrego de vuelta antes de borrarlos.

## 2. Migración archivo por archivo

`blue` y `green` mantienen su nombre — al cambiar su valor en el paso 1, **todo lo que ya decía `WorldCupColors.blue` o `WorldCupColors.green` se actualiza solo**, sin tocar esos archivos. Lo único que hay que reemplazar manualmente es cada `WorldCupColors.magenta`, según esta tabla:

| Archivo | Uso (línea aprox.) | Antes | Después |
|---|---|---|---|
| `home_screen.dart` | acento del `showDatePicker` (~62) | `primary: WorldCupColors.magenta` | `primary: WorldCupColors.accent` |
| `home_screen.dart` | texto de fecha "MIÉRCOLES, 17 DE JUNIO" (~148) | `WorldCupColors.magenta` | `WorldCupColors.accent` |
| `home_screen.dart` | badge "FILTRADO" fondo + texto (~156, 164) | `WorldCupColors.magenta` | `WorldCupColors.accent` |
| `home_screen.dart` | `CircularProgressIndicator` (~178) | `WorldCupColors.magenta` | `WorldCupColors.accent` |
| `home_screen.dart` | texto del mensaje de error (~191) | `WorldCupColors.magenta` | `WorldCupColors.live` |
| `filter_screen.dart` | `selectedColor` de los `ChoiceChip` (~64, 97) | `WorldCupColors.magenta` | `WorldCupColors.accent` |
| `filter_screen.dart` | botón "Aplicar Filtros" (~118) | `WorldCupColors.magenta` | `WorldCupColors.accent` |
| `date_selector_bar.dart` | pill de fecha seleccionada (~53) | `WorldCupColors.magenta` | `WorldCupColors.accent` |
| `match_card_widget.dart` | badge "EN VIVO" fondo + punto + texto (~37, 43, 50) | `WorldCupColors.magenta` | `WorldCupColors.live` |
| `detail_screen.dart` | minuto en vivo en el header (~108) | `WorldCupColors.magenta` | `WorldCupColors.live` |
| `detail_screen.dart` | tab seleccionado: `labelColor` / `indicatorColor` (~183, 185) | `WorldCupColors.magenta` | `WorldCupColors.accent` |
| `detail_screen.dart` | ícono "Clasificación" (~246) | `WorldCupColors.magenta` | `WorldCupColors.accent` |
| `detail_screen.dart` | posesión del balón, lado local: texto + barra (~277, 295) | `WorldCupColors.magenta` | `WorldCupColors.accent` |
| `detail_screen.dart` | fila de estadística, lado local: texto + barra (~416, 430) | `WorldCupColors.magenta` | `WorldCupColors.accent` |

No toques los usos de `WorldCupColors.green` (badge de marcador, lado visitante de posesión/estadísticas, ícono de estadio) ni los de `WorldCupColors.blue` (AppBar, gradiente del header de detalle, ícono "Horario Local", nombre de equipo en alineaciones) — esos ya están bien asignados, solo cambian de color automáticamente con el paso 1.

## 3. `app_theme.dart` — actualízalo, pero no esperes que cambie nada todavía

```dart
import 'package:flutter/material.dart';
import 'world_cup_colors.dart';

class AppTheme {
  static ThemeData buildAppTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: ColorScheme.fromSeed(
        seedColor: WorldCupColors.primary,
        primary: WorldCupColors.primary,
        secondary: WorldCupColors.accent,
        surface: WorldCupColors.bg,
      ),
      scaffoldBackgroundColor: WorldCupColors.bg,
      appBarTheme: const AppBarTheme(
        backgroundColor: WorldCupColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
    );
  }

  static ThemeData get lightTheme => buildAppTheme();
  static ThemeData get darkTheme => buildAppTheme().copyWith(
        brightness: Brightness.dark,
      );
}
```

Importante: `lib/main.dart` hoy **no usa `AppTheme`** — `MyApp` construye su propio `ThemeData(useMaterial3: true)` sin pasar por esta clase (esto ya lo habíamos detectado al revisar HU-01). Eso significa que el paso 1 (actualizar `world_cup_colors.dart`) es el que realmente cambia los colores visibles en la app, porque cada widget llama a `WorldCupColors.algo` directamente. Este paso 3 solo deja `AppTheme` consistente con la nueva paleta para el día que decidas conectarlo en `main.dart` — si quieres que lo conecte también, decime y lo agrego.

## 4. Checklist visual de verificación

Después de aplicar los cambios, confirma en la app:

- El AppBar y el header del detalle se ven azules (`#0066CC`), no el azul oscuro anterior (`#0033A0`).
- El badge "EN VIVO" de un partido en curso es rojo, no magenta.
- Si fuerzas un error de red (por ejemplo cortando el wifi), el mensaje de error en el home se ve rojo, no magenta — corrige el bug semántico que ya existía.
- La fecha seleccionada en la barra de fechas y en el `DatePicker`, los chips de filtro activos, el botón "Aplicar Filtros" y el tab activo del detalle se ven dorados.
- El marcador (cuando el partido ya tiene goles) y el lado visitante de las barras de posesión/estadísticas siguen en verde, ahora `#00A651`.