import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/loading_widget.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({Key? key}) : super(key: key);

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _selectedLocation = 'All';
  List<MarketplaceItem> _allItems = [];
  List<MarketplaceItem> _filteredItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMarketplaceData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMarketplaceData() async {
    setState(() => _isLoading = true);
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    _allItems = [
      MarketplaceItem(
        id: '1',
        title: 'Organic Wheat - Premium Quality',
        description: 'Fresh organic wheat harvested from pesticide-free farms',
        price: 2450.0,
        unit: 'per quintal',
        category: 'Grains',
        location: 'Anand, Gujarat',
        sellerName: 'Ramesh Patel',
        sellerRating: 4.8,
        imageUrl: 'assets/images/products/wheat.jpg',
        isOrganic: true,
        quantity: '50 quintals',
        postedDate: DateTime.now().subtract(const Duration(days: 2)),
        type: MarketplaceItemType.sell,
      ),
      MarketplaceItem(
        id: '2',
        title: 'Looking for Cotton Seeds',
        description: 'Need high-quality cotton seeds for 10 acres farming',
        price: 800.0,
        unit: 'per kg',
        category: 'Seeds',
        location: 'Bharuch, Gujarat',
        sellerName: 'Suresh Shah',
        sellerRating: 4.5,
        imageUrl: 'assets/images/products/cotton_seeds.jpg',
        isOrganic: false,
        quantity: '50 kg',
        postedDate: DateTime.now().subtract(const Duration(hours: 12)),
        type: MarketplaceItemType.buy,
      ),
      MarketplaceItem(
        id: '3',
        title: 'Fresh Tomatoes - Direct from Farm',
        description: 'Farm fresh tomatoes, perfect for wholesale buyers',
        price: 25.0,
        unit: 'per kg',
        category: 'Vegetables',
        location: 'Vadodara, Gujarat',
        sellerName: 'Meera Farmer',
        sellerRating: 4.9,
        imageUrl: 'assets/images/products/tomatoes.jpg',
        isOrganic: true,
        quantity: '500 kg',
        postedDate: DateTime.now().subtract(const Duration(hours: 6)),
        type: MarketplaceItemType.sell,
      ),
    ];
    
    _filteredItems = _allItems;
    setState(() => _isLoading = false);
  }

  void _filterItems() {
    setState(() {
      _filteredItems = _allItems.where((item) {
        final matchesSearch = _searchController.text.isEmpty ||
            item.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            item.description.toLowerCase().contains(_searchController.text.toLowerCase());
        
        final matchesCategory = _selectedCategory == 'All' || 
            item.category == _selectedCategory;
        
        final matchesLocation = _selectedLocation == 'All' ||
            item.location.contains(_selectedLocation);
        
        return matchesSearch && matchesCategory && matchesLocation;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(
        title: 'Marketplace',
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterItems();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.cardBackground,
              ),
              onChanged: (value) => _filterItems(),
            ),
          ),

          // Category Filter
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: AppConstants.marketplaceCategories.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                        _filterItems();
                      });
                    },
                    selectedColor: AppColors.primaryColor.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primaryColor : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Tab Bar
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primaryColor,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primaryColor,
            tabs: const [
              Tab(text: 'All Items'),
              Tab(text: 'For Sale'),
              Tab(text: 'Wanted'),
            ],
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const LoadingWidget()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildItemsList(_filteredItems),
                      _buildItemsList(_filteredItems.where((item) => 
                          item.type == MarketplaceItemType.sell).toList()),
                      _buildItemsList(_filteredItems.where((item) => 
                          item.type == MarketplaceItemType.buy).toList()),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddItemDialog,
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Post Item', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildItemsList(List<MarketplaceItem> items) {
    if (items.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadMarketplaceData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildMarketplaceCard(item);
        },
      ),
    );
  }

  Widget _buildMarketplaceCard(MarketplaceItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _openItemDetail(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Item Type Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: item.type == MarketplaceItemType.sell 
                          ? Colors.green.withOpacity(0.1)
                          : Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.type == MarketplaceItemType.sell ? 'FOR SALE' : 'WANTED',
                      style: TextStyle(
                        color: item.type == MarketplaceItemType.sell 
                            ? Colors.green : Colors.blue,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  if (item.isOrganic) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'ORGANIC',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  
                  const Spacer(),
                  
                  Text(
                    _formatTimeAgo(item.postedDate),
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Product Image and Details
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image placeholder
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.image,
                      color: Colors.grey,
                      size: 32,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Details
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

                        // Price and Quantity
                        Row(
                          children: [
                            Text(
                              '₹${item.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              ' ${item.unit}',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        Text(
                          'Quantity: ${item.quantity}',
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

              const SizedBox(height: 12),

              // Seller Info and Actions
              Row(
                children: [
                  // Seller Info
                  Expanded(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                          child: Icon(
                            Icons.person,
                            color: AppColors.primaryColor,
                            size: 16,
                          ),
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.sellerName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: AppColors.textSecondary,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 2),
                                  Expanded(
                                    child: Text(
                                      item.location,
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Rating and Action Buttons
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 14,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            item.sellerRating.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.phone),
                            onPressed: () => _contactSeller(item, 'phone'),
                            iconSize: 20,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chat),
                            onPressed: () => _contactSeller(item, 'chat'),
                            iconSize: 20,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.favorite_border),
                            onPressed: () => _toggleFavorite(item),
                            iconSize: 20,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.store,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No items found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _showAddItemDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Post Your First Item'),
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
    } else {
      return '${difference.inMinutes}m ago';
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Items'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Category:', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              items: AppConstants.marketplaceCategories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            const Text('Location:', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _selectedLocation,
              isExpanded: true,
              items: AppConstants.locations.map((location) {
                return DropdownMenuItem(
                  value: location,
                  child: Text(location),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLocation = value!;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedCategory = 'All';
                _selectedLocation = 'All';
                _filterItems();
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          ElevatedButton(
            onPressed: () {
              _filterItems();
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog() {
    Navigator.pushNamed(context, '/add-marketplace-item');
  }

  void _openItemDetail(MarketplaceItem item) {
    Navigator.pushNamed(context, '/marketplace-item-detail', arguments: item);
  }

  void _contactSeller(MarketplaceItem item, String method) {
    // Implement contact functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Contacting ${item.sellerName} via $method...'),
      ),
    );
  }

  void _toggleFavorite(MarketplaceItem item) {
    // Implement favorite functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Added to favorites'),
      ),
    );
  }
}

enum MarketplaceItemType { sell, buy }

class MarketplaceItem {
  final String id;
  final String title;
  final String description;
  final double price;
  final String unit;
  final String category;
  final String location;
  final String sellerName;
  final double sellerRating;
  final String imageUrl;
  final bool isOrganic;
  final String quantity;
  final DateTime postedDate;
  final MarketplaceItemType type;

  MarketplaceItem({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.unit,
    required this.category,
    required this.location,
    required this.sellerName,
    required this.sellerRating,
    required this.imageUrl,
    required this.isOrganic,
    required this.quantity,
    required this.postedDate,
    required this.type,
  });
}