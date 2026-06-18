🏳️ Skill: Banderas de las Selecciones (Mundial 2026)

## Por qué

Hoy `match_card_widget.dart` y `detail_screen.dart` pintan el "logo" del equipo con `Image.network(match.homeLogo)`, usando el `crest` que devuelve football-data.org. Para selecciones nacionales ese campo es inconsistente (a veces es el escudo de la federación, no la bandera), depende de una llamada de red por cada ícono, y si falla cae al `Icon(Icons.flag_rounded)` genérico.

Esta skill reemplaza eso por banderas reales, renderizadas localmente (sin red, sin parpadeo, sin íconos rotos), usando el código ISO del país en vez de una URL. Cubre las 48 selecciones ya confirmadas para el Mundial 2026 (fuente: FIFA, verificado en junio 2026).

## 1. Dependencia

```yaml
# pubspec.yaml
dependencies:
  country_flags: ^4.1.2
```

Renderiza el SVG de la bandera a partir de un código ISO 3166-1 (2 o 3 letras), sin llamadas a internet — los assets vienen empaquetados en el propio paquete.

## 2. Mapeo equipo → código ISO

```dart
// lib/core/utils/team_flag_mapper.dart

/// Mapea el nombre de equipo que devuelve football-data.org (campo `name`
/// de homeTeam/awayTeam) a su código ISO 3166-1 alpha-2, para las 48
/// selecciones confirmadas del Mundial 2026.
///
/// Inglaterra y Escocia no tienen código ISO propio (forman parte de GB),
/// así que se marcan con una clave especial que resuelve TeamFlagWidget
/// usando un asset local en vez del paquete country_flags.
class TeamFlagMapper {
  TeamFlagMapper._();

  static const String englandFlag = '__GB-ENG__';
  static const String scotlandFlag = '__GB-SCT__';

  static const Map<String, String> _isoByTeamName = {
    // Anfitriones
    'canada': 'CA',
    'mexico': 'MX',
    'méxico': 'MX',
    'usa': 'US',
    'united states': 'US',

    // AFC
    'australia': 'AU',
    'iraq': 'IQ',
    'iran': 'IR',
    'ir iran': 'IR',
    'japan': 'JP',
    'jordan': 'JO',
    'korea republic': 'KR',
    'south korea': 'KR',
    'qatar': 'QA',
    'saudi arabia': 'SA',
    'uzbekistan': 'UZ',

    // CAF
    'algeria': 'DZ',
    'cabo verde': 'CV',
    'cape verde': 'CV',
    'congo dr': 'CD',
    'dr congo': 'CD',
    'democratic republic of the congo': 'CD',
    "côte d'ivoire": 'CI',
    "cote d'ivoire": 'CI',
    'ivory coast': 'CI',
    'egypt': 'EG',
    'ghana': 'GH',
    'morocco': 'MA',
    'senegal': 'SN',
    'south africa': 'ZA',
    'tunisia': 'TN',

    // Concacaf (sin anfitriones)
    'curaçao': 'CW',
    'curacao': 'CW',
    'haiti': 'HT',
    'panama': 'PA',

    // CONMEBOL
    'argentina': 'AR',
    'brazil': 'BR',
    'brasil': 'BR',
    'colombia': 'CO',
    'ecuador': 'EC',
    'paraguay': 'PY',
    'uruguay': 'UY',

    // OFC
    'new zealand': 'NZ',

    // UEFA
    'austria': 'AT',
    'belgium': 'BE',
    'bosnia and herzegovina': 'BA',
    'croatia': 'HR',
    'czechia': 'CZ',
    'czech republic': 'CZ',
    'england': englandFlag,
    'france': 'FR',
    'germany': 'DE',
    'netherlands': 'NL',
    'norway': 'NO',
    'portugal': 'PT',
    'scotland': scotlandFlag,
    'spain': 'ES',
    'sweden': 'SE',
    'switzerland': 'CH',
    'türkiye': 'TR',
    'turkiye': 'TR',
    'turkey': 'TR',
  };

  /// Devuelve el código ISO (o la clave especial de Inglaterra/Escocia)
  /// para un nombre de equipo, o null si no está mapeado.
  static String? codeFor(String teamName) {
    final key = teamName.trim().toLowerCase();
    return _isoByTeamName[key];
  }
}
```

## 3. Caso especial: Inglaterra y Escocia

`country_flags` resuelve banderas por código ISO de país soberano. Como Inglaterra y Escocia compiten como selecciones separadas pero ambas pertenecen al Reino Unido (`GB`), el paquete mostraría la misma Union Jack para las dos — incorrecto para un Mundial donde ambas están clasificadas.

Solución: dos assets locales (PNG o SVG) de la bandera de San Jorge (Inglaterra) y el Saltire (Escocia), tomados de cualquier fuente libre de banderas (por ejemplo el proyecto `flag-icons`, MIT license, que las publica como `gb-eng` y `gb-sct`).

```yaml
# pubspec.yaml
flutter:
  uses-material-design: true
  assets:
    - assets/flags/gb-eng.png
    - assets/flags/gb-sct.png
```

Coloca los dos archivos en `assets/flags/` dentro del proyecto.

## 4. Widget reutilizable

```dart
// lib/core/widgets/team_flag_widget.dart
import 'package:flutter/material.dart';
import 'package:country_flags/country_flags.dart';
import '../utils/team_flag_mapper.dart';
import '../theme/world_cup_colors.dart';

/// Bandera circular de un equipo a partir de su nombre (tal como lo
/// devuelve la API). Si el equipo no está mapeado, cae al ícono
/// genérico que ya se usaba antes — mismo comportamiento de fallback.
class TeamFlagWidget extends StatelessWidget {
  final String teamName;
  final double size;

  const TeamFlagWidget({super.key, required this.teamName, this.size = 32});

  @override
  Widget build(BuildContext context) {
    final code = TeamFlagMapper.codeFor(teamName);

    if (code == TeamFlagMapper.englandFlag) {
      return _circularAsset('assets/flags/gb-eng.png');
    }
    if (code == TeamFlagMapper.scotlandFlag) {
      return _circularAsset('assets/flags/gb-sct.png');
    }
    if (code != null) {
      return ClipOval(
        child: SizedBox(
          width: size,
          height: size,
          child: CountryFlag.fromCountryCode(
            code,
            theme: ImageTheme(width: size, height: size),
          ),
        ),
      );
    }

    // Equipo sin mapear (no debería pasar con los 48 confirmados,
    // pero deja la app a salvo si la API agrega otra competición).
    return Icon(Icons.flag_rounded, size: size, color: WorldCupColors.textMuted);
  }

  Widget _circularAsset(String assetPath) {
    return ClipOval(
      child: Image.asset(assetPath, width: size, height: size, fit: BoxFit.cover),
    );
  }
}
```

## 5. Dónde reemplazar el código actual

En `match_card_widget.dart`, donde hoy está:

```dart
ClipOval(
  child: match.homeLogo.isNotEmpty
      ? Image.network(match.homeLogo, width: 32, height: 32, fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.flag_rounded, color: WorldCupColors.textMuted))
      : const Icon(Icons.flag_rounded, color: WorldCupColors.textMuted),
),
```

reemplazar por:

```dart
TeamFlagWidget(teamName: match.homeTeam, size: 32),
```

(y lo mismo para el equipo visitante, con `match.awayTeam`).

En `detail_screen.dart`, el bloque equivalente de `ClipOval(child: Image.network(match.homeLogo, width: 50/72, ...))` se reemplaza igual, ajustando `size` a 50 (header del `SliverAppBar`) o 72 si decides mantener ese tamaño en algún otro lugar.

No es necesario tocar `match_model.dart` ni quitar `homeLogo`/`awayLogo` de la entidad — quedan ahí sin uso en la UI, por si en el futuro quieres mostrar el escudo oficial de la federación en otro lugar.

## 6. Checklist de verificación

- `flutter pub get` después de agregar `country_flags` al `pubspec.yaml`.
- Probar un partido con Inglaterra y otro con Escocia: deben verse banderas distintas (San Jorge vs. Saltire), no la misma Union Jack.
- Probar un partido con un equipo no mapeado a propósito (nombre inventado): debe caer al ícono `Icons.flag_rounded` sin lanzar excepción.
- Confirmar que ya no hay parpadeo de imagen mientras carga (las banderas locales se pintan en el mismo frame, a diferencia de `Image.network`).