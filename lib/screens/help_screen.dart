import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_card.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<FAQItem> _faqItems = [];
  List<FAQItem> _filteredFAQs = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFAQs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadFAQs() {
    _faqItems = [
      FAQItem(
        category: 'General',
        question: 'How do I use the disease detection feature?',
        answer: 'To use disease detection, go to the Disease Detection screen, tap the camera icon, and take a clear photo of the affected plant part. The AI will analyze the image and provide diagnosis results.',
      ),
      FAQItem(
        category: 'General',
        question: 'How accurate is the crop recommendation?',
        answer: 'Our crop recommendation system uses machine learning algorithms with 85-90% accuracy based on soil conditions, weather patterns, and regional data.',
      ),
      FAQItem(
        category: 'Technical',
        question: 'Why is my location not being detected?',
        answer: 'Please ensure location permissions are enabled for AgriDirect in your device settings. Also check if your GPS is turned on.',
      ),
      FAQItem(
        category: 'Account',
        question: 'How do I reset my password?',
        answer: 'You can reset your password by tapping "Forgot Password" on the login screen and following the instructions sent to your registered mobile number.',
      ),
      FAQItem(
        category: 'Features',
        question: 'Can I use the app offline?',
        answer: 'Some features like saved crop calendar and farming tips work offline. However, weather updates, disease detection, and marketplace require internet connection.',
      ),
    ];
    _filteredFAQs = _faqItems;
  }

  void _filterFAQs(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredFAQs = _faqItems;
      } else {
        _filteredFAQs = _faqItems.where((faq) {
          return faq.question.toLowerCase().contains(query.toLowerCase()) ||
                 faq.answer.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: const CustomAppBar(title: 'Help & Support'),
      body: Column(
        children: [
          // Quick Actions
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    'Call Support',
                    Icons.phone,
                    AppColors.primaryColor,
                    () => _makePhoneCall(AppConstants.supportPhoneNumber),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionCard(
                    'WhatsApp',
                    Icons.chat,
                    Colors.green,
                    () => _openWhatsApp(AppConstants.supportWhatsAppNumber),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionCard(
                    'Email Us',
                    Icons.email,
                    Colors.blue,
                    () => _sendEmail(AppConstants.supportEmail),
                  ),
                ),
              ],
            ),
          ),

          // Tab Bar
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primaryColor,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primaryColor,
            tabs: const [
              Tab(text: 'FAQ'),
              Tab(text: 'Tutorials'),
              Tab(text: 'Contact'),
            ],
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFAQTab(),
                _buildTutorialsTab(),
                _buildContactTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return CustomCard(
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFAQTab() {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search FAQs...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _filterFAQs('');
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
            onChanged: _filterFAQs,
          ),
        ),

        // FAQ List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filteredFAQs.length,
            itemBuilder: (context, index) {
              final faq = _filteredFAQs[index];
              return _buildFAQItem(faq);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFAQItem(FAQItem faq) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ExpansionTile(
        title: Text(
          faq.question,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.help_outline,
            color: AppColors.primaryColor,
            size: 18,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(56, 0, 16, 16),
            child: Text(
              faq.answer,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialsTab() {
    final tutorials = [
      TutorialItem(
        title: 'Getting Started with AgriDirect',
        description: 'Learn the basics of using the app',
        duration: '5 min',
        icon: Icons.play_circle_filled,
        videoUrl: 'https://example.com/tutorial1',
      ),
      TutorialItem(
        title: 'Using Disease Detection',
        description: 'Step-by-step guide to detect plant diseases',
        duration: '8 min',
        icon: Icons.camera_alt,
        videoUrl: 'https://example.com/tutorial2',
      ),
      TutorialItem(
        title: 'Crop Recommendation Feature',
        description: 'How to get personalized crop suggestions',
        duration: '6 min',
        icon: Icons.agriculture,
        videoUrl: 'https://example.com/tutorial3',
      ),
      TutorialItem(
        title: 'Weather Monitoring',
        description: 'Understanding weather forecasts and alerts',
        duration: '4 min',
        icon: Icons.wb_sunny,
        videoUrl: 'https://example.com/tutorial4',
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tutorials.length,
      itemBuilder: (context, index) {
        final tutorial = tutorials[index];
        return _buildTutorialItem(tutorial);
      },
    );
  }

  Widget _buildTutorialItem(TutorialItem tutorial) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _openTutorial(tutorial.videoUrl),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  tutorial.icon,
                  color: AppColors.primaryColor,
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tutorial.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tutorial.description,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Duration: ${tutorial.duration}',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Get in Touch',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          _buildContactItem(
            Icons.phone,
            'Phone Support',
            AppConstants.supportPhoneNumber,
            'Available 24/7',
            () => _makePhoneCall(AppConstants.supportPhoneNumber),
          ),

          _buildContactItem(
            Icons.chat,
            'WhatsApp Support',
            AppConstants.supportWhatsAppNumber,
            'Quick responses',
            () => _openWhatsApp(AppConstants.supportWhatsAppNumber),
          ),

          _buildContactItem(
            Icons.email,
            'Email Support',
            AppConstants.supportEmail,
            'We\'ll respond within 24 hours',
            () => _sendEmail(AppConstants.supportEmail),
          ),

          _buildContactItem(
            Icons.location_on,
            'Visit Us',
            'AgriDirect Headquarters\nTech Park, Anand, Gujarat',
            'Mon-Fri: 9:00 AM - 6:00 PM',
            null,
          ),

          const SizedBox(height: 24),

          // Feedback Section
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Send Feedback',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Help us improve AgriDirect by sharing your thoughts and suggestions.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize