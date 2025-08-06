import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/weather_provider.dart';
import '../utils/colors.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/feature_card.dart';
import '../widgets/weather_card.dart';

/// Home screen widget that displays the main dashboard
class HomeScreen extends StatefulWidget {
  /// Creates a HomeScreen widget
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    context.read<WeatherProvider>().fetchWeatherData();
  }

  /// Returns the list of navigation items for the bottom navigation bar
  List<BottomNavItem> _getNavItems() => [
    BottomNavItem(icon: Icons.home, label: 'Home'),
    BottomNavItem(icon: Icons.cloud, label: 'Weather'),
    BottomNavItem(icon: Icons.build, label: 'Tools'),
    BottomNavItem(icon: Icons.people, label: 'Community'),
    BottomNavItem(icon: Icons.person, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const CustomAppBar(
      title: 'AgriDirect',
    ),
    body: _buildBody(),
    bottomNavigationBar: BottomNavBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      items: _getNavItems(),
    ),
  );

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildWeatherTab();
      case 2:
        return _buildToolsTab();
      case 3:
        return _buildCommunityTab();
      case 4:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            const SizedBox(height: 24),
            _buildQuickWeatherCard(),
            const SizedBox(height: 24),
            _buildFeaturesGrid(),
            const SizedBox(height: 24),
            _buildRecentActivity(),
          ],
        ),
      );

  Widget _buildWelcomeSection() => Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          final userName = user?.name.isNotEmpty == true ? user!.name : 'Farmer';

          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, $userName!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textOnPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Let\'s make your farming smarter today',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textOnPrimary.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          );
        },
      );

  Widget _buildQuickWeatherCard() => Consumer<WeatherProvider>(
        builder: (context, weatherProvider, child) {
          if (weatherProvider.isLoading) {
            // Create a loading weather card with required parameters
            return WeatherCard(
              location: 'Loading...',
              temperature: '--°C',
              condition: 'Loading',
              humidity: '--',
              windSpeed: '--',
              weatherIcon: Icons.cloud,
              onTap: () => _navigateToWeatherScreen(),
            );
          }

          if (weatherProvider.currentWeather != null) {
            final weather = weatherProvider.currentWeather!;
            return WeatherCard(
              location: weather.location,
              temperature: '${weather.temperature}°C',
              condition: weather.condition,
              humidity: '${weather.humidity}%',
              windSpeed: '${weather.windSpeed} km/h',
              weatherIcon: _getWeatherIcon(weather.condition),
              onTap: () => _navigateToWeatherScreen(),
            );
          }

          // Create an error state weather card
          return WeatherCard(
            location: 'Error',
            temperature: '--°C',
            condition: 'Unable to load',
            humidity: '--',
            windSpeed: '--',
            weatherIcon: Icons.error,
            onTap: () => weatherProvider.fetchWeatherData(),
          );
        },
      );

  IconData _getWeatherIcon(String? condition) {
    switch (condition?.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return Icons.wb_sunny;
      case 'cloudy':
      case 'overcast':
        return Icons.cloud;
      case 'rainy':
      case 'rain':
        return Icons.water_drop;
      case 'stormy':
        return Icons.thunderstorm;
      default:
        return Icons.cloud;
    }
  }

  Widget _buildFeaturesGrid() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Smart Farming Tools',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              FeatureCard(
                title: 'Disease Detection',
                description: 'AI-powered plant diagnosis',
                icon: Icons.medical_services,
                onTap: () => _navigateToDiseaseDetection(),
              ),
              FeatureCard(
                title: 'Crop Prediction',
                description: 'ML crop recommendations',
                icon: Icons.agriculture,
                onTap: () => _navigateToCropPrediction(),
              ),
              FeatureCard(
                title: 'Tool Rental',
                description: 'Rent farming equipment',
                icon: Icons.build,
                onTap: () => _navigateToToolRental(),
              ),
              FeatureCard(
                title: 'Smart Connect',
                description: 'Expert consultation',
                icon: Icons.people,
                onTap: () => _navigateToSmartConnect(),
              ),
            ],
          ),
        ],
      );

  Widget _buildRecentActivity() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () => _navigateToActivity(),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildActivityItem(
            'Disease detected in tomato plants',
            'Yesterday, 2:30 PM',
            Icons.warning,
            AppColors.warning,
          ),
          _buildActivityItem(
            'Weather alert: Heavy rain expected',
            'Today, 8:00 AM',
            Icons.cloud,
            AppColors.info,
          ),
          _buildActivityItem(
            'Crop calendar reminder: Fertilizer application',
            '2 days ago',
            Icons.event,
            AppColors.success,
          ),
        ],
      );

  Widget _buildActivityItem(String title, String time, IconData icon, Color color) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.divider),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildWeatherTab() => const Center(
        child: Text('Weather Tab - Navigate to detailed weather screen'),
      );

  Widget _buildToolsTab() => const Center(
        child: Text('Tools Tab - Navigate to tools/marketplace'),
      );

  Widget _buildCommunityTab() => const Center(
        child: Text('Community Tab - Navigate to smart connect'),
      );

  Widget _buildProfileTab() => const Center(
        child: Text('Profile Tab - Navigate to profile screen'),
      );

  // Navigation methods
  void _navigateToWeatherScreen() {
    Navigator.pushNamed(context, '/weather');
  }

  void _navigateToDiseaseDetection() {
    Navigator.pushNamed(context, '/disease-detection');
  }

  void _navigateToCropPrediction() {
    Navigator.pushNamed(context, '/crop-prediction');
  }

  void _navigateToToolRental() {
    Navigator.pushNamed(context, '/rent-tools');
  }

  void _navigateToSmartConnect() {
    Navigator.pushNamed(context, '/smart-connect');
  }

  void _navigateToActivity() {
    Navigator.pushNamed(context, '/activity');
  }
}