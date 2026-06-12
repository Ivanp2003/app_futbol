import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'features/matches_board/presentation/screens/home_screen.dart';

void main() async {
  // Asegura que los canales nativos estén listos antes de inicializar el idioma
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa el formateo de fechas para español (o el idioma que necesites)
  await initializeDateFormatting('es', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mundial 2026',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
