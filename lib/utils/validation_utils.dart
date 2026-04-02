class ValidationUtils {
  // Email validation
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // Password validation
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  // Phone number validation
  static bool isValidPhoneNumber(String phoneNumber) {
    final phoneRegex = RegExp(r'^[0-9]{9,15}$');
    return phoneRegex.hasMatch(phoneNumber.replaceAll(RegExp(r'[^0-9]'), ''));
  }

  // Name validation
  static bool isValidName(String name) {
    return name.length >= 3;
  }

  // URL validation
  static bool isValidUrl(String url) {
    try {
      Uri.parse(url);
      return url.startsWith('http://') || url.startsWith('https://');
    } catch (e) {
      return false;
    }
  }

  // Empty validation
  static bool isEmpty(String value) {
    return value.trim().isEmpty;
  }

  // Minimum length validation
  static bool hasMinimumLength(String value, int minimumLength) {
    return value.length >= minimumLength;
  }

  // Maximum length validation
  static bool hasMaximumLength(String value, int maximumLength) {
    return value.length <= maximumLength;
  }

  // Password match validation
  static bool passwordsMatch(String password, String confirmPassword) {
    return password == confirmPassword;
  }
}

