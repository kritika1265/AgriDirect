// screens/auth/business_registration.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import your files
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../utils/colors.dart';

/// Business email registration form
class BusinessEmailRegistrationForm extends StatefulWidget {
  final UserType userType;
  
  const BusinessEmailRegistrationForm({
    super.key,
    required this.userType,
  });

  @override
  State<BusinessEmailRegistrationForm> createState() => _BusinessEmailRegistrationFormState();
}

class _BusinessEmailRegistrationFormState extends State<BusinessEmailRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _businessPhoneController = TextEditingController();
  final _businessEmailController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  List<String> _selectedCategories = [];

  List<String> get _availableCategories {
    return widget.userType == UserType.vendor
        ? ['Tractors', 'Plows', 'Harvesters', 'Irrigation Equipment', 'Hand Tools', 'Fertilizer Spreaders']
        : ['Seeds', 'Fertilizers', 'Pesticides', 'Tools', 'Equipment', 'Organic Products'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _businessNameController.dispose();
    _businessAddressController.dispose();
    _businessPhoneController.dispose();
    _businessEmailController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            
            // Personal Information Section
            _buildSectionHeader('Personal Information'),
            const SizedBox(height: 16),
            
            // Owner Name
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Owner Full Name',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter owner name';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Email
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Personal Email',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!Provider.of<AuthProvider>(context, listen: false).isValidEmail(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Password
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                helperText: 'At least 8 characters with uppercase, lowercase & number',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                if (!Provider.of<AuthProvider>(context, listen: false).isValidPassword(value)) {
                  return 'Password must be at least 8 characters with uppercase, lowercase & number';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {}); // For password strength indicator
              },
            ),
            
            // Password Strength Indicator
            if (_passwordController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  final strength = authProvider.getPasswordStrength(_passwordController.text);
                  final strengthText = authProvider.getPasswordStrengthText(strength);
                  
                  return Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: strength / 4,
                          backgroundColor: AppColors.border,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            strength < 2 ? AppColors.error :
                            strength < 3 ? AppColors.warning :
                            AppColors.success,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        strengthText,
                        style: TextStyle(
                          fontSize: 12,
                          color: strength < 2 ? AppColors.error :
                                 strength < 3 ? AppColors.warning :
                                 AppColors.success,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Confirm Password
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 32),
            
            // Business Information Section
            _buildSectionHeader('Business Information'),
            const SizedBox(height: 16),
            
            // Business Name
            TextFormField(
              controller: _businessNameController,
              decoration: InputDecoration(
                labelText: 'Business/Shop Name',
                prefixIcon: const Icon(Icons.business),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter business name';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Business Address
            TextFormField(
              controller: _businessAddressController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Business Address',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter business address';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Business Phone
            TextFormField(
              controller: _businessPhoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Business Phone',
                prefixIcon: const Icon(Icons.phone_in_talk),
                prefixText: '+91 ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter business phone';
                }
                if (!Provider.of<AuthProvider>(context, listen: false).isValidPhoneNumber(value)) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Business Email
            TextFormField(
              controller: _businessEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Business Email (optional)',
                prefixIcon: const Icon(Icons.business_center),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (!Provider.of<AuthProvider>(context, listen: false).isValidEmail(value)) {
                    return 'Please enter a valid email';
                  }
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Business Description
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Business Description',
                prefixIcon: const Icon(Icons.description),
                hintText: 'Tell us about your ${widget.userType == UserType.vendor ? "rental services" : "products"}...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter business description';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Service/Product Categories
            Text(
              widget.userType == UserType.vendor 
                  ? 'Services you provide:' 
                  : 'Products you sell:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableCategories.map((category) {
                final isSelected = _selectedCategories.contains(category);
                return FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCategories.add(category);
                      } else {
                        _selectedCategories.remove(category);
                      }
                    });
                  },
                  selectedColor: AppColors.primary.withOpacity(0.3),
                  checkmarkColor: AppColors.primary,
                );
              }).toList(),
            ),
            
            if (_selectedCategories.isEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Please select at least one category',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                ),
              ),
            ],
            
            const SizedBox(height: 32),
            
            // Terms and Conditions
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.info,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your business will be verified before activation. You may be required to provide additional documents.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Register Button
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return ElevatedButton(
                  onPressed: _isLoading ? null : () => _handleRegister(authProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Create ${widget.userType == UserType.vendor ? "Vendor" : "Seller"} Account',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                );
              },
            ),
            
            // Error Message
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                if (authProvider.errorMessage != null) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      authProvider.errorMessage!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Future<void> _handleRegister(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one category'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final additionalData = {
      'businessName': _businessNameController.text,
      'businessAddress': _businessAddressController.text,
      'businessPhone': _businessPhoneController.text,
      'businessEmail': _businessEmailController.text.isNotEmpty 
          ? _businessEmailController.text 
          : null,
      'businessDescription': _descriptionController.text,
      'serviceCategories': _selectedCategories,
      'verificationStatus': 'pending',
      'isActiveVendor': false,
      'rating': 0.0,
      'totalTransactions': 0,
    };

    final success = await authProvider.registerWithEmail(
      email: _emailController.text,
      password: _passwordController.text,
      name: _nameController.text,
      userType: widget.userType,
      additionalData: additionalData,
    );

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      _showBusinessVerificationDialog();
    }
  }

  void _showBusinessVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          '${widget.userType == UserType.vendor ? "Vendor" : "Seller"} Account Created',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your account has been created successfully! Here\'s what happens next:',
            ),
            const SizedBox(height: 16),
            _buildVerificationStep('1', 'Email verification sent to your inbox'),
            _buildVerificationStep('2', 'Business details under review'),
            _buildVerificationStep('3', 'Account activation within 2-3 business days'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.info,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You can start setting up your profile, but ${widget.userType == UserType.vendor ? "rentals" : "sales"} will be available after verification.',
                      style: TextStyle(
                        color: AppColors.info,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/home');
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

/// Business phone registration form
class BusinessPhoneRegistrationForm extends StatefulWidget {
  final UserType userType;
  
  const BusinessPhoneRegistrationForm({
    super.key,
    required this.userType,
  });

  @override
  State<BusinessPhoneRegistrationForm> createState() => _BusinessPhoneRegistrationFormState();
}

class _BusinessPhoneRegistrationFormState extends State<BusinessPhoneRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _businessPhoneController = TextEditingController();
  final _businessEmailController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  bool _isOtpSent = false;
  bool _isLoading = false;
  String? _verificationId;
  List<String> _selectedCategories = [];

  List<String> get _availableCategories {
    return widget.userType == UserType.vendor
        ? ['Tractors', 'Plows', 'Harvesters', 'Irrigation Equipment', 'Hand Tools', 'Fertilizer Spreaders']
        : ['Seeds', 'Fertilizers', 'Pesticides', 'Tools', 'Equipment', 'Organic Products'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _businessNameController.dispose();
    _businessAddressController.dispose();
    _businessPhoneController.dispose();
    _businessEmailController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            
            if (!_isOtpSent) ...[
              // Personal Information
              _buildSectionHeader('Personal Information'),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Owner Full Name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter owner name';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Personal Phone Number',
                  prefixIcon: const Icon(Icons.phone),
                  prefixText: '+91 ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (!Provider.of<AuthProvider>(context, listen: false).isValidPhoneNumber(value)) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 32),
              
              // Business Information
              _buildSectionHeader('Business Information'),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _businessNameController,
                decoration: InputDecoration(
                  labelText: 'Business/Shop Name',
                  prefixIcon: const Icon(Icons.business),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter business name';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _businessAddressController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Business Address',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter business address';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _businessPhoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Business Phone',
                  prefixIcon: const Icon(Icons.phone_in_talk),
                  prefixText: '+91 ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter business phone';
                  }
                  if (!Provider.of<AuthProvider>(context, listen: false).isValidPhoneNumber(value)) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _businessEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Business Email (optional)',
                  prefixIcon: const Icon(Icons.business_center),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!Provider.of<AuthProvider>(context, listen: false).isValidEmail(value)) {
                      return 'Please enter a valid email';
                    }
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Business Description',
                  prefixIcon: const Icon(Icons.description),
                  hintText: 'Tell us about your ${widget.userType == UserType.vendor ? "rental services" : "products"}...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter business description';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Categories
              Text(
                widget.userType == UserType.vendor 
                    ? 'Services you provide:' 
                    : 'Products you sell:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableCategories.map((category) {
                  final isSelected = _selectedCategories.contains(category);
                  return FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedCategories.add(category);
                        } else {
                          _selectedCategories.remove(category);
                        }
                      });
                    },
                    selectedColor: AppColors.primary.withOpacity(0.3),
                    checkmarkColor: AppColors.primary,
                  );
                }).toList(),
              ),
              
              if (_selectedCategories.isEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Please select at least one category',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                  ),
                ),
              ],
              
              const SizedBox(height: 32),
              
              // Send OTP Button
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return ElevatedButton(
                    onPressed: _isLoading ? null : () => _handleSendOtp(authProvider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Send OTP',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  );
                },
              ),
            ] else ...[
              // OTP Verification State
              Text(
                'Enter the 6-digit code sent to\n+91 ${_phoneController.text}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  letterSpacing: 8,
                ),
                decoration: InputDecoration(
                  labelText: 'Enter OTP',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the OTP';
                  }
                  if (value.length != 6) {
                    return 'OTP must be 6 digits';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Resend OTP
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Didn't receive code? "),
                      if (authProvider.canResendOtp)
                        TextButton(
                          onPressed: () => _handleResendOtp(authProvider),
                          child: const Text('Resend'),
                        )
                      else
                        Text(
                          'Resend in ${authProvider.otpCountdown}s',
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                    ],
                  );
                },
              ),
              
              const SizedBox(height: 24),
              
              // Create Account Button
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return ElevatedButton(
                    onPressed: _isLoading ? null : () => _handleCreateAccount(authProvider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Create ${widget.userType == UserType.vendor ? "Vendor" : "Seller"} Account',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              TextButton(
                onPressed: () {
                  setState(() {
                    _isOtpSent = false;
                    _otpController.clear();
                  });
                },
                child: const Text('Change Phone Number'),
              ),
            ],
            
            // Error Message
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                if (authProvider.errorMessage != null) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      authProvider.errorMessage!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Future<void> _handleSendOtp(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one category'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final success = await authProvider.sendOTP(_phoneController.text);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      setState(() {
        _isOtpSent = true;
        _verificationId = authProvider.verificationId;
      });
    }
  }

  Future<void> _handleResendOtp(AuthProvider authProvider) async {
    setState(() {
      _isLoading = true;
    });

    await authProvider.resendOTP(_phoneController.text);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _handleCreateAccount(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final additionalData = {
      'businessName': _businessNameController.text,
      'businessAddress': _businessAddressController.text,
      'businessPhone': _businessPhoneController.text,
      'businessEmail': _businessEmailController.text.isNotEmpty 
          ? _businessEmailController.text 
          : null,
      'businessDescription': _descriptionController.text,
      'serviceCategories': _selectedCategories,
      'verificationStatus': 'pending',
      'isActiveVendor': false,
      'rating': 0.0,
      'totalTransactions': 0,
    };

    final success = await authProvider.verifyOTP(
      verificationId: _verificationId!,
      otp: _otpController.text,
      name: _nameController.text,
      userType: widget.userType,
      additionalData: additionalData,
    );

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      _showBusinessVerificationDialog();
    }
  }

  void _showBusinessVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          '${widget.userType == UserType.vendor ? "Vendor" : "Seller"} Account Created',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Your business account has been created successfully! Your details will be reviewed within 2-3 business days.',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.info),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You can set up your profile, but ${widget.userType == UserType.vendor ? "rentals" : "sales"} will be available after verification.',
                      style: TextStyle(color: AppColors.info, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/home');
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}