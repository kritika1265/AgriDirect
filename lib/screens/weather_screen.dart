// lib/screens/weather_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/weather_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/chart_widgets.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../models/weather_model.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WeatherProvider>(context, listen: false).fetchWeatherData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Weather Forecast',
        showBackButton: true,
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, weatherProvider, child) {
          if (weatherProvider.isLoading) {
            return const Center(
              child: LoadingWidget(message: 'Fetching weather data...'),
            );
          }

          if (weatherProvider.error != null) {
            return _buildErrorState(weatherProvider);
          }

          if (weatherProvider.currentWeather == null) {
            return _buildNoDataState();
          }

          return Column(
            children: [
              _buildCurrentWeatherHeader(weatherProvider.currentWeather!),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTodayTab(weatherProvider),
                    _buildForecastTab(weatherProvider),
                    _buildChartsTab(weatherProvider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCurrentWeatherHeader(Weather currentWeather) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryGreen,
            AppColors.lightGreen,
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentWeather.location,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDateTime(currentWeather.timestamp),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Icon(
                _getWeatherIcon(currentWeather.condition),
                color: Colors.white,
                size: 40,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWeatherStat(
                'Temperature',
                '${currentWeather.temperature.toInt()}°C',
                Icons.thermostat,
              ),
              _buildWeatherStat(
                'Humidity',
                '${currentWeather.humidity.toInt()}%',
                Icons.water_drop,
              ),
              _buildWeatherStat(
                'Wind',
                '${currentWeather.windSpeed.toInt()} km/h',
                Icons.air,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primaryGreen,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppColors.primaryGreen,
        tabs: const [
          Tab(text: 'Today', icon: Icon(Icons.today)),
          Tab(text: 'Forecast', icon: Icon(Icons.calendar_month)),
          Tab(text: 'Charts', icon: Icon(Icons.show_chart)),
        ],
      ),
    );
  }

  Widget _buildTodayTab(WeatherProvider weatherProvider) {
    final currentWeather = weatherProvider.currentWeather!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Current Conditions'),
          const SizedBox(height: 12),
          _buildConditionsGrid(currentWeather),
          const SizedBox(height: 24),
          _buildSectionTitle('Agricultural Insights'),
          const SizedBox(height: 12),
          _buildAgriculturalInsights(currentWeather),
          const SizedBox(height: 24),
          _buildSectionTitle('Recommendations'),
          const SizedBox(height: 12),
          _buildRecommendations(currentWeather),
        ],
      ),
    );
  }

  Widget _buildConditionsGrid(Weather weather) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildConditionCard(
          'Feels Like',
          '${weather.feelsLike?.toInt() ?? weather.temperature.toInt()}°C',
          Icons.thermostat,
          AppColors.accentOrange,
        ),
        _buildConditionCard(
          'UV Index',
          weather.uvIndex?.toString() ?? 'N/A',
          Icons.sunny,
          Colors.amber,
        ),
        _buildConditionCard(
          'Pressure',
          '${weather.pressure?.toInt() ?? 1013} hPa',
          Icons.compress,
          Colors.blue,
        ),
        _buildConditionCard(
          'Visibility',
          '${weather.visibility?.toInt() ?? 10} km',
          Icons.visibility,
          Colors.teal,
        ),
      ],
    );
  }

  Widget _buildConditionCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgriculturalInsights(Weather weather) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGreen),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.agriculture, color: AppColors.primaryGreen),
              const SizedBox(width: 8),
              Text(
                'Farming Conditions',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInsightRow(
            'Irrigation',
            _getIrrigationAdvice(weather),
            _getIrrigationIcon(weather),
          ),
          _buildInsightRow(
            'Pest Risk',
            _getPestRiskLevel(weather),
            _getPestRiskIcon(weather),
          ),
          _buildInsightRow(
            'Disease Risk',
            _getDiseaseRiskLevel(weather),
            _getDiseaseRiskIcon(weather),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildRecommendations(Weather weather) {
    final recommendations = _getWeatherRecommendations(weather);
    
    return Column(
      children: recommendations.map((rec) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.lightbulb, color: Colors.blue, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(rec)),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildForecastTab(WeatherProvider weatherProvider) {
    if (weatherProvider.forecast.isEmpty) {
      return const Center(
        child: Text('No forecast data available'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: weatherProvider.forecast.length,
      itemBuilder: (context, index) {
        final weather = weatherProvider.forecast[index];
        return WeatherCard(
          weather: weather,
          showDetails: true,
        );
      },
    );
  }

  Widget _buildChartsTab(WeatherProvider weatherProvider) {
    if (weatherProvider.forecast.isEmpty) {
      return const Center(
        child: Text('No data available for charts'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSectionTitle('Temperature Trend'),
          const SizedBox(height: 12),
          WeatherChart(
            data: weatherProvider.forecast,
            type: WeatherChartType.temperature,
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Humidity & Rainfall'),
          const SizedBox(height: 12),
          WeatherChart(
            data: weatherProvider.forecast,
            type: WeatherChartType.humidity,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildErrorState(WeatherProvider weatherProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading weather data',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            weatherProvider.error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => weatherProvider.fetchWeatherData(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No weather data available',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Please check your internet connection and try again',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Helper methods
  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return Icons.wb_sunny;
      case 'cloudy':
      case 'overcast':
        return Icons.cloud;
      case 'rainy':
      case 'rain':
        return Icons.umbrella;
      case 'stormy':
      case 'thunderstorm':
        return Icons.flash_on;
      case 'snowy':
      case 'snow':
        return Icons.ac_unit;
      default:
        return Icons.wb_cloudy;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    return '${days[dateTime.weekday - 1]}, ${dateTime.day} ${months[dateTime.month - 1]}';
  }

  String _getIrrigationAdvice(Weather weather) {
    if (weather.rainfall > 10) return 'Not needed';
    if (weather.humidity < 40) return 'Required';
    return 'Monitor soil';
  }

  IconData _getIrrigationIcon(Weather weather) {
    if (weather.rainfall > 10) return Icons.check_circle;
    if (weather.humidity < 40) return Icons.water_drop;
    return Icons.visibility;
  }

  String _getPestRiskLevel(Weather weather) {
    if (weather.temperature > 30 && weather.humidity > 70) return 'High';
    if (weather.temperature > 25 && weather.humidity > 60) return 'Medium';
    return 'Low';
  }

  IconData _getPestRiskIcon(Weather weather) {
    final risk = _getPestRiskLevel(weather);
    switch (risk) {
      case 'High': return Icons.warning;
      case 'Medium': return Icons.info;
      default: return Icons.check_circle;
    }
  }

  String _getDiseaseRiskLevel(Weather weather) {
    if (weather.humidity > 80 && weather.temperature > 20) return 'High';
    if (weather.humidity > 60 && weather.temperature > 15) return 'Medium';
    return 'Low';
  }

  IconData _getDiseaseRiskIcon(Weather weather) {
    final risk = _getDiseaseRiskLevel(weather);
    switch (risk) {
      case 'High': return Icons.warning;
      case 'Medium': return Icons.info;
      default: return Icons.check_circle;
    }
  }

  List<String> _getWeatherRecommendations(Weather weather) {
    final recommendations = <String>[];
    
    if (weather.rainfall > 20) {
      recommendations.add('Heavy rain expected - ensure proper drainage');
    }
    
    if (weather.windSpeed > 25) {
      recommendations.add('Strong winds - secure plant supports');
    }
    
    if (weather.temperature > 35) {
      recommendations.add('High temperature - provide shade for sensitive crops');
    }
    
    if (weather.humidity < 30) {
      recommendations.add('Low humidity - increase irrigation frequency');
    }
    
    if (recommendations.isEmpty) {
      recommendations.add('Good weather conditions for farming activities');
    }
    
    return recommendations;
  }
}