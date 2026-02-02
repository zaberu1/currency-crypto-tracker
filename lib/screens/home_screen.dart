import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/asset_card.dart';
import '../widgets/bottom_nav.dart';
import '../data_provider.dart';
import '../services/auth_service.dart'; // Добавляем сервис аутентификации

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final provider = Provider.of<CurrencyData>(context, listen: false);
    await provider.loadData();
  }

  Future<void> _onRefresh() async {
    setState(() => _isRefreshing = true);
    final provider = Provider.of<CurrencyData>(context, listen: false);
    await provider.refreshData();
    setState(() => _isRefreshing = false);
  }

  // Функция выхода из аккаунта
  Future<void> _logout() async {
    final authService = AuthService();
    await authService.logout();

    // Переходим на экран входа
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  // Функция для показа диалога подтверждения выхода
  Future<void> _showLogoutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Выход из аккаунта',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            'Вы уверены, что хотите выйти из аккаунта?',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                'Отмена',
                style: TextStyle(fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.2),
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.red.withOpacity(0.3)),
                ),
              ),
              child: const Text(
                'Выйти',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          'Currency & Crypto Tracker',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF1E1E1E),
        actions: [
          // Кнопка выхода
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.redAccent.withOpacity(0.1),
                ),
                child: const Icon(
                  Icons.exit_to_app_rounded,
                  color: Colors.redAccent,
                  size: 22,
                ),
              ),
              onPressed: _showLogoutDialog,
              tooltip: 'Выйти из аккаунта',
            ),
          ),
          // Кнопка обновления
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueAccent.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.refresh,
                  color: _isRefreshing ? Colors.grey : Colors.blueAccent,
                ),
              ),
              onPressed: _isRefreshing
                  ? null
                  : () {
                _onRefresh();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Updating prices...'),
                    backgroundColor: Colors.blueAccent,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Consumer<CurrencyData>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.assets.isEmpty) {
            return _buildLoadingView();
          }

          if (provider.error.isNotEmpty) {
            return _buildErrorView(provider);
          }

          final displayAssets = _searchQuery.isEmpty
              ? provider.assets
              : provider.searchAssets(_searchQuery);

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color(0xFF1E1E1E),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search BTC, USD, EUR...',
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 16,
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Icon(
                          Icons.search_rounded,
                          color: Colors.grey[500],
                          size: 24,
                        ),
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: Colors.grey[500],
                          size: 20,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                          : null,
                      border: InputBorder.none,
                      filled: false,
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                  ),
                ),
              ),

              // Stats Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _buildStatCard(
                      title: 'Total',
                      value: displayAssets.length.toString(),
                      color: Colors.blueAccent,
                      icon: Icons.list_alt_rounded,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      title: 'Crypto',
                      value: displayAssets
                          .where((a) => a.type == 'crypto')
                          .length
                          .toString(),
                      color: Colors.orangeAccent,
                      icon: Icons.currency_bitcoin_rounded,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      title: 'Currency',
                      value: displayAssets
                          .where((a) => a.type == 'currency')
                          .length
                          .toString(),
                      color: Colors.greenAccent,
                      icon: Icons.currency_exchange_rounded,
                    ),
                  ],
                ),
              ),

              // Last Update & Search Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Отображаем текущего пользователя
                    FutureBuilder<String?>(
                      future: AuthService().getCurrentUser(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          return Text(
                            'User: ${snapshot.data}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                    Text(
                      'Showing ${displayAssets.length} assets',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      Text(
                        'Search: "$_searchQuery"',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blueAccent,
                        ),
                      ),
                  ],
                ),
              ),

              // Loading indicator
              if (provider.isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Updating prices...',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),

              // Assets List
              Expanded(
                child: displayAssets.isEmpty
                    ? _buildEmptyState(_searchQuery)
                    : RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: Colors.blueAccent,
                  backgroundColor: const Color(0xFF1E1E1E),
                  displacement: 40,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    itemCount: displayAssets.length,
                    separatorBuilder: (context, index) =>
                    const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      return AssetCard(asset: displayAssets[index]);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 0),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.2),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blueAccent.withOpacity(0.1),
            ),
            child: const Icon(
              Icons.currency_exchange_rounded,
              size: 40,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 24),
          const CircularProgressIndicator(
            color: Colors.blueAccent,
            strokeWidth: 2,
          ),
          const SizedBox(height: 20),
          const Text(
            'Fetching Market Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Loading real-time prices...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(CurrencyData provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(0.1),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 50,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Connection Error',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                provider.error.length > 100
                    ? '${provider.error.substring(0, 100)}...'
                    : provider.error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                provider.loadData();
              },
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // Use cached data if available
              },
              child: const Text(
                'Use Offline Data',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String query) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.withOpacity(0.1),
              ),
              child: Icon(
                query.isEmpty ? Icons.currency_bitcoin_rounded : Icons.search_off_rounded,
                size: 50,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              query.isEmpty ? 'No Assets Found' : 'No Results',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              query.isEmpty
                  ? 'Market data will appear here'
                  : 'No assets found for "$query"',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[400],
                height: 1.5,
              ),
            ),
            if (query.isNotEmpty) ...[
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blueAccent,
                  side: const BorderSide(color: Colors.blueAccent),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Clear Search'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}