import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _freeBase = 'api.coingecko.com';

  static const List<String> _topCryptos = [
    'bitcoin',
    'ethereum',
    'tether',
    'binancecoin',
    'solana',
    'ripple',
    'usd-coin',
    'cardano',
    'dogecoin',
    'polkadot',
    'tron',
    'chainlink',
    'matic-network',
    'stellar',
    'litecoin',
  ];

  // ---------------- SIMPLE PRICE ----------------
  Future<Map<String, dynamic>> getCryptoData() async {
    final uri = Uri.https(
      _freeBase,
      '/api/v3/simple/price',
      {
        'ids': _topCryptos.join(','),
        'vs_currencies': 'usd',
        'include_24hr_change': 'true',
      },
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {};
    } catch (_) {
      return {};
    }
  }

  // ---------------- MARKET DATA ----------------
  Future<List<dynamic>> getDetailedCryptoData() async {
    final uri = Uri.https(
      _freeBase,
      '/api/v3/coins/markets',
      {
        'vs_currency': 'usd',
        'ids': _topCryptos.take(10).join(','),
        'order': 'market_cap_desc',
        'per_page': '10',
        'page': '1',
        'sparkline': 'false',
        'price_change_percentage': '1h,24h,7d',
      },
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // ---------------- EXCHANGE RATES ----------------
  Future<Map<String, dynamic>> getExchangeRates(String baseCurrency) async {
    try {
      final response = await http.get(
        Uri.parse('https://open.er-api.com/v6/latest/$baseCurrency'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }

      return _fallbackRates();
    } catch (_) {
      return _fallbackRates();
    }
  }

  Map<String, dynamic> _fallbackRates() {
    return {
      'rates': {
        'USD': 1.0,
        'EUR': 0.92,
        'GBP': 0.79,
        'JPY': 150.0,
        'KZT': 470.0,
        'RUB': 92.0,
      }
    };
  }

  // ---------------- CONVERTER ----------------
  Future<double> convertCurrency(String from, String to, double amount) async {
    final data = await getExchangeRates(from);
    final rate = data['rates']?[to];

    if (rate == null) {
      throw Exception('Rate not found');
    }

    return amount * rate;
  }
}
