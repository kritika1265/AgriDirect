import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/weather_card.dart';
import '../widgets/feature_card.dart';
import '../widgets/bottom_nav_bar.dart';
import '../utils/colors.dart';

class HomeScreen extends StatefulWidget {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'AgriDirect',
        showProfile: true,
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

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

  Widget _buildHomeTab() {
    return SingleChildScrollView(
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
  }

  Widget _buildWelcomeSection() {
    return Consumer<AuthProvider>(
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
                color: AppColors.primary.withOpacity(0.3),
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
                  color: AppColors.textOnPrimary.withOpacity(0.9),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickWeatherCard() {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        if (weatherProvider.isLoading) {
          return const WeatherCard.loading();
        }
        
        if (weatherProvider.currentWeather != null) {
          return WeatherCard(
            weather: weatherProvider.currentWeather!,
            onTap: () => _navigateToWeatherScreen(),
          );
        }
        
        return WeatherCard.error(
          onRetry: () => weatherProvider.fetchWeatherData(),
        );
      },
    );
  }

  Widget _buildFeaturesGrid() {
    return Column(
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
              subtitle: 'AI-powered plant diagnosis',
              icon: Icons.medical_services,
              color: AppColors.diseaseCard,
              onTap: () => _navigateToDiseaseDetection(),
            ),
            FeatureCard(
              title: 'Crop Prediction',
              subtitle: 'ML crop recommendations',
              icon: Icons.agriculture,
              color: AppColors.cropCard,
              onTap: () => _navigateToCropPrediction(),
            ),
            FeatureCard(
              title: 'Tool Rental',
              subtitle: 'Rent farming equipment',
              icon: Icons.build,
              color: AppColors.toolCard,
              onTap: () => _navigateToToolRental(),
            ),
            FeatureCard(
              title: 'Smart Connect',
              subtitle: 'Expert consultation',
              icon: Icons.people,
              color: AppColors.newsCard,
              onTap: () => _navigateToSmartConnect(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Column(
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
  }

  Widget _buildActivityItem(String title, String time, IconData icon, Color color) {
    return Container(
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
              color: color.withOpacity(0.1),
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
  }

  Widget _buildWeatherTab() {
    return const Center(
      child: Text('Weather Tab - Navigate to detailed weather screen'),
    );
  }

  Widget _buildToolsTab() {
    return const Center(
      child: Text('Tools Tab - Navigate to tools/marketplace'),
    );
  }

  Widget _buildCommunityTab() {
    return const Center(
      child: Text('Community Tab - Navigate to smart connect'),
    );
  }

  Widget _buildProfileTab() {
    return const Center(
      child: Text('Profile Tab - Navigate to profile screen'),
    );
  }

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