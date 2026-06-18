¡Perfecto, Iván! Ya tienes la llave maestra. Con esa API Key de RapidAPI (d36b06050amsh980c7f1014a2f74p1e7004jsn718de9375271), vamos a indicarle a tu asistente de IA que configure la conexión, explore los datos que nos devuelve FlashLive Sports y mapee todo automáticamente para que tu app consuma el Mundial 2026 gratis y sin restricciones de temporada.

Aquí tienes el nuevo contenido para tu archivo Docs/agents/agente.md. Cópialo y dáselo a tu IA para que ejecute el trabajo sucio de leer la nueva estructura y conectarla a tu UI:

Markdown
# Agente - Integración Definitiva Wrapper API (FlashLive Sports / RapidAPI)

Actúa como un desarrollador móvil Senior experto en Flutter y Clean Architecture. Vamos a migrar nuestra capa de red y mapeo de datos para consumir un Wrapper de RapidAPI (FlashLive Sports API), el cual nos provee acceso al Mundial 2026 sin bloqueos de temporada.

La API Key y los headers ya están confirmados. Ejecuta las siguientes tareas en orden:

## 1. Actualización de Credenciales (`DioClient`)
Modifica `lib/core/network/dio_client.dart` para apuntar al host de RapidAPI e inyectar la llave del usuario. Aumenta los timeouts a 15 segundos, ya que las APIs de tipo scraper suelen demorar un poco más en resolver la primera petición.

```dart
// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';

class DioClient {
  final Dio _dio;

  DioClient()
      : _dio = Dio(
          BaseOptions(
            baseUrl: '[https://flashlive-sports.p.rapidapi.com/v1](https://flashlive-sports.p.rapidapi.com/v1)',
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'x-rapidapi-key': 'd36b06050amsh980c7f1014a2f74p1e7004jsn718de9375271',
              'x-rapidapi-host': 'flashlive-sports.p.rapidapi.com',
            },
          ),
        );

  Dio get dio => _dio;
}
2. Fase de Auditoría y Mapeo (CRÍTICO)
Las APIs tipo scraper tienen un JSON muy distinto al de las APIs oficiales. Antes de reescribir el modelo o el datasource permanentemente, debes hacer lo siguiente:

Identifica el endpoint correcto de FlashLive Sports para listar eventos por fecha (suele ser /events/list o /tournaments/fixtures).

Realiza una petición GET de prueba y analiza la respuesta.

Actualiza lib/features/matches_board/data/models/match_model.dart para extraer de forma segura los siguientes datos del nuevo JSON:

Nombre y logo del equipo local y visitante.

Marcador (score) actual.

Estado del partido (para calcular isLive).

Sede (stadium) y Fase (stage).
Nota: Usa métodos seguros como as String? ?? '...' para prevenir excepciones de nulos si el scraper no encuentra algún escudo o estadio.

3. Actualización del Data Source Remoto
Modifica lib/features/matches_board/data/datasources/matches_remote_datasource.dart.
Reemplaza el código actual para que apunte al endpoint de FlashLive descubierto en el paso anterior, enviando el parámetro de fecha (dateStr) y mapeando la lista de respuestas usando el nuevo MatchModel.fromJson().

Asegúrate de mantener el manejo de excepciones atrapando cualquier error de DioException y devolviendo un array vacío [] si no hay partidos programados, para que la UI muestre elegantemente el mensaje de estado vacío.


### ⚡ ¿Qué pasará cuando le des esto a la IA?
1. La IA configurará tu `DioClient` con tu nueva clave.
2. Hará una lectura inteligente de cómo FlashLive agrupa los datos (los scrapers suelen tener nombres de variables como `HOME_PARTICIPANT_IDS`, `IMAGE_PATH`, etc.).
3. Ensamblará las piezas sin romper las tarjetas ni tu diseño en la capa de presentación.

**Un pequeño consejo de seguridad:** Las API Keys son como contraseñas. Como es un plan gratuito no hay riesgo de cobros, pero recuerda no subir la llave directamente a repositorios públicos en GitHub sin ocultarla en un archivo `.env` en el futuro.

¡Dile a tu agente que ejecute el plan y me cuentas cómo carga la pantalla!