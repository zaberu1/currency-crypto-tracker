import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/converter_screen.dart';
import 'screens/favorites_screen.dart';
import 'data_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CurrencyData()..loadData(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Currency & Crypto Tracker',
        theme: ThemeData.dark(),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/converter': (context) => const ConverterScreen(),
          '/favorites': (context) => const FavoritesScreen(),
        },
      ),
    );
  }
}