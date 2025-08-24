// screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import your files
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../utils/colors.dart';

/// Registration screen with user type selection
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  UserType _selectedUserType = UserType.farmer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Column(
        children: [
          // User Type Selection
          _buildUserTypeSelection(),
          
          // Registration Form
          Expanded(
            child: _selectedUserType == UserType.farmer
                ? const FarmerRegistrationForm()
                : BusinessRegistrationForm(userType: _selectedUserType),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTypeSelection() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'I want to join as:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          // User type options
          Row(
            children: [
              Expanded(
                child: _buildUserTypeOption(
                  userType: UserType.farmer,
                  icon: Icons.agriculture,
                  title: 'Farmer',
                  subtitle: 'Buy tools, get advice',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildUserTypeOption(
                  userType: UserType.vendor,
                  icon: Icons.store,
                  title: 'Vendor',
                  subtitle: 'Rent out tools',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildUserTypeOption(
                  userType: UserType.seller,
                  icon: Icons.storefront,
                  title: 'Seller',
                  subtitle: 'Sell products',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserTypeOption({
    required UserType userType,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedUserType == userType;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedUserType = userType;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.white : AppColors.primary,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: isSelected ? Colors.white70 : AppColors.textSecondary,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Farmer registration form
class FarmerRegistrationForm extends StatefulWidget {
  const FarmerRegistrationForm({super.key});

  @override
  State<FarmerRegistrationForm> createState() => _FarmerRegistrationFormState();
}

class _FarmerRegistrationFormState extends State<FarmerRegistrationForm> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.textSecondary,
            indicator: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'Email'),
              Tab(text: 'Phone'),
            ],
          ),
        ),
        
        // Tab Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              FarmerEmailRegistrationForm(),
              FarmerPhoneRegistrationForm(),
            ],
          ),
        ),
      ],
    );
  }
}

/// Farmer email registration form
class FarmerEmailRegistrationForm extends StatefulWidget {
  const FarmerEmailRegistrationForm({super.key});

  @override
  State<FarmerEmailRegistrationForm> createState() => _FarmerEmailRegistrationFormState();
}

class _FarmerEmailRegistrationFormState extends State<FarmerEmailRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _locationController = TextEditingController();
  final _farmSizeController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  final List<String> _selectedCrops = [];

  final List<String> _availableCrops = [
    'Rice', 'Wheat', 'Corn', 'Cotton', 'Sugarcane',
    'Soybean', 'Tomato', 'Potato', 'Onion', 'Cabbage'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _locationController.dispose();
    _farmSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            
            // Name Field
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Email Field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email Address',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!_isValidEmail(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Password Field
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
                if (!_isValidPassword(value)) {
                  return 'Password must be at least 8 characters with uppercase, lowercase & number';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {}); // Trigger rebuild for password strength indicator
              },
            ),
            
            // Password Strength Indicator
            if (_passwordController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildPasswordStrengthIndicator(),
            ],
            
            const SizedBox(height: 16),
            
            // Confirm Password Field
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
            
            const SizedBox(height: 16),
            
            // Location Field
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Location/Address',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your location';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Farm Size Field
            TextFormField(
              controller: _farmSizeController,
              decoration: InputDecoration(
                labelText: 'Farm Size (in acres)',
                prefixIcon: const Icon(Icons.landscape),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            
            const SizedBox(height: 16),
            
            // Crop Selection
            Text(
              'Crops you grow (optional):',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableCrops.map((crop) {
                final isSelected = _selectedCrops.contains(crop);
                return FilterChip(
                  label: Text(crop),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCrops.add(crop);
                      } else {
                        _selectedCrops.remove(crop);
                      }
                    });
                  },
                  selectedColor: AppColors.primary.withValues(alpha: 0.3),
                  checkmarkColor: AppColors.primary,
                );
              }).toList(),
            ),
            
            const SizedBox(height: 32),
            
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
                      : const Text(
                          'Create Farmer Account',
                          style: TextStyle(
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

  Widget _buildPasswordStrengthIndicator() {
    final strength = _getPasswordStrength(_passwordController.text);
    final strengthText = _getPasswordStrengthText(strength);
    
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
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return password.length >= 8 &&
           password.contains(RegExp(r'[A-Z]')) &&
           password.contains(RegExp(r'[a-z]')) &&
           password.contains(RegExp(r'[0-9]'));
  }

  int _getPasswordStrength(String password) {
    int score = 0;
    if (password.length >= 8) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;
    return score;
  }

  String _getPasswordStrengthText(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'Very Weak';
      case 2:
        return 'Weak';
      case 3:
        return 'Fair';
      case 4:
        return 'Good';
      case 5:
        return 'Strong';
      default:
        return 'Very Weak';
    }
  }

  Future<void> _handleRegister(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final additionalData = {
      'location': _locationController.text,
      'farmSize': _farmSizeController.text.isNotEmpty ? _farmSizeController.text : null,
      'cropTypes': _selectedCrops,
    };

    final success = await authProvider.registerWithEmail(
      email: _emailController.text,
      password: _passwordController.text,
      name: _nameController.text,
      userType: UserType.farmer,
      additionalData: additionalData,
    );

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      // Show email verification dialog
      _showEmailVerificationDialog();
    }
  }

  void _showEmailVerificationDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Verify Your Email'),
        content: const Text(
          'We\'ve sent a verification link to your email address. Please check your email and click the link to verify your account.',
        ),
        actions: [
          TextButton(
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

/// Farmer phone registration form
class FarmerPhoneRegistrationForm extends StatefulWidget {
  const FarmerPhoneRegistrationForm({super.key});

  @override
  State<FarmerPhoneRegistrationForm> createState() => _FarmerPhoneRegistrationFormState();
}

class _FarmerPhoneRegistrationFormState extends State<FarmerPhoneRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _locationController = TextEditingController();
  final _farmSizeController = TextEditingController();
  
  bool _isOtpSent = false;
  bool _isLoading = false;
  String? _verificationId;
  final List<String> _selectedCrops = [];

  final List<String> _availableCrops = [
    'Rice', 'Wheat', 'Corn', 'Cotton', 'Sugarcane',
    'Soybean', 'Tomato', 'Potato', 'Onion', 'Cabbage'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _locationController.dispose();
    _farmSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            
            if (!_isOtpSent) ...[
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Phone Field
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
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
                  if (!_isValidPhoneNumber(value)) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Location Field
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location/Address',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your location';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Farm Size Field
              TextFormField(
                controller: _farmSizeController,
                decoration: InputDecoration(
                  labelText: 'Farm Size (in acres)',
                  prefixIcon: const Icon(Icons.landscape),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              
              const SizedBox(height: 16),
              
              // Crop Selection
              Text(
                'Crops you grow (optional):',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableCrops.map((crop) {
                  final isSelected = _selectedCrops.contains(crop);
                  return FilterChip(
                    label: Text(crop),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedCrops.add(crop);
                        } else {
                          _selectedCrops.remove(crop);
                        }
                      });
                    },
                    selectedColor: AppColors.primary.withValues(alpha: 0.3),
                    checkmarkColor: AppColors.primary,
                  );
                }).toList(),
              ),
              
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
              // OTP Verification
              Text(
                'Enter the 6-digit code sent to\n+91 ${_phoneController.text}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // OTP Field
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
                          style: TextStyle(color: AppColors.textSecondary),
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
                        : const Text(
                            'Create Farmer Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              // Back button
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
                      style: TextStyle(
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

  bool _isValidPhoneNumber(String phone) {
    return RegExp(r'^[6-9]\d{9}$').hasMatch(phone);
  }

  Future<void> _handleSendOtp(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) {
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
      'location': _locationController.text,
      'farmSize': _farmSizeController.text.isNotEmpty ? _farmSizeController.text : null,
      'cropTypes': _selectedCrops,
    };

    final success = await authProvider.verifyOTP(
      verificationId: _verificationId!,
      otp: _otpController.text,
      name: _nameController.text,
      userType: UserType.farmer,
      additionalData: additionalData,
    );

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }
}

/// Business registration form for vendors and sellers
class BusinessRegistrationForm extends StatefulWidget {
  final UserType userType;
  
  const BusinessRegistrationForm({
    super.key,
    required this.userType,
  });

  @override
  State<BusinessRegistrationForm> createState() => _BusinessRegistrationFormState();
}

class _BusinessRegistrationFormState extends State<BusinessRegistrationForm> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.textSecondary,
            indicator: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'Email'),
              Tab(text: 'Phone'),
            ],
          ),
        ),
        
        // Tab Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              BusinessEmailRegistrationForm(userType: widget.userType),
              BusinessPhoneRegistrationForm(userType: widget.userType),
            ],
          ),
        ),
      ],
    );
  }
}

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
  final _businessRegNumberController = TextEditingController();
  final _businessDescriptionController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  final List<String> _selectedCategories = [];

  final List<String> _vendorCategories = [
    'Tractors', 'Harvesters', 'Plowing Equipment', 'Irrigation Systems',
    'Fertilizer Spreaders', 'Seeders', 'Cultivators', 'Mowers'
  ];

  final List<String> _sellerCategories = [
    'Seeds', 'Fertilizers', 'Pesticides', 'Tools', 'Machinery Parts',
    'Organic Products', 'Animal Feed', 'Agricultural Chemicals'
  ];

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
    _businessRegNumberController.dispose();
    _businessDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.userType == UserType.vendor 
        ? _vendorCategories 
        : _sellerCategories;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            
            // Personal Information Section
            Text(
              'Personal Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            
            // Name Field
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Email Field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email Address',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                bool _isValidEmail(String email) {
                  return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Password Fields
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
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                if (!_isValidPassword(value)) {
                  return 'Password must be at least 8 characters with uppercase, lowercase & number';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
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
            
            const SizedBox(height: 24),
            
            // Business Information Section
            Text(
              'Business Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            
            // Business Name
            TextFormField(
              controller: _businessNameController,
              decoration: InputDecoration(
                labelText: 'Business Name',
                prefixIcon: const Icon(Icons.business),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your business name';
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
                  return 'Please enter your business address';
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
                  return 'Please enter your business phone';
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
                labelText: 'Business Email (Optional)',
                prefixIcon: const Icon(Icons.business_center),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Business Registration Number
            TextFormField(
              controller: _businessRegNumberController,
              decoration: InputDecoration(
                labelText: 'Registration Number (Optional)',
                prefixIcon: const Icon(Icons.assignment),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                helperText: 'GST, Shop License, etc.',
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Business Description
            TextFormField(
              controller: _businessDescriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Business Description',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                helperText: 'Brief description of your business',
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Service Categories
            Text(
              widget.userType == UserType.vendor 
                  ? 'Equipment Categories:' 
                  : 'Product Categories:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((category) {
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
                  selectedColor: AppColors.primary.withValues(alpha: 0.3),
                  checkmarkColor: AppColors.primary,
                );
              }).toList(),
            ),
            
            const SizedBox(height: 32),
            
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
                          'Create ${widget.userType == UserType.vendor ? 'Vendor' : 'Seller'} Account',
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
                      style: TextStyle(
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

  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return password.length >= 8 &&
           password.contains(RegExp(r'[A-Z]')) &&
           password.contains(RegExp(r'[a-z]')) &&
           password.contains(RegExp(r'[0-9]'));
  }

  Future<void> _handleRegister(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one ${widget.userType == UserType.vendor ? 'equipment' : 'product'} category'),
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
      'businessEmail': _businessEmailController.text.isNotEmpty ? _businessEmailController.text : null,
      'businessRegistrationNumber': _businessRegNumberController.text.isNotEmpty ? _businessRegNumberController.text : null,
      'businessDescription': _businessDescriptionController.text.isNotEmpty ? _businessDescriptionController.text : null,
      'serviceCategories': _selectedCategories,
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
      _showVerificationDialog();
    }
  }

  void _showVerificationDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Account Created'),
        content: Text(
          'Your ${widget.userType == UserType.vendor ? 'vendor' : 'seller'} account has been created successfully. '
          'Please verify your email and wait for admin approval before you can start using business features.',
        ),
        actions: [
          TextButton(
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
  final _businessRegNumberController = TextEditingController();
  final _businessDescriptionController = TextEditingController();
  
  bool _isOtpSent = false;
  bool _isLoading = false;
  String? _verificationId;
  final List<String> _selectedCategories = [];

  final List<String> _vendorCategories = [
    'Tractors', 'Harvesters', 'Plowing Equipment', 'Irrigation Systems',
    'Fertilizer Spreaders', 'Seeders', 'Cultivators', 'Mowers'
  ];

  final List<String> _sellerCategories = [
    'Seeds', 'Fertilizers', 'Pesticides', 'Tools', 'Machinery Parts',
    'Organic Products', 'Animal Feed', 'Agricultural Chemicals'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _businessNameController.dispose();
    _businessAddressController.dispose();
    _businessPhoneController.dispose();
    _businessEmailController.dispose();
    _businessRegNumberController.dispose();
    _businessDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.userType == UserType.vendor 
        ? _vendorCategories 
        : _sellerCategories;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            
            if (!_isOtpSent) ...[
              // Personal Information
              Text(
                'Personal Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Phone Field
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
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
                  if (!_isValidPhoneNumber(value)) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Business Information Section (same as email form)
              Text(
                'Business Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              
              // Business fields (same as email form)
              TextFormField(
                controller: _businessNameController,
                decoration: InputDecoration(
                  labelText: 'Business Name',
                  prefixIcon: const Icon(Icons.business),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your business name';
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
                    return 'Please enter your business address';
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
                    return 'Please enter your business phone';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _businessEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Business Email (Optional)',
                  prefixIcon: const Icon(Icons.business_center),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _businessRegNumberController,
                decoration: InputDecoration(
                  labelText: 'Registration Number (Optional)',
                  prefixIcon: const Icon(Icons.assignment),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  helperText: 'GST, Shop License, etc.',
                ),
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _businessDescriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Business Description',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  helperText: 'Brief description of your business',
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Service Categories
              Text(
                widget.userType == UserType.vendor 
                    ? 'Equipment Categories:' 
                    : 'Product Categories:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((category) {
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
                    selectedColor: AppColors.primary.withValues(alpha: 0.3),
                    checkmarkColor: AppColors.primary,
                  );
                }).toList(),
              ),
              
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
              // OTP Verification Screen
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
                          style: TextStyle(color: AppColors.textSecondary),
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
                            'Create ${widget.userType == UserType.vendor ? 'Vendor' : 'Seller'} Account',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              // Back button
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
                      style: TextStyle(
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

  bool _isValidPhoneNumber(String phone) {
    return RegExp(r'^[6-9]\d{9}$').hasMatch(phone);
  }

  Future<void> _handleSendOtp(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one ${widget.userType == UserType.vendor ? 'equipment' : 'product'} category'),
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
      'businessEmail': _businessEmailController.text.isNotEmpty ? _businessEmailController.text : null,
      'businessRegistrationNumber': _businessRegNumberController.text.isNotEmpty ? _businessRegNumberController.text : null,
      'businessDescription': _businessDescriptionController.text.isNotEmpty ? _businessDescriptionController.text : null,
      'serviceCategories': _selectedCategories,
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
      _showVerificationDialog();
    }
  }

  void _showVerificationDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Account Created'),
        content: Text(
          'Your ${widget.userType == UserType.vendor ? 'vendor' : 'seller'} account has been created successfully. '
          'Please wait for admin approval before you can start using business features.',
        ),
        actions: [
          TextButton(
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