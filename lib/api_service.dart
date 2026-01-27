import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Ваш API ключ CoinGecko Pro
  static const String _apiKey = 'CG-Ki5sEMyi4Jzj87ZvyjkCjuXm';

  // CoinGecko Pro API
  static const String _coinGeckoProBaseUrl = 'https://pro-api.coingecko.com/api/v3';

  // Список основных криптовалют (ID из CoinGecko)
  static const List<String> _topCryptos = [
    'bitcoin',      // BTC
    'ethereum',     // ETH
    'tether',       // USDT
    'binancecoin',  // BNB
    'solana',       // SOL
    'ripple',       // XRP
    'usd-coin',     // USDC
    'cardano',      // ADA
    'dogecoin',     // DOGE
    'polkadot',     // DOT
    'tron',         // TRX
    'chainlink',    // LINK
    'matic-network', // MATIC
    'stellar',      // XLM
    'litecoin',     // LTC
  ];

  // Получение данных о криптовалютах
  Future<Map<String, dynamic>> getCryptoData() async {
    try {
      final headers = {
        'x-cg-pro-api-key': _apiKey,
        'Content-Type': 'application/json',
      };

      final ids = _topCryptos.join(',');
      final response = await http.get(
        Uri.parse(
            '$_coinGeckoProBaseUrl/simple/price?ids=$ids&vs_currencies=usd&include_24hr_change=true&include_24hr_vol=true&include_market_cap=true'
        ),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('CoinGecko Pro API Error: ${response.statusCode}');
        print('Response: ${response.body}');
        // Fallback к бесплатному API
        return await _getCryptoDataFree();
      }
    } catch (e) {
      print('API Error: $e');
      return await _getCryptoDataFree();
    }
  }

  // Fallback метод для бесплатного API
  Future<Map<String, dynamic>> _getCryptoDataFree() async {
    try {
      final ids = _topCryptos.join(',');
      final response = await http.get(
        Uri.parse(
            'https://api.coingecko.com/api/v3/simple/price?ids=$ids&vs_currencies=usd&include_24hr_change=true'
        ),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {};
    } catch (e) {
      print('Free API Error: $e');
      return {};
    }
  }

  // Получение подробных данных о криптовалютах (с объемом торгов и капитализацией)
  Future<List<dynamic>> getDetailedCryptoData() async {
    try {
      final headers = {
        'x-cg-pro-api-key': _apiKey,
        'Content-Type': 'application/json',
      };

      final response = await http.get(
        Uri.parse(
            '$_coinGeckoProBaseUrl/coins/markets?vs_currency=usd&ids=${_topCryptos.join(',')}&order=market_cap_desc&per_page=20&page=1&sparkline=true&price_change_percentage=1h,24h,7d'
        ),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Detailed API Error: ${response.statusCode}');
        return await _getDetailedCryptoDataFree();
      }
    } catch (e) {
      print('Detailed API Error: $e');
      return await _getDetailedCryptoDataFree();
    }
  }

  // Fallback для подробных данных
  Future<List<dynamic>> _getDetailedCryptoDataFree() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids=${_topCryptos.take(10).join(',')}&order=market_cap_desc&per_page=10&page=1&sparkline=false&price_change_percentage=1h,24h,7d'
        ),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      print('Free Detailed API Error: $e');
      return [];
    }
  }

  // Получение курсов валют (используем бесплатный API для валют)
  Future<Map<String, dynamic>> getExchangeRates(String baseCurrency) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.exchangerate-api.com/v4/latest/$baseCurrency'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }

      // Fallback API
      return await _getExchangeRatesFallback(baseCurrency);
    } catch (e) {
      print('Exchange Rate Error: $e');
      return await _getExchangeRatesFallback(baseCurrency);
    }
  }

  // Fallback для курсов валют
  Future<Map<String, dynamic>> _getExchangeRatesFallback(String baseCurrency) async {
    try {
      final response = await http.get(
        Uri.parse('https://open.er-api.com/v6/latest/$baseCurrency'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }

      // Создаем фиктивные данные, если API недоступны
      return {
        'rates': {
          'USD': 1.0,
          'EUR': 0.92,
          'GBP': 0.79,
          'JPY': 150.0,
          'CAD': 1.35,
          'AUD': 1.52,
          'KZT': 470.0,
          'RUB': 92.0,
        }
      };
    } catch (e) {
      return {
        'rates': {
          'USD': 1.0,
          'EUR': 0.92,
          'GBP': 0.79,
          'JPY': 150.0,
          'CAD': 1.35,
          'AUD': 1.52,
          'KZT': 470.0,
          'RUB': 92.0,
        }
      };
    }
  }

  // Конвертация валют
  Future<double> convertCurrency(String from, String to, double amount) async {
    try {
      final rates = await getExchangeRates(from);
      final rate = rates['rates'][to];

      if (rate != null) {
        return amount * rate;
      }
      throw Exception('Conversion rate not found');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Получение информации о конкретной криптовалюте
  Future<Map<String, dynamic>> getCryptoInfo(String id) async {
    try {
      final headers = {
        'x-cg-pro-api-key': _apiKey,
        'Content-Type': 'application/json',
      };

      final response = await http.get(
        Uri.parse('$_coinGeckoProBaseUrl/coins/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {};
    } catch (e) {
      print('Crypto Info Error: $e');
      return {};
    }
  }

  // Получение исторических данных для графика
  Future<List<dynamic>> getHistoricalData(String id, int days) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://api.coingecko.com/api/v3/coins/$id/market_chart?vs_currency=usd&days=$days'
        ),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body)['prices'];
      }
      return [];
    } catch (e) {
      print('Historical Data Error: $e');
      return [];
    }
  }

  // Получение списка всех криптовалют для поиска
  Future<List<dynamic>> getAllCryptos() async {
    try {
      final headers = {
        'x-cg-pro-api-key': _apiKey,
        'Content-Type': 'application/json',
      };

      final response = await http.get(
        Uri.parse('$_coinGeckoProBaseUrl/coins/list'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }

      // Fallback
      return await _getAllCryptosFree();
    } catch (e) {
      return await _getAllCryptosFree();
    }
  }

  Future<List<dynamic>> _getAllCryptosFree() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.coingecko.com/api/v3/coins/list'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}