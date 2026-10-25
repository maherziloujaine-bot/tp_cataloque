import 'package:flutter/material.dart';

import 'models/panier.dart';
import 'screens/catalogue_screen.dart';

void main() {
  runApp(const CatalogueApp());
}

class CatalogueApp extends StatefulWidget {
  const CatalogueApp({super.key});

  @override
  State<CatalogueApp> createState() => _CatalogueAppState();
}

class _CatalogueAppState extends State<CatalogueApp> {
  final Panier _panier = Panier();

  @override
  void dispose() {
    _panier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF3F51B5);
    const background = Color(0xFFF5F6FA);

    return MaterialApp(
      title: 'Catalogue de formations',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: primary),
        scaffoldBackgroundColor: background,
        appBarTheme: const AppBarTheme(
          backgroundColor: primary,
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(28)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: const StadiumBorder(),
          ),
        ),
      ),
      home: CatalogueScreen(panier: _panier),
    );
  }
}
