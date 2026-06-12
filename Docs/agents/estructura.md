# Arquitectura del Código: Clean Architecture + Vertical Slicing
Organizaremos el código agrupándolo por características funcionales (features). Dentro de cada feature, dividiremos las responsabilidades en las capas clásicas de Clean Architecture: Data, Domain y Presentation.


lib/
│
├── core/                         # Configuraciones globales compartidas
│   ├── network/
│   │   └── dio_client.dart       # Instancia centralizada de Dio, Interceptors y Timeouts
│   ├── theme/
│   │   └── app_theme.dart        # Colores, tipografías y estilos visuales
│   └── utils/
│       └── date_formatter.dart   # Conversión de fechas a hora local (HU-03)
│
└── features/                     # Vertical Slicing: Funcionalidades independientes
    │
    ├── matches_board/            # Feature: Pizarra de partidos (HU-01 y HU-02)
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   └── matches_remote_datasource.dart
    │   │   └── models/
    │   │       └── match_model.dart
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   └── match_entity.dart
    │   │   └── repositories/
    │   │       └── matches_repository.dart
    │   └── presentation/
    │       ├── screens/
    │       │   └── home_screen.dart
    │       └── widgets/
    │           ├── match_card_widget.dart
    │           └── date_selector_bar.dart
    │
    └── match_detail/             # Feature: Detalle del partido (HU-03)
        ├── data/
        │   └── datasources/
        │       └── detail_remote_datasource.dart
        ├── domain/
        │   └── entities/
        │       └── match_detail_entity.dart
        └── presentation/
            └── screens/
                └── detail_screen.dart