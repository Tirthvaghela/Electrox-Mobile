class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    
    // Check for at least one letter and one number
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
    final hasNumber = RegExp(r'[0-9]').hasMatch(value);
    
    if (!hasLetter || !hasNumber) {
      return 'Password must contain at least one letter and one number';
    }
    
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters long';
    }
    
    return null;
  }

  static String? validateOrganizationName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Organization name is required';
    }
    
    if (value.trim().length < 3) {
      return 'Organization name must be at least 3 characters long';
    }
    
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }

  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    final urlRegex = RegExp(r'^https?:\/\/[^\s]+$');
    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    
    return null;
  }
}