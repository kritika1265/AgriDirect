// lib/screens/smart_connect_screen.dart
import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_widget.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';

class SmartConnectScreen extends StatefulWidget {
  const SmartConnectScreen({Key? key}) : super(key: key);

  @override
  State<SmartConnectScreen> createState() => _SmartConnectScreenState();
}

class _SmartConnectScreenState extends State<SmartConnectScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _questionController = TextEditingController();
  bool _isLoading = false;
  
  final List<Expert> _experts = [
    Expert(
      id: '1',
      name: 'Dr. Rajesh Kumar',
      specialization: 'Crop Disease Management',
      experience: '15 years',
      rating: 4.8,
      totalConsultations: 1250,
      imageUrl: 'assets/images/experts/expert1.png',
      isOnline: true,
      consultationFee: 500,
      languages: ['Hindi', 'English', 'Gujarati'],
    ),
    Expert(
      id: '2',
      name: 'Dr. Priya Sharma',
      specialization: 'Soil Health & Nutrition',
      experience: '12 years',
      rating: 4.9,
      totalConsultations: 980,
      imageUrl: 'assets/images/experts/expert2.png',
      isOnline: false,
      consultationFee: 600,
      languages: ['Hindi', 'English'],
    ),
    Expert(
      id: '3',
      name: 'Kisan Bhai Patel',
      specialization: 'Organic Farming',
      experience: '20 years',
      rating: 4.7,
      totalConsultations: 2100,
      imageUrl: 'assets/images/experts/expert3.png',
      isOnline: true,
      consultationFee: 400,
      languages: ['Gujarati', 'Hindi'],
    ),
  ];

  final List<CommunityPost> _communityPosts = [
    CommunityPost(
      id: '1',
      authorName: 'Ramesh Patel',
      authorLocation: 'Anand, Gujarat',
      title: 'Brown spots on tomato leaves - need help!',
      content: 'I noticed brown spots appearing on my tomato plants. The spots are getting bigger each day. Has anyone faced this issue before?',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      likes: 12,
      replies: 5,
      category: 'Disease Management',
      images: ['assets/images/posts/tomato_disease.jpg'],
    ),
    CommunityPost(
      id: '2',
      authorName: 'Suresh Shah',
      authorLocation: 'Bharuch, Gujarat',
      title: 'Best fertilizer for wheat crop?',
      content: 'Looking for recommendations on the best fertilizer for wheat cultivation. My soil test shows nitrogen deficiency.',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      likes: 8,
      replies: 15,
      category: 'Fertilizers',
      images: [],
    ),
  ];

  final List<String> _categories = [
    'All', 'Disease Management', 'Fertilizers', 'Irrigation', 'Pest Control', 'Crop Care', 'Others'
  ];

  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Smart Connect'),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildExpertsTab(),
                _buildCommunityTab(),
                _buildAskQuestionTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
          Tab(text: 'Experts'),
          Tab(text: 'Community'),
          Tab(text: 'Ask Question'),
        ],
      ),
    );
  }

  Widget _buildExpertsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _experts.length,
      itemBuilder: (context, index) {
        return _buildExpertCard(_experts[index]);
      },
    );
  }

  Widget _buildExpertCard(Expert expert) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey[300],
                      child: const Icon(Icons.person, size: 40, color: Colors.grey),
                    ),
                    if (expert.isOnline)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expert.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        expert.specialization,
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${expert.experience} experience',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      expert.isOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                        color: expert.isOnline ? Colors.green : Colors.grey,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          expert.rating.toString(),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Consultations: ${expert.totalConsultations}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Languages: ${expert.languages.join(', ')}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${expert.consultationFee}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const Text(
                      'per consultation',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'View Profile',
                    onPressed: () => _viewExpertProfile(expert),
                    backgroundColor: Colors.grey[200]!,
                    textColor: Colors.black87,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: expert.isOnline ? 'Consult Now' : 'Schedule',
                    onPressed: () => _consult