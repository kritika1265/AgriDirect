// lib/screens/smart_connect_screen.dart
import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_widget.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';

class Expert {
  final String id;
  final String name;
  final String specialization;
  final String experience;
  final double rating;
  final int totalConsultations;
  final String imageUrl;
  final bool isOnline;
  final int consultationFee;
  final List<String> languages;

  Expert({
    required this.id,
    required this.name,
    required this.specialization,
    required this.experience,
    required this.rating,
    required this.totalConsultations,
    required this.imageUrl,
    required this.isOnline,
    required this.consultationFee,
    required this.languages,
  });
}

class CommunityPost {
  final String id;
  final String authorName;
  final String authorLocation;
  final String title;
  final String content;
  final DateTime timestamp;
  final int likes;
  final int replies;
  final String category;
  final List<String> images;

  CommunityPost({
    required this.id,
    required this.authorName,
    required this.authorLocation,
    required this.title,
    required this.content,
    required this.timestamp,
    required this.likes,
    required this.replies,
    required this.category,
    required this.images,
  });
}

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

  Widget _buildCommunityTab() {
    List<CommunityPost> filteredPosts = _selectedCategory == 'All'
        ? _communityPosts
        : _communityPosts.where((post) => post.category == _selectedCategory).toList();

    return Column(
      children: [
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategory == category;
              return ChoiceChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (_) {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                selectedColor: AppColors.primaryColor,
                backgroundColor: Colors.grey[200],
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ),
        Expanded(
          child: filteredPosts.isEmpty
              ? const Center(child: Text('No posts found for this category.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredPosts.length,
                  itemBuilder: (context, index) {
                    return _buildCommunityPostCard(filteredPosts[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCommunityPostCard(CommunityPost post) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300],
                  child: const Icon(Icons.person, size: 24, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      post.authorLocation,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  _formatTimestamp(post.timestamp),
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              post.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              post.content,
              style: const TextStyle(fontSize: 14),
            ),
            if (post.images.isNotEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: post.images.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, idx) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        post.images[idx],
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.thumb_up_alt_outlined, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('${post.likes}'),
                const SizedBox(width: 16),
                Icon(Icons.chat_bubble_outline, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('${post.replies}'),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    post.category,
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
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
                // Add the missing _buildAskQuestionTab method at the end of the class
                
                  Widget _buildAskQuestionTab() {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ask a Question',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _questionController,
                            hintText: 'Type your question here...',
                            maxLines: 5,
                          ),
                          const SizedBox(height: 16),
                          _isLoading
                              ? const LoadingWidget()
                              : CustomButton(
                                  text: 'Submit',
                                  onPressed: _submitQuestion,
                                  backgroundColor: AppColors.primaryColor,
                                  textColor: Colors.white,
                                ),
                        ],
                      ),
                    );
                  }
                
                  void _submitQuestion() {
                    setState(() {
                      _isLoading = true;
                    });
                    // Simulate a network call
                    Future.delayed(const Duration(seconds: 2), () {
                      setState(() {
                        _isLoading = false;
                        _questionController.clear();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Your question has been submitted!')),
                      );
                    });
                  }