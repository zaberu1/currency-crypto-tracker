import 'package:flutter/material.dart';
import 'api_service.dart';

class Asset {
  final String id;
  final String name;
  final String symbol;
  final double price;
  final double priceChange1h;
  final double priceChange24h;
  final double priceChange7d;
  final double volume24h;
  final double marketCap;
  final String type;
  bool isFavorite;

  Asset({
    required this.id,
    required this.name,
    required this.symbol,
    required this.price,
    required this.priceChange1h,
    required this.priceChange24h,
    required this.priceChange7d,
    required this.volume24h,
    required this.marketCap,
    required this.type,
    this.isFavorite = false,
  });
}

class CurrencyData with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Asset> assets = [];
  List<Asset> favoriteAssets = [];
  Map<String, double> exchangeRates = {};
  bool isLoading = true;
  String error = '';

  // Основные валюты
  final List<String> availableCurrencies = ['USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD', 'KZT', 'RUB', 'CNY'];

  // Загрузка всех данных
  Future<void> loadData() async {
    try {
      isLoading = true;
      error = '';
      notifyListeners();

      // Очищаем предыдущие данные
      assets.clear();

      // Загружаем криптовалюты
      await _loadCryptos();

      // Загружаем валюты
      await _loadCurrencies();

      isLoading = false;
      notifyListeners();

    } catch (e) {
      error = 'Failed to load data: $e';
      isLoading = false;
      notifyListeners();
    }
  }

  // Загрузка криптовалют с реальными данными
  Future<void> _loadCryptos() async {
    try {
      final cryptoList = await _apiService.getDetailedCryptoData();

      for (var crypto in cryptoList) {
        try {
          final asset = Asset(
            id: crypto['id'] ?? '',
            name: crypto['name'] ?? 'Unknown',
            symbol: (crypto['symbol'] ?? '').toUpperCase(),
            price: (crypto['current_price'] ?? 0.0).toDouble(),
            priceChange1h: (crypto['price_change_percentage_1h_in_currency'] ?? 0.0).toDouble(),
            priceChange24h: (crypto['price_change_percentage_24h'] ?? 0.0).toDouble(),
            priceChange7d: (crypto['price_change_percentage_7d_in_currency'] ?? 0.0).toDouble(),
            volume24h: (crypto['total_volume'] ?? 0.0).toDouble(),
            marketCap: (crypto['market_cap'] ?? 0.0).toDouble(),
            type: 'crypto',
          );

          if (asset.name != 'Unknown') {
            assets.add(asset);
          }
        } catch (e) {
          print('Error parsing crypto: $e');
        }
      }

      // Если данных нет, создаем демо-данные
      if (assets.where((a) => a.type == 'crypto').isEmpty) {
        _createDemoCryptoData();
      }

    } catch (e) {
      print('Error loading cryptos: $e');
      _createDemoCryptoData();
    }
  }

  // Создание демо-данных, если API не работает
  void _createDemoCryptoData() {
    final demoCryptos = [
      {
        'id': 'bitcoin',
        'name': 'Bitcoin',
        'symbol': 'BTC',
        'price': 90317.39,
        'change1h': -0.3,
        'change24h': -0.3,
        'change7d': 2.5,
        'volume': 34963837741,
        'marketCap': 1804077401450,
      },
      {
        'id': 'ethereum',
        'name': 'Ethereum',
        'symbol': 'ETH',
        'price': 3102.84,
        'change1h': -0.3,
        'change24h': 0.0,
        'change7d': 2.0,
        'volume': 17413573158,
        'marketCap': 374539956307,
      },
      {
        'id': 'tether',
        'name': 'Tether',
        'symbol': 'USDT',
        'price': 0.9989,
        'change1h': 0.0,
        'change24h': 0.0,
        'change7d': -0.1,
        'volume': 61201261165,
        'marketCap': 186783931139,
      },
      {
        'id': 'bnb',
        'name': 'BNB',
        'symbol': 'BNB',
        'price': 887.96,
        'change1h': -0.2,
        'change24h': -1.5,
        'change7d': 0.0,
        'volume': 1351216298,
        'marketCap': 123711738434,
      },
      {
        'id': 'solana',
        'name': 'Solana',
        'symbol': 'SOL',
        'price': 139.06,
        'change1h': -0.3,
        'change24h': -1.9,
        'change7d': -2.8,
        'volume': 5954071778,
        'marketCap': 78549097435,
      },
    ];

    for (var crypto in demoCryptos) {
      final asset = Asset(
        id: crypto['id'] as String,
        name: crypto['name'] as String,
        symbol: crypto['symbol'] as String,
        price: crypto['price'] as double,
        priceChange1h: crypto['change1h'] as double,
        priceChange24h: crypto['change24h'] as double,
        priceChange7d: crypto['change7d'] as double,
        volume24h: crypto['volume'] as double,
        marketCap: crypto['marketCap'] as double,
        type: 'crypto',
      );
      assets.add(asset);
    }
  }

  // Загрузка валют
  Future<void> _loadCurrencies() async {
    try {
      final exchangeData = await _apiService.getExchangeRates('USD');
      exchangeRates = Map<String, double>.from(exchangeData['rates'] ?? {});

      // Добавляем USD как базовую валюту
      final usdAsset = Asset(
        id: 'USD',
        name: 'US Dollar',
        symbol: 'USD',
        price: 1.0,
        priceChange1h: 0.0,
        priceChange24h: 0.0,
        priceChange7d: 0.0,
        volume24h: 0.0,
        marketCap: 0.0,
        type: 'currency',
      );
      assets.add(usdAsset);

      // Добавляем основные валюты в assets
      for (var currency in availableCurrencies) {
        if (currency != 'USD' && exchangeRates.containsKey(currency)) {
          final rate = exchangeRates[currency]!;
          final asset = Asset(
            id: currency,
            name: _getCurrencyName(currency),
            symbol: currency,
            price: rate,
            priceChange1h: 0.0,
            priceChange24h: 0.0,
            priceChange7d: 0.0,
            volume24h: 0.0,
            marketCap: 0.0,
            type: 'currency',
          );
          assets.add(asset);
        }
      }

    } catch (e) {
      print('Error loading currencies: $e');
      // Создаем демо-данные для валют
      _createDemoCurrencyData();
    }
  }

  // Получение названия валюты
  String _getCurrencyName(String code) {
    final names = {
      'USD': 'US Dollar',
      'EUR': 'Euro',
      'GBP': 'British Pound',
      'JPY': 'Japanese Yen',
      'CAD': 'Canadian Dollar',
      'AUD': 'Australian Dollar',
      'KZT': 'Kazakhstani Tenge',
      'RUB': 'Russian Ruble',
      'CNY': 'Chinese Yuan',
    };
    return names[code] ?? code;
  }

  void _createDemoCurrencyData() {
    // Добавляем USD
    final usdAsset = Asset(
      id: 'USD',
      name: 'US Dollar',
      symbol: 'USD',
      price: 1.0,
      priceChange1h: 0.0,
      priceChange24h: 0.0,
      priceChange7d: 0.0,
      volume24h: 0.0,
      marketCap: 0.0,
      type: 'currency',
    );
    assets.add(usdAsset);

    final demoCurrencies = [
      {'id': 'EUR', 'rate': 0.92, 'name': 'Euro'},
      {'id': 'GBP', 'rate': 0.79, 'name': 'British Pound'},
      {'id': 'JPY', 'rate': 150.0, 'name': 'Japanese Yen'},
      {'id': 'KZT', 'rate': 470.0, 'name': 'Kazakhstani Tenge'},
      {'id': 'RUB', 'rate': 92.0, 'name': 'Russian Ruble'},
    ];

    for (var currency in demoCurrencies) {
      final asset = Asset(
        id: currency['id'] as String,
        name: currency['name'] as String,
        symbol: currency['id'] as String,
        price: currency['rate'] as double,
        priceChange1h: 0.0,
        priceChange24h: 0.0,
        priceChange7d: 0.0,
        volume24h: 0.0,
        marketCap: 0.0,
        type: 'currency',
      );
      assets.add(asset);
    }
  }

  // Обновление данных
  Future<void> refreshData() async {
    await loadData();
  }

  // Добавление в избранное
  void toggleFavorite(String assetId) {
    final assetIndex = assets.indexWhere((asset) => asset.id == assetId);
    if (assetIndex != -1) {
      assets[assetIndex].isFavorite = !assets[assetIndex].isFavorite;

      if (assets[assetIndex].isFavorite) {
        favoriteAssets.add(assets[assetIndex]);
      } else {
        favoriteAssets.removeWhere((asset) => asset.id == assetId);
      }

      notifyListeners();
    }
  }

  // Поиск активов
  List<Asset> searchAssets(String query) {
    if (query.isEmpty) return assets;

    return assets.where((asset) {
      return asset.name.toLowerCase().contains(query.toLowerCase()) ||
          asset.symbol.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Форматирование чисел
  String formatNumber(double number, {int decimals = 2}) {
    if (number >= 1000000000000) {
      return '\$${(number / 1000000000000).toStringAsFixed(decimals)}T';
    } else if (number >= 1000000000) {
      return '\$${(number / 1000000000).toStringAsFixed(decimals)}B';
    } else if (number >= 1000000) {
      return '\$${(number / 1000000).toStringAsFixed(decimals)}M';
    } else if (number >= 1000) {
      return '\$${(number / 1000).toStringAsFixed(decimals)}K';
    }
    return '\$${number.toStringAsFixed(decimals)}';
  }

  // Получение цвета для изменения цены
  Color getChangeColor(double change) {
    if (change > 0) return Colors.green;
    if (change < 0) return Colors.red;
    return Colors.grey;
  }

  // Получение иконки для изменения цены
  IconData getChangeIcon(double change) {
    if (change > 0) return Icons.arrow_upward;
    if (change < 0) return Icons.arrow_downward;
    return Icons.horizontal_rule;
  }

  // КОНВЕРТАЦИЯ - ДОБАВЛЕННЫЙ МЕТОД
  Future<double> convert(String from, String to, double amount) async {
    try {
      // Парсим символы из строки
      String fromSymbol = from;
      String toSymbol = to;

      // Удаляем описание если есть
      if (from.contains(' - ')) {
        fromSymbol = from.split(' - ')[0];
      }
      if (to.contains(' - ')) {
        toSymbol = to.split(' - ')[0];
      }

      // Если обе валюты (не крипто) - используем exchange rate API
      final fromIsCrypto = assets.any((a) => a.symbol == fromSymbol && a.type == 'crypto');
      final toIsCrypto = assets.any((a) => a.symbol == toSymbol && a.type == 'crypto');

      if (!fromIsCrypto && !toIsCrypto) {
        // Валюты к валюте
        final result = await _apiService.convertCurrency(fromSymbol, toSymbol, amount);
        return result;
      }

      // Находим активы
      final fromAsset = assets.firstWhere(
            (asset) => asset.symbol == fromSymbol,
        orElse: () {
          // Если не нашли, создаем временный актив
          if (fromSymbol == 'USD') {
            return Asset(
              id: 'USD',
              name: 'US Dollar',
              symbol: 'USD',
              price: 1.0,
              priceChange1h: 0.0,
              priceChange24h: 0.0,
              priceChange7d: 0.0,
              volume24h: 0.0,
              marketCap: 0.0,
              type: 'currency',
            );
          }
          // Для других валют используем exchange rate
          final rate = exchangeRates[fromSymbol] ?? 1.0;
          return Asset(
            id: fromSymbol,
            name: fromSymbol,
            symbol: fromSymbol,
            price: rate,
            priceChange1h: 0.0,
            priceChange24h: 0.0,
            priceChange7d: 0.0,
            volume24h: 0.0,
            marketCap: 0.0,
            type: 'currency',
          );
        },
      );

      final toAsset = assets.firstWhere(
            (asset) => asset.symbol == toSymbol,
        orElse: () {
          // Если не нашли, создаем временный актив
          if (toSymbol == 'USD') {
            return Asset(
              id: 'USD',
              name: 'US Dollar',
              symbol: 'USD',
              price: 1.0,
              priceChange1h: 0.0,
              priceChange24h: 0.0,
              priceChange7d: 0.0,
              volume24h: 0.0,
              marketCap: 0.0,
              type: 'currency',
            );
          }
          // Для других валют используем exchange rate
          final rate = exchangeRates[toSymbol] ?? 1.0;
          return Asset(
            id: toSymbol,
            name: toSymbol,
            symbol: toSymbol,
            price: rate,
            priceChange1h: 0.0,
            priceChange24h: 0.0,
            priceChange7d: 0.0,
            volume24h: 0.0,
            marketCap: 0.0,
            type: 'currency',
          );
        },
      );

      // Конвертация через USD
      // from -> USD -> to
      final fromPriceInUSD = fromAsset.type == 'crypto' ? fromAsset.price : 1.0;
      final toPriceInUSD = toAsset.type == 'crypto' ? toAsset.price : 1.0;

      if (fromAsset.type == 'currency' && toAsset.type == 'currency') {
        // Валюта к валюте
        return (amount / fromAsset.price) * toAsset.price;
      } else if (fromAsset.type == 'crypto' && toAsset.type == 'crypto') {
        // Крипто к крипто
        return (amount * fromPriceInUSD) / toPriceInUSD;
      } else {
        // Смешанная конвертация (крипто-валюта)
        final amountInUSD = fromAsset.type == 'crypto'
            ? amount * fromPriceInUSD
            : amount / fromAsset.price;

        return toAsset.type == 'crypto'
            ? amountInUSD / toPriceInUSD
            : amountInUSD * toAsset.price;
      }
    } catch (e) {
      print('Conversion error: $e');
      throw Exception('Conversion failed: $e');
    }
  }

  // ДОБАВЛЕННЫЙ МЕТОД: Получение списка валют для Dropdown
  List<String> getCurrencyList() {
    final currencyAssets = assets.where((a) => a.type == 'currency').toList();
    return currencyAssets.map((asset) => '${asset.symbol} - ${asset.name}').toList();
  }

  // ДОБАВЛЕННЫЙ МЕТОД: Получение списка криптовалют для Dropdown
  List<String> getCryptoListForDropdown() {
    final cryptoAssets = assets.where((a) => a.type == 'crypto').toList();
    return cryptoAssets.map((asset) => '${asset.symbol} - ${asset.name}').toList();
  }

  // ДОБАВЛЕННЫЙ МЕТОД: Получение всех опций для конвертера
  List<String> getConverterOptions() {
    final allOptions = <String>[];

    // Добавляем валюты
    final currencies = assets.where((a) => a.type == 'currency').toList();
    for (var currency in currencies) {
      allOptions.add('${currency.symbol} - ${currency.name}');
    }

    // Добавляем криптовалюты
    final cryptos = assets.where((a) => a.type == 'crypto').toList();
    for (var crypto in cryptos) {
      allOptions.add('${crypto.symbol} - ${crypto.name}');
    }

    return allOptions;
  }

  // ДОБАВЛЕННЫЙ МЕТОД: Получение актива по ID
  Asset? getAssetById(String id) {
    try {
      return assets.firstWhere((asset) => asset.id == id);
    } catch (e) {
      return null;
    }
  }

  // ДОБАВЛЕННЫЙ МЕТОД: Получение актива по символу
  Asset? getAssetBySymbol(String symbol) {
    try {
      return assets.firstWhere((asset) => asset.symbol == symbol);
    } catch (e) {
      return null;
    }
  }
}