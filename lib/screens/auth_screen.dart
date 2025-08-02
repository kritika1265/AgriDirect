import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_widget.dart';
import '../utils/colors.dart';
import '../utils/validators.dart';

/// Authentication screen for phone number and OTP verification
class AuthScreen extends StatefulWidget {
  /// Creates an AuthScreen widget
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isOtpSent = false;
  int _resendTimer = 60;
  bool _canResend = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0, 0.6, curve: Curves.easeOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1, curve: Curves.easeOut),
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _resendTimer = 60;
      _canResend = false;
    });
    
    _countdown();
  }

  void _countdown() {
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
      } else {
        timer.cancel();
        if (mounted) {
          setState(() {
            _canResend = true;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: DecoratedBox(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) => FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60),
                    _buildLogo(),
                    const SizedBox(height: 60),
                    _buildAuthForm(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _buildLogo() => Center(
    child: Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.agriculture,
            size: 60,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'AgriDirect',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.textOnPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Smart Farming Solutions',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textOnPrimary.withValues(alpha: 0.8),
          ),
        ),
      ],
    ),
  );

  Widget _buildAuthForm() => Consumer<AuthProvider>(
    builder: (context, authProvider, child) => Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isOtpSent ? 'Verify OTP' : 'Welcome Back',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _isOtpSent
                  ? 'Enter the OTP sent to ${_phoneController.text}'
                  : 'Enter your phone number to continue',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (!_isOtpSent) ...[
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '+91 9876543210',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: Validators.validatePhoneNumber,
              ),
            ] else ...[
              TextFormField(
                controller: _otpController,
                decoration: const InputDecoration(
                  labelText: 'OTP',
                  hintText: 'Enter 6-digit OTP',
                  prefixIcon: Icon(Icons.security),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                validator: Validators.validateOTP,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isOtpSent = false;
                        _otpController.clear();
                        _timer?.cancel();
                        _canResend = false;
                      });
                    },
                    child: const Text('Change Number'),
                  ),
                  TextButton(
                    onPressed: _canResend ? () => _resendOTP() : null,
                    child: Text(
                      _canResend ? 'Resend OTP' : 'Resend in ${_resendTimer}s',
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            if (authProvider.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        authProvider.errorMessage!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            ElevatedButton(
              onPressed: authProvider.isLoading ? null : () => _handleAuth(),
              child: authProvider.isLoading
                  ? const CircularProgressIndicator()
                  : Text(_isOtpSent ? 'Verify OTP' : 'Send OTP'),
            ),
            if (_isOtpSent) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: authProvider.isLoading
                    ? null
                    : () {
                        setState(() {
                          _isOtpSent = false;
                          _otpController.clear();
                          _timer?.cancel();
                          _canResend = false;
                        });
                      },
                child: const Text('Back'),
              ),
            ],
          ],
        ),
      ),
    ),
  );

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();

    if (!_isOtpSent) {
      // Send OTP
      final phoneNumber = '+91${_phoneController.text.trim()}';
      final success = await authProvider.sendOTP(phoneNumber);
      
      if (success) {
        setState(() {
          _isOtpSent = true;
        });
        _startResendTimer();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OTP sent successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } else {
      // Verify OTP
      final otp = _otpController.text.trim();
      final phoneNumber = '+91${_phoneController.text.trim()}';
      final success = await authProvider.verifyOTP(otp, phoneNumber);
      
      if (success && mounted) {
        await Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  Future<void> _resendOTP() async {
    final authProvider = context.read<AuthProvider>();
    final phoneNumber = '+91${_phoneController.text.trim()}';
    
    final success = await authProvider.sendOTP(phoneNumber);
    
    if (success) {
      _startResendTimer();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP resent successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }
}