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
      items: [
        BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: currentIndex == 0
                  ? Colors.blueAccent.withOpacity(0.2)
                  : Colors.transparent,
            ),
            child: const Icon(Icons.home),
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: currentIndex == 1
                  ? Colors.blueAccent.withOpacity(0.2)
                  : Colors.transparent,
            ),
            child: const Icon(Icons.swap_horiz),
          ),
          label: 'Converter',
        ),
        BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: currentIndex == 2
                  ? Colors.blueAccent.withOpacity(0.2)
                  : Colors.transparent,
            ),
            child: const Icon(Icons.star),
          ),
          label: 'Favorites',
          activeIcon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.blueAccent.withOpacity(0.2),
            ),
            child: const Icon(
              Icons.star,
              color: Colors.yellow,
            ),
          ),
        ),
        BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: currentIndex == 3
                  ? Colors.blueAccent.withOpacity(0.2)
                  : Colors.transparent,
            ),
            child: const Icon(Icons.refresh),
          ),
          label: 'Refresh',
        ),
      ],
    );
  }
}