/// Mapea el nombre de equipo que devuelve football-data.org (campo `name`
/// de homeTeam/awayTeam) a su código ISO 3166-1 alpha-2 (o subdivisión
/// ISO 3166-2 para selecciones sin país propio), para las 48 selecciones
/// confirmadas del Mundial 2026.
///
/// Inglaterra → 'GB-ENG' y Escocia → 'GB-SCT': ambos están soportados
/// nativamente por el paquete country_flags (≥ 3.0.0), sin necesidad
/// de assets locales.
class TeamFlagMapper {
  TeamFlagMapper._();

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
    'tanzania': 'TZ',
    'tunisia': 'TN',

    // CONCACAF (sin anfitriones)
    'curaçao': 'CW',
    'curacao': 'CW',
    'haiti': 'HT',
    'panama': 'PA',

    // CONMEBOL
    'argentina': 'AR',
    'brazil': 'BR',
    'brasil': 'BR',
    'chile': 'CL',
    'colombia': 'CO',
    'ecuador': 'EC',
    'paraguay': 'PY',
    'peru': 'PE',
    'perú': 'PE',
    'uruguay': 'UY',
    'venezuela': 'VE',
    'bolivia': 'BO',

    // OFC
    'new zealand': 'NZ',

    // UEFA
    'austria': 'AT',
    'belgium': 'BE',
    'bosnia and herzegovina': 'BA',
    'croatia': 'HR',
    'czechia': 'CZ',
    'czech republic': 'CZ',
    // Subdivisions ISO 3166-2 — soportados por country_flags ≥ 3.0
    'england': 'GB-ENG',
    'scotland': 'GB-SCT',
    'wales': 'GB-WLS',
    'france': 'FR',
    'germany': 'DE',
    'greece': 'GR',
    'hungary': 'HU',
    'netherlands': 'NL',
    'norway': 'NO',
    'poland': 'PL',
    'portugal': 'PT',
    'romania': 'RO',
    'serbia': 'RS',
    'slovakia': 'SK',
    'slovenia': 'SI',
    'spain': 'ES',
    'sweden': 'SE',
    'switzerland': 'CH',
    'türkiye': 'TR',
    'turkiye': 'TR',
    'turkey': 'TR',
    'ukraine': 'UA',
  };

  /// Devuelve el código ISO para un nombre de equipo,
  /// o `null` si el equipo no está mapeado.
  static String? codeFor(String teamName) {
    final key = teamName.trim().toLowerCase();
    return _isoByTeamName[key];
  }
}
