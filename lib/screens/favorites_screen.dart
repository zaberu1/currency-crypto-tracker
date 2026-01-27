import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/asset_card.dart';
import '../widgets/bottom_nav.dart';
import '../data_provider.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        centerTitle: true,
        actions: [
          Consumer<CurrencyData>(
            builder: (context, provider, child) {
              if (provider.favoriteAssets.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  onPressed: () {
                    _showClearAllDialog(context, provider);
                  },
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
      body: Consumer<CurrencyData>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.favoriteAssets.isEmpty) {
            return _buildLoadingView();
          }

          if (provider.favoriteAssets.isEmpty) {
            return _buildEmptyView();
          }

          return Column(
            children: [
              // Статистика избранного
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(
                      label: Text(
                        'Favorites: ${provider.favoriteAssets.length}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: Colors.yellow.withOpacity(0.2),
                    ),
                    Chip(
                      label: Text(
                        'Total Value: \$${_calculateTotalValue(provider.favoriteAssets).toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: Colors.greenAccent.withOpacity(0.2),
                    ),
                  ],
                ),
              ),

              // Список избранных
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await provider.refreshData();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: provider.favoriteAssets.length,
                    itemBuilder: (context, index) {
                      final asset = provider.favoriteAssets[index];
                      return Dismissible(
                        key: Key(asset.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return await _showConfirmDialog(context, asset);
                        },
                        onDismissed: (direction) {
                          provider.toggleFavorite(asset.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Removed ${asset.name} from favorites'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        },
                        child: AssetCard(asset: asset),
                      );
                    },
                  ),
                ),
              ),

              // Подсказка
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[900],
                child: const Row(
                  children: [
                    Icon(Icons.info, size: 16, color: Colors.grey),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Swipe left to remove from favorites',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 2),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading favorites...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.star_border,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No favorites yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Tap the star icon on any asset to add it to your favorites',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
            icon: const Icon(Icons.home),
            label: const Text('Browse Assets'),
          ),
        ],
      ),
    );
  }

  double _calculateTotalValue(List<Asset> assets) {
    return assets.fold(0.0, (sum, asset) => sum + asset.price);
  }

  Future<bool> _showConfirmDialog(BuildContext context, Asset asset) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove from favorites?'),
        content: Text(
          'Are you sure you want to remove ${asset.name} (${asset.symbol}) from your favorites?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    ) ??
        false;
  }

  Future<void> _showClearAllDialog(BuildContext context, CurrencyData provider) async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all favorites?'),
        content: const Text(
          'Are you sure you want to remove all assets from your favorites? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    ) ??
        false;

    if (shouldClear) {
      // Создаем копию списка для удаления
      final favoritesCopy = List<Asset>.from(provider.favoriteAssets);

      // Удаляем каждый актив из избранного
      for (final asset in favoritesCopy) {
        provider.toggleFavorite(asset.id);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All favorites cleared'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}