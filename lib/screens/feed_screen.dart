import 'package:flutter/material.dart';

import '../models/news_item.dart';
import '../services/api_service.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/loading_widget.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<NewsItem> _newsItems = [];
  List<NewsItem> _tipsItems = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFeedData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFeedData() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }
    
    try {
      // Simulate API calls
      await Future<void>.delayed(const Duration(seconds: 1));
      
      // Mock data - replace with actual API service calls
      final newsItems = [
        NewsItem(
          id: '1',
          title: 'New Drought-Resistant Wheat Variety Released',
          description: 'Scientists develop breakthrough wheat variety for harsh conditions',
          content: 'Agricultural scientists have developed a new wheat variety that can withstand prolonged drought conditions...',
          category: 'Research',
          imageUrl: 'assets/images/news/wheat_research.jpg',
          publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
          source: 'AgriNews',
          url: 'https://example.com/news/1',
          tags: ['wheat', 'drought', 'research', 'agriculture'],
        ),
        NewsItem(
          id: '2',
          title: 'Organic Farming Subsidies Increased by 25%',
          description: 'Government boosts support for sustainable farming practices',
          content: 'Government announces increased subsidies for organic farming practices to promote sustainable agriculture...',
          category: 'Policy',
          imageUrl: 'assets/images/news/organic_farming.jpg',
          publishedAt: DateTime.now().subtract(const Duration(hours: 5)),
          source: 'FarmPolicy Today',
          url: 'https://example.com/news/2',
          tags: ['organic', 'subsidies', 'policy', 'government'],
        ),
      ];

      final tipsItems = [
        NewsItem(
          id: '3',
          title: 'Best Practices for Monsoon Crop Protection',
          description: 'Essential guidelines for protecting crops during heavy rainfall',
          content: 'Essential tips to protect your crops during heavy rainfall and flooding conditions...',
          category: 'Tips',
          imageUrl: 'assets/images/tips/monsoon_tips.jpg',
          publishedAt: DateTime.now().subtract(const Duration(days: 1)),
          source: 'AgriExpert',
          url: 'https://example.com/tips/1',
          tags: ['monsoon', 'protection', 'crops', 'weather'],
        ),
      ];

      if (mounted) {
        setState(() {
          _newsItems = newsItems;
          _tipsItems = tipsItems;
        });
      }
    } catch (e) {
      // Handle error
      debugPrint('Error loading feed data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(
        title: 'News & Updates',
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFeedData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter Chips
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: AppConstants.newsCategories.map((String category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (mounted) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      }
                    },
                    selectedColor: AppColors.primaryColor.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primaryColor : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Tab Bar
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primaryColor,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primaryColor,
            tabs: const [
              Tab(text: 'Latest News'),
              Tab(text: 'Farming Tips'),
              Tab(text: 'Market Updates'),
            ],
          ),
          
          // Tab Views
          Expanded(
            child: _isLoading
                ? const LoadingWidget()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildNewsList(_newsItems),
                      _buildTipsList(_tipsItems),
                      _buildMarketUpdates(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsList(List<NewsItem> items) {
    if (items.isEmpty) {
      return _buildEmptyState('No news available');
    }

    return RefreshIndicator(
      onRefresh: _loadFeedData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildNewsCard(item);
        },
      ),
    );
  }

  Widget _buildTipsList(List<NewsItem> items) {
    if (items.isEmpty) {
      return _buildEmptyState('No tips available');
    }

    return RefreshIndicator(
      onRefresh: _loadFeedData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildTipCard(item);
        },
      ),
    );
  }

  Widget _buildMarketUpdates() {
    return RefreshIndicator(
      onRefresh: _loadFeedData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMarketCard('Wheat', '₹2,450/quintal', '+2.5%', Colors.green),
          _buildMarketCard('Rice', '₹3,200/quintal', '-1.2%', Colors.red),
          _buildMarketCard('Maize', '₹1,850/quintal', '+0.8%', Colors.green),
          _buildMarketCard('Cotton', '₹5,680/quintal', '+3.2%', Colors.green),
        ],
      ),
    );
  }

  Widget _buildNewsCard(NewsItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _openNewsDetail(item),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                color: AppColors.cardBackground,
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: item.imageUrl.isNotEmpty
                    ? Image.asset(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.image, size: 48, color: Colors.grey),
                          );
                        },
                      )
                    : const Center(
                        child: Icon(Icons.image, size: 48, color: Colors.grey),
                      ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category and Time
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item.category,
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatTimeAgo(item.publishedAt),
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Title
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Content preview
                  Text(
                    item.description,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Source and actions
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Source: ${item.source}',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.share, size: 20),
                        onPressed: () => _shareNews(item),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.bookmark_border, size: 20),
                        onPressed: () => _bookmarkNews(item),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(NewsItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _openNewsDetail(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  Icons.lightbulb,
                  color: AppColors.primaryColor,
                  size: 28,
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      item.description,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      _formatTimeAgo(item.publishedAt),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMarketCard(String commodity, String price, String change, Color changeColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.grain,
                color: AppColors.primaryColor,
                size: 20,
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    commodity,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    price,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: changeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                change,
                style: TextStyle(
                  color: changeColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.article_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showFilterDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Category'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: AppConstants.newsCategories.map((String category) {
              return RadioListTile<String>(
                title: Text(category),
                value: category,
                groupValue: _selectedCategory,
                onChanged: (String? value) {
                  if (mounted && value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                    Navigator.pop(context);
                  }
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _openNewsDetail(NewsItem item) {
    // Navigate to news detail screen
    Navigator.pushNamed(context, '/news-detail', arguments: item);
  }

  void _shareNews(NewsItem item) {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing: ${item.title}')),
    );
  }

  void _bookmarkNews(NewsItem item) {
    // Implement bookmark functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bookmarked: ${item.title}')),
    );
  }
}