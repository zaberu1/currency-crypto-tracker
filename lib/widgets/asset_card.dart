import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data_provider.dart';

class AssetCard extends StatelessWidget {
  final Asset asset;

  const AssetCard({
    super.key,
    required this.asset,
  });

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<CurrencyData>(context, listen: false);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      color: const Color(0xFF1E1E1E),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Можно добавить детальный просмотр
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Левая часть: Иконка и название
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Иконка криптовалюты
                        _buildAssetIcon(asset),
                        const SizedBox(width: 12),
                        // Название и символ
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                asset.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                asset.symbol,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Индикаторы изменений (только для крипто)
                    if (asset.type == 'crypto')
                      Row(
                        children: [
                          _buildChangeChip('1h', asset.priceChange1h),
                          const SizedBox(width: 6),
                          _buildChangeChip('24h', asset.priceChange24h),
                          const SizedBox(width: 6),
                          _buildChangeChip('7d', asset.priceChange7d),
                        ],
                      ),
                  ],
                ),
              ),

              // Правая часть: Цена и избранное
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Цена
                  Text(
                    '\$${_formatPrice(asset.price)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Изменение цены за 24ч
                  if (asset.type == 'crypto')
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          asset.priceChange24h >= 0
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          size: 14,
                          color: dataProvider.getChangeColor(asset.priceChange24h),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${asset.priceChange24h >= 0 ? '+' : ''}${asset.priceChange24h.toStringAsFixed(2)}%',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: dataProvider.getChangeColor(asset.priceChange24h),
                          ),
                        ),
                      ],
                    )
                  else if (asset.type == 'currency' && asset.symbol != 'USD')
                    Text(
                      '1 USD = ${asset.price.toStringAsFixed(4)} ${asset.symbol}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[400],
                      ),
                    ),
                  const SizedBox(height: 8),
                  // Кнопка избранного
                  GestureDetector(
                    onTap: () {
                      dataProvider.toggleFavorite(asset.id);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: asset.isFavorite
                            ? Colors.yellow.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.1),
                      ),
                      child: Icon(
                        asset.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                        size: 20,
                        color: asset.isFavorite ? Colors.yellow : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssetIcon(Asset asset) {
    // Используем цветные иконки без сетевых запросов
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _getAssetColor(asset),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _getAssetColor(asset).withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: _getAssetIconWidget(asset),
      ),
    );
  }

  Widget _getAssetIconWidget(Asset asset) {
    if (asset.type == 'crypto') {
      // Иконки криптовалют
      switch (asset.symbol) {
        case 'BTC':
          return const Text(
            '₿',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        case 'ETH':
          return const Text(
            'Ξ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        case 'USDT':
          return const Text(
            '₮',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        case 'BNB':
          return const Text(
            'B',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        case 'SOL':
          return const Text(
            '◎',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        case 'XRP':
          return const Text(
            'X',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        case 'ADA':
          return const Text(
            'A',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        case 'DOGE':
          return const Text(
            'Ð',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        default:
          return Text(
            asset.symbol.length >= 2
                ? asset.symbol.substring(0, 2)
                : asset.symbol,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
      }
    } else {
      // Иконки валют
      switch (asset.symbol) {
        case 'USD':
          return const Text(
            '\$',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        case 'EUR':
          return const Text(
            '€',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        case 'GBP':
          return const Text(
            '£',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        case 'JPY':
          return const Text(
            '¥',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        case 'KZT':
          return const Text(
            '₸',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        case 'RUB':
          return const Text(
            '₽',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        default:
          return Text(
            asset.symbol.length >= 2
                ? asset.symbol.substring(0, 2)
                : asset.symbol,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
      }
    }
  }

  Widget _buildChangeChip(String label, double change) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getChangeColor(change).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getChangeColor(change).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 2),
          Icon(
            change >= 0 ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            size: 10,
            color: _getChangeColor(change),
          ),
          const SizedBox(width: 2),
          Text(
            '${change.abs().toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 10,
              color: _getChangeColor(change),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getAssetColor(Asset asset) {
    if (asset.type == 'crypto') {
      // Разные цвета для разных крипто
      switch (asset.symbol) {
        case 'BTC':
          return const Color(0xFFF7931A); // Bitcoin orange
        case 'ETH':
          return const Color(0xFF627EEA); // Ethereum blue
        case 'USDT':
          return const Color(0xFF26A17B); // Tether green
        case 'BNB':
          return const Color(0xFFF0B90B); // BNB yellow
        case 'SOL':
          return const Color(0xFF00FFA3); // Solana green
        case 'XRP':
          return const Color(0xFF23292F); // XRP black
        case 'ADA':
          return const Color(0xFF0033AD); // Cardano blue
        case 'DOGE':
          return const Color(0xFFC2A633); // Dogecoin gold
        default:
          return Colors.blueAccent;
      }
    } else {
      // Разные цвета для разных валют
      switch (asset.symbol) {
        case 'USD':
          return Colors.green;
        case 'EUR':
          return const Color(0xFF0033CC); // Euro blue
        case 'GBP':
          return const Color(0xFFB22222); // British red
        case 'JPY':
          return const Color(0xFFBC002D); // Japanese red
        case 'KZT':
          return const Color(0xFF00AFCA); // Kazakh blue
        case 'RUB':
          return const Color(0xFF0039A6); // Russian blue
        default:
          return Colors.blueAccent;
      }
    }
  }

  String _formatPrice(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(2)}M';
    } else if (price >= 10000) {
      return '${(price / 1000).toStringAsFixed(1)}K';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(2)}K';
    } else if (price >= 100) {
      return price.toStringAsFixed(1);
    } else if (price >= 10) {
      return price.toStringAsFixed(2);
    } else if (price >= 1) {
      return price.toStringAsFixed(3);
    } else if (price >= 0.1) {
      return price.toStringAsFixed(4);
    } else if (price >= 0.01) {
      return price.toStringAsFixed(5);
    } else {
      return price.toStringAsFixed(6);
    }
  }

  Color _getChangeColor(double change) {
    if (change > 0) return const Color(0xFF00B894); // Зеленый
    if (change < 0) return const Color(0xFFD63031); // Красный
    return Colors.grey;
  }
}

// Виджет для скелетона/загрузки
class AssetCardSkeleton extends StatelessWidget {
  const AssetCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: const Color(0xFF1E1E1E),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Скелетон для иконки
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 12),
            // Скелетон для текста
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 60,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            // Скелетон для цены
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 80,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 60,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}