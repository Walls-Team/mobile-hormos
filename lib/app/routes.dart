import 'package:flutter/material.dart';
import 'package:genius_hormo/views/auth/welcome.dart';

class AppRoutes {
  static const String home = '';
  static const String dashboard = '/dashboard'
  ;
  static const String login = '/login';
  static const String register = '/register';
  static const String terms = '/terms';
  static const String forgotPassword = '/forgot_password';
  static const String verificationCode = '/verification_code';
  static const String resetPassword = '/reset_password';
  static const String settings = '/settings';


  static Map<String, WidgetBuilder> get routes => {
    home: (context) => WelcomeScreen(),
    login: (context) => Container(),
    register: (context) => Container(),
    terms: (context) => Container(),
    forgotPassword: (context) => Container(),
    verificationCode: (context) => Container(),
    resetPassword: (context) => Container(),
    settings:(context)=> Container(),
  };
}
