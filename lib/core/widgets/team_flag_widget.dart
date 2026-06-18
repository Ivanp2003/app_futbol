import 'package:flutter/material.dart';
import 'package:country_flags/country_flags.dart';
import '../utils/team_flag_mapper.dart';
import '../theme/world_cup_colors.dart';

/// Bandera circular de un equipo a partir de su nombre (tal como lo
/// devuelve football-data.org).
///
/// Flujo de resolución:
///   1. Busca el código en [TeamFlagMapper] (ISO 3166-1 o subdivisión 3166-2).
///   2. Si lo encuentra → [CountryFlag] renderiza el SVG local sin red.
///   3. Si no → [Icons.flag_rounded] como fallback seguro.
///
/// No hay llamadas de red: todos los SVG vienen empaquetados en
/// `country_flags` (incluyendo GB-ENG y GB-SCT).
class TeamFlagWidget extends StatelessWidget {
  final String teamName;
  final double size;

  const TeamFlagWidget({
    super.key,
    required this.teamName,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    final code = TeamFlagMapper.codeFor(teamName);

    if (code != null) {
      return CountryFlag.fromCountryCode(
        code,
        theme: ImageTheme(
          width: size,
          height: size,
          shape: const Circle(),
        ),
      );
    }

    // Equipo sin mapear: fallback silencioso sin excepción.
    return Icon(Icons.flag_rounded, size: size, color: WorldCupColors.textMuted);
  }
}
