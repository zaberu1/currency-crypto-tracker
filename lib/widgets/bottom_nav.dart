import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data_provider.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;

  const BottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<CurrencyData>(context, listen: false);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        // Обновляем данные при переключении на главную
        if (index == 0) {
          dataProvider.refreshData();
          Navigator.pushReplacementNamed(context, '/');
        } else if (index == 1) {
          Navigator.pushReplacementNamed(context, '/converter');
        } else if (index == 2) {
          Navigator.pushReplacementNamed(context, '/favorites');
        }
      },
      backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
      selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
      unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          activeIcon: Icon(Icons.home_filled),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.currency_exchange_rounded),
          activeIcon: Icon(Icons.currency_exchange),
          label: 'Converter',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border_rounded),
          activeIcon: Icon(Icons.favorite_rounded),
          label: 'Favorites',
        ),
      ],
    );
  }
}