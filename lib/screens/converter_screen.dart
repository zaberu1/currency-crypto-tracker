import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/bottom_nav.dart';
import '../data_provider.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  String? _fromCurrency;
  String? _toCurrency;
  double _amount = 1.0;
  double _convertedAmount = 0.0;
  bool _isConverting = false;
  String _conversionText = '';
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amountController.text = _amount.toString();
    _amountController.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    final text = _amountController.text;
    if (text.isNotEmpty) {
      final value = double.tryParse(text) ?? 0.0;
      setState(() {
        _amount = value;
      });
    }
  }

  Future<void> _convert() async {
    if (_fromCurrency == null || _toCurrency == null || _amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select currencies and enter amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isConverting = true;
      _conversionText = '';
    });

    try {
      final provider = Provider.of<CurrencyData>(context, listen: false);
      final result = await provider.convert(_fromCurrency!, _toCurrency!, _amount);

      setState(() {
        _convertedAmount = result;
        _conversionText = '$_amount $_fromCurrency = ${result.toStringAsFixed(4)} $_toCurrency';
        _isConverting = false;
      });
    } catch (e) {
      setState(() {
        _conversionText = 'Error: $e';
        _isConverting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Conversion failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
      _conversionText = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CurrencyData>(context);
    final currencyOptions = provider.getCurrencyList();
    final cryptoOptions = provider.getCryptoListForDropdown();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Converter Info'),
                  content: const Text(
                    'Convert between currencies and cryptocurrencies using real-time exchange rates.\n\n'
                        'Note: Crypto-to-crypto conversions are calculated based on USD prices.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Карточка конвертера
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Из какой валюты
                    _buildCurrencySelector(
                      label: 'From',
                      value: _fromCurrency,
                      options: [...currencyOptions, ...cryptoOptions],
                      onChanged: (value) {
                        setState(() {
                          _fromCurrency = value;
                          _conversionText = '';
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // Кнопка swap
                    Center(
                      child: IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Icon(
                            Icons.swap_vert,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        onPressed: _swapCurrencies,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // В какую валюту
                    _buildCurrencySelector(
                      label: 'To',
                      value: _toCurrency,
                      options: [...currencyOptions, ...cryptoOptions],
                      onChanged: (value) {
                        setState(() {
                          _toCurrency = value;
                          _conversionText = '';
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // Сумма
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        prefixIcon: const Icon(Icons.attach_money),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Кнопка конвертации
                    ElevatedButton(
                      onPressed: _isConverting ? null : _convert,
                      child: _isConverting
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                          : const Text('Convert'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Результат конвертации
            if (_conversionText.isNotEmpty)
              Card(
                color: Colors.blueAccent.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Conversion Result',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _conversionText,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_fromCurrency != null && _toCurrency != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '1 $_fromCurrency = ${(_convertedAmount / _amount).toStringAsFixed(6)} $_toCurrency',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Популярные конверсии
            if (currencyOptions.isNotEmpty)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Popular Conversions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 2.5,
                        ),
                        itemCount: _getPopularConversions().length,
                        itemBuilder: (context, index) {
                          final conv = _getPopularConversions()[index];
                          return _buildConversionChip(conv['from']!, conv['to']!);
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 1),
    );
  }

  Widget _buildCurrencySelector({
    required String label,
    required String? value,
    required List<String> options,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).inputDecorationTheme.fillColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              hint: Text('Select $label currency'),
              items: options.map((String option) {
                return DropdownMenuItem<String>(
                  value: option.split(' - ')[0],
                  child: Text(option),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConversionChip(String from, String to) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _fromCurrency = from;
          _toCurrency = to;
          _amount = 1.0;
          _amountController.text = '1';
          _conversionText = '';
        });
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                from,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 16),
              const SizedBox(width: 8),
              Text(
                to,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, String>> _getPopularConversions() {
    return [
      {'from': 'USD', 'to': 'KZT'},
      {'from': 'EUR', 'to': 'KZT'},
      {'from': 'BTC', 'to': 'USD'},
      {'from': 'ETH', 'to': 'USD'},
      {'from': 'USD', 'to': 'EUR'},
      {'from': 'KZT', 'to': 'RUB'},
    ];
  }
}