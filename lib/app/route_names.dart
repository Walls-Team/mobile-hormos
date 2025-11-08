class privateRoutes {
  static const String dashboard = '/dashboard';
  static const String stats = '/stats';
  static const String store = '/store';
  static const String settings = '/settings';
  static const String faqs = '/faqs';
  static const String termsAndConditions = '/terms_and_condictions';
  static const String resetPassword = '/auth/reset_password';
  static const String verifyEmail = '/auth/verify_email/:email';
}

class publicRoutes {
  static const String home = '/';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot_password';
}
