import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart' as models; // Added alias to resolve ambiguous import
import '../providers/auth_provider.dart';
import '../services/image_service.dart'; // This now includes ImagePickerService, NetworkService, etc.
import '../utils/colors.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_widget.dart';

/// Profile screen for displaying and editing user information
class ProfileScreen extends StatefulWidget {
  /// Creates a profile screen
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _farmSizeController = TextEditingController();
  final _cropTypesController = TextEditingController();
  
  bool _isEditing = false;
  bool _isLoading = false;
  String? _profileImageUrl;
  
  final List<String> _farmingExperience = [
    'Beginner (0-2 years)',
    'Intermediate (3-5 years)',
    'Experienced (6-10 years)',
    'Expert (10+ years)'
  ];
  
  String _selectedExperience = 'Beginner (0-2 years)';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber;
      _locationController.text = user.location ?? '';
      _farmSizeController.text = user.farmSize ?? '';
      _cropTypesController.text = user.cropTypes.join(', ');
      _selectedExperience = user.experience ?? _farmingExperience[0];
      _profileImageUrl = user.imageUrl ?? user.profilePicture; // Check both fields
    }
  }

  Future<void> _pickProfileImage() async {
    try {
      // Show image source selection dialog
      final imageSource = await _showImageSourceDialog();
      if (imageSource == null) return;
      
      setState(() => _isLoading = true);
      
      XFile? pickedImage;
      if (imageSource == ImageSource.camera) {
        pickedImage = await ImagePickerService.pickFromCamera();
      } else {
        pickedImage = await ImagePickerService.pickFromGallery();
      }
      
      if (pickedImage != null) {
        final imageFile = File(pickedImage.path);
        
        // Validate the image
        final isValid = await ImageValidator.validateImage(imageFile);
        if (!isValid) {
          setState(() => _isLoading = false);
          _showSnackBar('Invalid image file. Please select a valid image (max ${ImageConstants.maxFileSizeMB}MB)');
          return;
        }
        
        // Cache the image
        final cachedPath = await ImageCacheService.cacheImage(imageFile);
        if (cachedPath != null) {
          // Upload image using NetworkService (mock upload)
          final response = await NetworkService.uploadImage(
            imageFile: File(cachedPath),
            description: 'Profile picture for ${_nameController.text}',
          );
          
          if (response.success && response.data != null) {
            setState(() {
              _profileImageUrl = response.data!.path;
              _isLoading = false;
            });
            _showSnackBar('Profile image updated successfully!');
          } else {
            setState(() => _isLoading = false);
            _showSnackBar('Failed to upload image: ${response.error ?? 'Unknown error'}');
          }
        } else {
          setState(() => _isLoading = false);
          _showSnackBar('Failed to process image');
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Failed to update profile image: $e');
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Create updated user using copyWith
      final updatedUser = authProvider.user!.copyWith(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        location: _locationController.text.trim(),
        farmSize: _farmSizeController.text.trim(),
        cropTypes: _cropTypesController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        experience: _selectedExperience,
        imageUrl: _profileImageUrl, // Using imageUrl field
        updatedAt: DateTime.now(),
      );
      
      await authProvider.updateUser(updatedUser);
      
      setState(() {
        _isEditing = false;
        _isLoading = false;
      });
      
      _showSnackBar('Profile updated successfully!');
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Failed to update profile: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: 'Profile',
          actions: [
            if (!_isEditing)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => setState(() => _isEditing = true),
              ),
          ],
        ),
        body: _isLoading
            ? const LoadingWidget()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Image Section
                      _buildProfileImageSection(),
                      const SizedBox(height: 24),
                      
                      // Profile Form Fields
                      _buildProfileForm(),
                      
                      const SizedBox(height: 32),
                      
                      // Action Buttons
                      if (_isEditing) _buildActionButtons(),
                      
                      if (!_isEditing) _buildStatisticsSection(),
                    ],
                  ),
                ),
              ),
      );

  Widget _buildProfileImageSection() => Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: AppColors.primaryLight,
                backgroundImage: _profileImageUrl != null
                    ? NetworkImage(_profileImageUrl!)
                    : null,
                child: _profileImageUrl == null
                    ? Icon(
                        Icons.person,
                        size: 60,
                        color: AppColors.primary,
                      )
                    : null,
              ),
              if (_isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickProfileImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final user = authProvider.user;
              return Column(
                children: [
                  Text(
                    user?.name ?? 'User Name',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (user?.isVerified == true)
                    const Row( // Added const
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified,
                          color: Colors.green,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Verified Farmer',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                ],
              );
            },
          ),
        ],
      );

  Widget _buildProfileForm() => Column(
        children: [
          CustomTextField(
            controller: _nameController,
            label: 'Full Name',
            enabled: _isEditing,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          CustomTextField(
            controller: _emailController,
            label: 'Email',
            enabled: _isEditing,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Email is required';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          CustomTextField(
            controller: _phoneController,
            label: 'Phone Number',
            enabled: _isEditing,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Phone number is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          CustomTextField(
            controller: _locationController,
            label: 'Location',
            enabled: _isEditing,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Location is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          CustomTextField(
            controller: _farmSizeController,
            label: 'Farm Size (acres)',
            enabled: _isEditing,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          
          CustomTextField(
            controller: _cropTypesController,
            label: 'Crop Types (comma separated)',
            enabled: _isEditing,
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          
          // Farming Experience Dropdown
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedExperience,
              decoration: const InputDecoration(
                labelText: 'Farming Experience',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: _farmingExperience.map((experience) => DropdownMenuItem(
                    value: experience,
                    child: Text(experience),
                  )).toList(),
              onChanged: _isEditing
                  ? (value) => setState(() => _selectedExperience = value!)
                  : null,
            ),
          ),
        ],
      );

  Widget _buildActionButtons() => Row(
        children: [
          Expanded(
            child: CustomButton(
              text: 'Cancel',
              onPressed: () {
                setState(() => _isEditing = false);
                _loadUserProfile(); // Reset form fields
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CustomButton(
              text: 'Save Changes',
              onPressed: _saveProfile,
              isLoading: _isLoading,
            ),
          ),
        ],
      );

  Widget _buildStatisticsSection() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1), // Changed withValues to withOpacity
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Predictions', '24', Icons.insights),
                _buildStatItem('Consultations', '8', Icons.chat),
                _buildStatItem('Tools Rented', '12', Icons.build),
              ],
            ),
          ],
        ),
      );

  Widget _buildStatItem(String label, String value, IconData icon) => Column(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _farmSizeController.dispose();
    _cropTypesController.dispose();
    // Clear image cache when disposing (optional)
    _clearImageCache();
    super.dispose();
  }

  Future<void> _clearImageCache() async {
    try {
      await ImageCacheService.clearCache();
    } catch (e) {
      // Silently handle cache clear errors
    }
  }
}