class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  // Phone number validation (Indian format)
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove spaces and special characters
    String cleanedNumber = value.replaceAll(RegExp(r'[^\d]'), '');
    
    // Check if it's a valid Indian mobile number
    if (cleanedNumber.length == 10 && cleanedNumber.startsWith(RegExp(r'[6-9]'))) {
      return null;
    } else if (cleanedNumber.length == 12 && cleanedNumber.startsWith('91')) {
      String actualNumber = cleanedNumber.substring(2);
      if (actualNumber.startsWith(RegExp(r'[6-9]'))) {
        return null;
      }
    } else if (cleanedNumber.length == 13 && cleanedNumber.startsWith('+91')) {
      String actualNumber = cleanedNumber.substring(3);
      if (actualNumber.startsWith(RegExp(r'[6-9]'))) {
        return null;
      }
    }
    
    return 'Please enter a valid 10-digit mobile number';
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters long';
    }
    
    if (value.trim().length > 50) {
      return 'Name must not exceed 50 characters';
    }
    
    // Check if name contains only letters and spaces
    final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
    if (!nameRegex.hasMatch(value.trim())) {
      return 'Name can only contain letters and spaces';
    }
    
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    
    if (value.length > 50) {
      return 'Password must not exceed 50 characters';
    }
    
    return null;
  }

  // OTP validation
  static String? validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }
    
    if (value.length != 6) {
      return 'OTP must be 6 digits';
    }
    
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'OTP must contain only numbers';
    }
    
    return null;
  }

  // Location validation
  static String? validateLocation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Location is required';
    }
    
    if (value.trim().length < 2) {
      return 'Location must be at least 2 characters long';
    }
    
    if (value.trim().length > 100) {
      return 'Location must not exceed 100 characters';
    }
    
    return null;
  }

  // Farm size validation
  static String? validateFarmSize(String? value) {
    if (value == null || value.isEmpty) {
      return 'Farm size is required';
    }
    
    return null;
  }

  // Crop type validation
  static String? validateCropTypes(List<String>? value) {
    if (value == null || value.isEmpty) {
      return 'Please select at least one crop type';
    }
    
    return null;
  }

  // Generic required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    return null;
  }

  // Number validation
  static String? validateNumber(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    
    return null;
  }

  // Positive number validation
  static String? validatePositiveNumber(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }
    
    if (number <= 0) {
      return '$fieldName must be greater than 0';
    }
    
    return null;
  }

  // URL validation
  static String? validateURL(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    final urlRegex = RegExp(
      r'^https?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&=]*)$'
    );
    
    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    
    return null;
  }

  // Age validation
  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age is required';
    }
    
    final age = int.tryParse(value);
    if (age == null) {
      return 'Please enter a valid age';
    }
    
    if (age < 18 || age > 100) {
      return 'Age must be between 18 and 100';
    }
    
    return null;
  }

  // Date validation
  static String? validateDate(DateTime? value) {
    if (value == null) {
      return 'Date is required';
    }
    
    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  // Custom validation for specific business rules
  static String? validateCropSeason(String? season, String? cropType) {
    if (season == null || season.isEmpty) {
      return 'Season is required';
    }
    
    // Add specific business logic for crop-season combinations
    final Map<String, List<String>> cropSeasons = {
      'Rice': ['Kharif'],
      'Wheat': ['Rabi'],
      'Sugarcane': ['Perennial'],
      'Cotton': ['Kharif'],
      'Maize': ['Kharif', 'Rabi'],
    };
    
    if (cropType != null && cropSeasons.containsKey(cropType)) {
      if (!cropSeasons[cropType]!.contains(season)) {
        return '$cropType is not suitable for $season season';
      }
    }
    
    return null;
  }

  // Soil type validation for crops
  static String? validateSoilForCrop(String? soilType, String? cropType) {
    if (soilType == null || soilType.isEmpty) {
      return 'Soil type is required';
    }
    
    // Add specific soil-crop compatibility logic
    final Map<String, List<String>> cropSoils = {
      'Rice': ['Clay', 'Loamy'],
      'Wheat': ['Loamy', 'Clay'],
      'Cotton': ['Sandy', 'Loamy'],
      'Sugarcane': ['Loamy', 'Clay'],
    };
    
    if (cropType != null && cropSoils.containsKey(cropType)) {
      if (!cropSoils[cropType]!.contains(soilType)) {
        return '$soilType soil may not be optimal for $cropType';
      }
    }
    
    return null;
  }

  // Text length validation
  static String? validateTextLength(String? value, {
    required String fieldName,
    int? minLength,
    int? maxLength,
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    final trimmedValue = value.trim();
    
    if (minLength != null && trimmedValue.length < minLength) {
      return '$fieldName must be at least $minLength characters long';
    }
    
    if (maxLength != null && trimmedValue.length > maxLength) {
      return '$fieldName must not exceed $maxLength characters';
    }
    
    return null;
  }
}