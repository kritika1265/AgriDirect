// lib/screens/rent_tools_screen.dart
import 'package:flutter/material.dart';
import '../models/tool_model.dart';
import '../models/rental_model.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_card.dart';
import '../widgets/loading_widget.dart';

/// Screen for renting agricultural tools
class RentToolsScreen extends StatefulWidget {
  /// Creates a new rent tools screen
  const RentToolsScreen({super.key});

  @override
  State<RentToolsScreen> createState() => _RentToolsScreenState();
}

class _RentToolsScreenState extends State<RentToolsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ToolModel> _availableTools = [];
  List<RentalModel> _myRentals = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All', 'Tractors', 'Harvesters', 'Plows', 'Sprayers', 'Irrigation', 'Others'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate API call
    await Future<void>.delayed(const Duration(seconds: 2));
    
    // Mock data
    _availableTools = [
      ToolModel(
        id: '1',
        name: 'John Deere Tractor 5050D',
        category: 'Tractors',
        description: '50 HP tractor suitable for medium farming operations',
        pricePerDay: 2500,
        location: 'Anand, Gujarat',
        imageUrl: 'assets/images/tools/tractor.png',
        ownerName: 'Ramesh Patel',
        ownerPhone: '+91 98765 43210',
        isAvailable: true,
        rating: 4.5,
        totalRatings: 23,
      ),
      ToolModel(
        id: '2',
        name: 'Combine Harvester',
        category: 'Harvesters',
        description: 'Modern combine harvester for wheat and rice',
        pricePerDay: 5000,
        location: 'Bharuch, Gujarat',
        imageUrl: 'assets/images/tools/harvester.png',
        ownerName: 'Suresh Shah',
        ownerPhone: '+91 98765 43211',
        isAvailable: true,
        rating: 4.8,
        totalRatings: 15,
      ),
      ToolModel(
        id: '3',
        name: 'Power Sprayer',
        category: 'Sprayers',
        description: 'High-pressure sprayer for pesticides and fertilizers',
        pricePerDay: 800,
        location: 'Vadodara, Gujarat',
        imageUrl: 'assets/images/tools/sprayer.png',
        ownerName: 'Kiran Modi',
        ownerPhone: '+91 98765 43212',
        isAvailable: false,
        rating: 4.2,
        totalRatings: 31,
      ),
    ];

    _myRentals = [
      RentalModel(
        id: '1',
        toolId: '1',
        toolName: 'John Deere Tractor 5050D',
        ownerName: 'Ramesh Patel',
        startDate: DateTime.now().subtract(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 1)),
        totalAmount: 7500,
        status: RentalStatus.active,
        location: 'Anand, Gujarat',
      ),
    ];

    setState(() {
      _isLoading = false;
    });
  }

  List<ToolModel> get _filteredTools {
    if (_selectedCategory == 'All') {
      return _availableTools;
    }
    return _availableTools.where((tool) => tool.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const CustomAppBar(title: 'Rent Tools'),
    body: Column(
      children: [
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAvailableToolsTab(),
              _buildMyRentalsTab(),
            ],
          ),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: _showAddToolDialog,
      backgroundColor: AppColors.primaryColor,
      child: const Icon(Icons.add, color: Colors.white),
    ),
  );

  Widget _buildTabBar() => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withValues(alpha: 0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: TabBar(
      controller: _tabController,
      labelColor: AppColors.primaryColor,
      unselectedLabelColor: Colors.grey[600],
      indicatorColor: AppColors.primaryColor,
      tabs: const [
        Tab(text: 'Available Tools'),
        Tab(text: 'My Rentals'),
      ],
    ),
  );

  Widget _buildAvailableToolsTab() {
    if (_isLoading) {
      return const Center(child: LoadingWidget());
    }

    return Column(
      children: [
        _buildCategoryFilter(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredTools.length,
              itemBuilder: (context, index) => _buildToolCard(_filteredTools[index]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() => Container(
    height: 60,
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        final isSelected = category == _selectedCategory;
        
        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: FilterChip(
            label: Text(category),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _selectedCategory = category;
              });
            },
            backgroundColor: Colors.grey[100],
            selectedColor: AppColors.primaryColor.withValues(alpha: 0.2),
            labelStyle: TextStyle(
              color: isSelected ? AppColors.primaryColor : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        );
      },
    ),
  );

  Widget _buildToolCard(ToolModel tool) => CustomCard(
    margin: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey[300],
                child: const Icon(Icons.agriculture, size: 80, color: Colors.grey),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: tool.isAvailable ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tool.isAvailable ? 'Available' : 'Rented',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tool.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tool.category,
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                tool.description,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    tool.location,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    tool.ownerName,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text('${tool.rating} (${tool.totalRatings})'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '₹${tool.pricePerDay.toStringAsFixed(0)}/day',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  CustomButton(
                    text: tool.isAvailable ? 'Rent Now' : 'Not Available',
                    onPressed: tool.isAvailable ? () => _showRentDialog(tool) : null,
                    backgroundColor: tool.isAvailable ? AppColors.primaryColor : Colors.grey,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildMyRentalsTab() {
    if (_isLoading) {
      return const Center(child: LoadingWidget());
    }

    if (_myRentals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Active Rentals',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your rented tools will appear here',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _myRentals.length,
        itemBuilder: (context, index) => _buildRentalCard(_myRentals[index]),
      ),
    );
  }

  Color _getRentalStatusColor(RentalStatus status) {
    switch (status) {
      case RentalStatus.active:
        return Colors.green;
      case RentalStatus.completed:
        return Colors.blue;
      case RentalStatus.cancelled:
        return Colors.red;
      case RentalStatus.pending:
        return Colors.orange;
    }
  }

  Widget _buildRentalCard(RentalModel rental) => CustomCard(
    margin: const EdgeInsets.only(bottom: 16),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  rental.toolName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getRentalStatusColor(rental.status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getRentalStatusText(rental.status),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Owner: ${rental.ownerName}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            'Location: ${rental.location}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start Date',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _formatDate(rental.startDate),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'End Date',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _formatDate(rental.endDate),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total Amount',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '₹${rental.totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (rental.status == RentalStatus.active) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Extend Rental',
                    onPressed: () => _showExtendDialog(rental),
                    backgroundColor: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Return Tool',
                    onPressed: () => _showReturnDialog(rental),
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ),
  );

  String _getRentalStatusText(RentalStatus status) {
    switch (status) {
      case RentalStatus.active:
        return 'Active';
      case RentalStatus.completed:
        return 'Completed';
      case RentalStatus.cancelled:
        return 'Cancelled';
      case RentalStatus.pending:
        return 'Pending';
    }
  }

  // Helper method to format dates
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showRentDialog(ToolModel tool) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rent ${tool.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Price: ₹${tool.pricePerDay}/day'),
            const SizedBox(height: 8),
            Text('Owner: ${tool.ownerName}'),
            const SizedBox(height: 8),
            Text('Location: ${tool.location}'),
            const SizedBox(height: 16),
            const Text('Contact owner to confirm rental details and pickup arrangements.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Launch phone dialer
              _contactOwner(tool.ownerPhone);
            },
            child: const Text('Contact Owner'),
          ),
        ],
      ),
    );
  }

  void _showExtendDialog(RentalModel rental) {
    // Implementation for extending rental
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Extend Rental'),
        content: const Text('Feature coming soon! Contact the owner directly to extend your rental.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showReturnDialog(RentalModel rental) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Return Tool'),
        content: const Text('Are you sure you want to mark this tool as returned? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _returnTool(rental);
            },
            child: const Text('Return Tool'),
          ),
        ],
      ),
    );
  }

  void _showAddToolDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('List Your Tool'),
        content: const Text('Feature coming soon! You will be able to list your agricultural tools for rent.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _contactOwner(String phoneNumber) {
    // Implementation to launch phone dialer
    // You can use url_launcher package for this
    debugPrint('Calling $phoneNumber');
  }

  void _returnTool(RentalModel rental) {
    setState(() {
      rental.status = RentalStatus.completed;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tool marked as returned successfully!')),
    );
  }
}