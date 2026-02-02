import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            /// LEFT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildAssetIcon(asset),
                      const SizedBox(width: 12),
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

            /// RIGHT
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatPrice(asset),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),

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
                    '1 USD = ${_formatCurrency(asset.price, asset.symbol)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[400],
                    ),
                  ),

                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => dataProvider.toggleFavorite(asset.id),
                  child: Icon(
                    asset.isFavorite
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: asset.isFavorite ? Colors.yellow : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================= PRICE FORMAT =================

  String _formatPrice(Asset asset) {
    if (asset.type == 'crypto') {
      return _formatCurrency(asset.price, '\$');
    }
    return _formatCurrency(asset.price, asset.symbol);
  }

  String _formatCurrency(double value, String symbol) {
    final formatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: symbol == '\$' ? '\$' : '',
      decimalDigits: 2,
    );

    final formatted = formatter.format(value);

    return symbol == '\$' ? formatted : '$formatted $symbol';
  }

  // ================= UI HELPERS =================

  Widget _buildAssetIcon(Asset asset) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _getAssetColor(asset),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          _getSymbol(asset),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _getSymbol(Asset asset) {
    switch (asset.symbol) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'KZT':
        return '₸';
      case 'RUB':
        return '₽';
      case 'BTC':
        return '₿';
      case 'ETH':
        return 'Ξ';
      case 'USDT':
        return '₮';
      default:
        return asset.symbol.substring(0, 1);
    }
  }

  Widget _buildChangeChip(String label, double change) {
    final color = _getChangeColor(change);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label ${change.abs().toStringAsFixed(1)}%',
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getAssetColor(Asset asset) {
    if (asset.type == 'crypto') {
      switch (asset.symbol) {
        case 'BTC':
          return const Color(0xFFF7931A);
        case 'ETH':
          return const Color(0xFF627EEA);
        case 'USDT':
          return const Color(0xFF26A17B);
        default:
          return Colors.blueAccent;
      }
    } else {
      switch (asset.symbol) {
        case 'USD':
          return Colors.green;
        case 'EUR':
          return const Color(0xFF0033CC);
        case 'KZT':
          return const Color(0xFF00AFCA);
        case 'RUB':
          return const Color(0xFF0039A6);
        default:
          return Colors.blueAccent;
      }
    }
  }

  Color _getChangeColor(double change) {
    if (change > 0) return const Color(0xFF00B894);
    if (change < 0) return const Color(0xFFD63031);
    return Colors.grey;
  }
}
