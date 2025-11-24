import 'package:flutter/material.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

import 'package:flutter_localization/flutter_localization.dart'; 


// import 'package:flutter/cupertino.dart';



class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  // static AppLocalizations of(BuildContext context) {
  //   return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  // }

    static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static AppLocalizations safeOf(BuildContext context) {
    final localizations = of(context);
    if (localizations == null) {
      throw FlutterError('AppLocalizations no encontrado en el contexto. '
          'Asegúrate de haber configurado las localizations en MaterialApp.');
    }
    return localizations;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  // Agregar este getter para los delegates globales
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    AppLocalizations.delegate,
    // GlobalMaterialLocalizations.delegate,
    // GlobalWidgetsLocalizations.delegate,
    // GlobalCupertinoLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = [
    Locale('en', ''),
    Locale('es', ''),
  ];

  static final Map<String, Map<String, dynamic>> _localizedValues = {
    'en': en,
    'es': es,
  };

  String _getTranslation(String key, Map<String, dynamic> map) {
    final keys = key.split('.');
    dynamic result = map;
    
    for (final k in keys) {
      if (result is Map<String, dynamic>) {
        result = result[k];
      } else {
        return key;
      }
    }
    
    return result?.toString() ?? key;
  }

  String t(String key) {
    return _getTranslation(key, _localizedValues[locale.languageCode]!);
  }

  // Operator [] to allow map-like access
  dynamic operator [](String key) {
    final value = _localizedValues[locale.languageCode]![key];
    return value;
  }

  // Common
  String get commonLoading => t('common.loading');
  String get commonSave => t('common.save');
  String get commonSaving => t('common.saving');
  String get commonSuccess => t('common.success');
  String get commonError => t('common.error');
  String get commonLogout => t('common.logout');
  String get commonBack => t('common.back');
  String get commonComplete => t('common.complete');
  String get commonIncomplete => t('common.incomplete');
  String get commonTokenExpired => t('common.tokenExpired');
  String get commonSelectPlaceholder => t('common.selectPlaceholder');
  String get commonCancel => t('common.cancel');
  String get commonSelect => t('common.select');
  String get commonClose => t('common.close');

  // Auth
  String get authLogin => t('auth.login');
  String get authRegister => t('auth.register');
  String get authEmail => t('auth.email');
  String get authPassword => t('auth.password');
  String get authConfirmPassword => t('auth.confirmPassword');
  String get authFirstName => t('auth.firstName');
  String get authLastName => t('auth.lastName');
  String get authLoginSuccess => t('auth.loginSuccess');
  String get authLoginError => t('auth.loginError');
  String get authRegisterSuccess => t('auth.registerSuccess');
  String get authRegisterError => t('auth.registerError');
  String get authBackToLogin => t('auth.backToLogin');
  String get authPasswordMismatch => t('auth.passwordMismatch');

  // Dashboard
  String get dashboardOverview => t('dashboard.overview');
  String get dashboardNotifications => t('dashboard.notifications');
  String get dashboardSettings => t('dashboard.settings');
  String get dashboardStats => t('dashboard.stats');
  String get dashboardStore => t('dashboard.store');
  String get dashboardConfigurationSetup => t('dashboard.configurationSetup');
  String get dashboardCompleteAllSteps => t('dashboard.completeAllSteps');
  String get dashboardDevice => t('dashboard.device');
  String get dashboardDeviceNotConnected => t('dashboard.deviceNotConnected');
  String get dashboardDeviceConnected => t('dashboard.deviceConnected');
  String get dashboardProfile => t('dashboard.profile');
  String get dashboardProfileConnected => t('dashboard.profileConnected');
  String get dashboardCurrentTestosterone => t('dashboard.currentTestosterone');
  String get dashboardLabTest => t('dashboard.labTest');
  String get dashboardSelectLab => t('dashboard.selectLab');
  String get dashboardNoNotifications => t('dashboard.noNotifications');
  String get dashboardNoNotificationsDesc => t('dashboard.noNotificationsDesc');
  String get dashboardCompleteProfile => t('dashboard.completeProfile');
  String get dashboardCompleteProfileToSee => t('dashboard.completeProfileToSee');
  String get dashboardLoadingHealthData => t('dashboard.loadingHealthData');
  String get dashboardTestosteroneStatus => t('dashboard.testosteroneStatus');
  String get dashboardTestosteroneInfo => t('dashboard.testosteroneInfo');
  
  String testosteroneLevel(String level) => t('dashboard.testosteroneLevel.$level');

  // Charts
  String get chartsTestosteroneLevels => t('charts.testosteroneLevels');
  String get chartsTestosteroneTable => t('charts.testosteroneTable');
  String get chartsTestosteroneTableNote => t('charts.testosteroneTableNote');
  String get chartsAgeRange => t('charts.ageRange');
  String get chartsYears => t('charts.years');
  String get chartsHealthStats => t('charts.healthStats');
  String get chartsMetricsEvolution => t('charts.metricsEvolution');
  String get chartsRestingHr => t('charts.restingHr');
  String get chartsHrv => t('charts.hrv');
  String get chartsSleepHours => t('charts.sleepHours');
  String get chartsSleepEfficiency => t('charts.sleepEfficiency');
  String get chartsRespiratoryRate => t('charts.respiratoryRate');
  String get chartsSpo2 => t('charts.spo2');
  String get chartsCaloriesTotal => t('charts.caloriesTotal');
  String get chartsActiveCalories => t('charts.activeCalories');
  String get chartsTestosterone => t('charts.testosterone');
  String get chartsTestosteroneAnalyzing => t('charts.testosteroneAnalyzing');
  
  String chartsInterval(String interval) => t('charts.intervals.$interval');

  // Settings
  String get settingsPersonalData => t('settings.personalData');
  String get settingsLanguage => t('settings.language');
  String get settingsWeight => t('settings.weight');
  String get settingsHeight => t('settings.height');
  String get settingsHeightFeet => t('settings.heightFeet');
  String get settingsAge => t('settings.age');
  String get settingsBirthDate => t('settings.birthDate');
  String get settingsMinAge => t('settings.minAge');
  String get settingsSaveData => t('settings.saveData');
  String get settingsDataSaved => t('settings.dataSaved');
  String get settingsSaveError => t('settings.saveError');
  String get settingsDevice => t('settings.device');
  String get settingsDeviceConnect => t('settings.deviceConnect');
  String get settingsDeviceConnected => t('settings.deviceConnected');
  String get settingsDeviceDisconnect => t('settings.deviceDisconnect');
  String get settingsSelectDevice => t('settings.selectDevice');
  String get settingsWhoop => t('settings.whoop');
  String get settingsWhoopConnect => t('settings.whoopConnect');
  String get settingsWhoopConnected => t('settings.whoopConnected');
  String get settingsWhoopDisconnect => t('settings.whoopDisconnect');
  String get settingsChangeDevice => t('settings.changeDevice');
  String get settingsUser => t('settings.user');
  String get settingsEmail => t('settings.email');
  String get settingsPassword => t('settings.password');
  String get settingsChangePassword => t('settings.changePassword');
  String get settingsGender => t('settings.gender');
  String get settingsFaqs => t('settings.faqs');
  String get settingsAppSettingsLanguage => t('settings.appSettings.language');
  String get settingsConnectionsTitle => t('settings.connections.title');
  String get settingsConnectionsSelectDevice => t('settings.connections.selectDevice');
  String get settingsLogOut => t('settings.logOut');
  String get settingsLogOutError => t('settings.logOutError');
  String get settingsSelectAvatar => t('settings.selectAvatar');
  String get settingsAvatarUpdated => t('settings.avatarUpdated');
  String get settingsAvatarUpdateError => t('settings.avatarUpdateError');
  String get settingsDeleteAccount => t('settings.deleteAccount');
  String get settingsDeleteAccountModalTitle => t('settings.deleteAccountModal.title');
  String get settingsDeleteAccountModalMessage => t('settings.deleteAccountModal.message');
  String get settingsDeleteAccountModalWarning => t('settings.deleteAccountModal.warning');
  String get settingsDeleteAccountModalConfirm => t('settings.deleteAccountModal.confirm');
  String get settingsDeleteAccountModalCancel => t('settings.deleteAccountModal.cancel');
  String get settingsDeleteAccountSuccess => t('settings.deleteAccountSuccess');
  String get settingsDeleteAccountError => t('settings.deleteAccountError');

  // Gender
  String gender(String genderType) => t('gender.$genderType');

  // Errors
  String get errorsConnectionTitle => t('errors.connectionTitle');
  String get errorsConnectionMessage => t('errors.connectionMessage');
  String get errorsProfileLoadError => t('errors.profileLoadError');
  String get errorsRetry => t('errors.retry');

  // Loading
  String get loadingSynchronizing => t('loading.synchronizing');
  String get loadingPreparingData => t('loading.preparingData');

  // Device Connection
  String get deviceConnectionSynchronizing => t('device.connection.synchronizing');
  String get deviceConnectionSynchronizingDescription => t('device.connection.synchronizingDescription');
  String get deviceConnectionProcessing => t('device.connection.processing');
  String get deviceConnectionProcessingDescription => t('device.connection.processingDescription');
  String get deviceConnectionSuccess => t('device.connection.success');
  String get deviceConnectionSuccessDescription => t('device.connection.successDescription');
  String get deviceConnectionError => t('device.connection.error');
  String get deviceConnectionErrorDescription => t('device.connection.errorDescription');
  String get deviceConnectionRedirecting => t('device.connection.redirecting');
  String get deviceConnectionMaxRetriesReached => t('device.connection.maxRetriesReached');
  String get deviceConnectionFailed => t('device.connection.failed');
  String get deviceConnectionResultsError => t('device.connection.resultsError');
  String get deviceConnectionStatusError => t('device.connection.statusError');
  String get deviceConnectionInitError => t('device.connection.initError');
  String get deviceConnectionDisconnected => t('device.connection.disconnected');
  String get deviceConnectionDisconnectError => t('device.connection.disconnectError');
  String get deviceConnectionDisconnectMaxRetries => t('device.connection.disconnectMaxRetries');
  String get deviceConnectionNoDeviceConnected => t('device.connection.noDeviceConnected');
  String get deviceConnectionTryAgain => t('device.connection.tryAgain');

  // Daily Questions
  String get dailyQuestionsTitle => t('dailyQuestions.title');
  String get dailyQuestionsSaved => t('dailyQuestions.saved');
  String get dailyQuestionsError => t('dailyQuestions.error');
  String get dailyQuestionsAlcoholTitle => t('dailyQuestions.alcohol.title');
  String get dailyQuestionsAlcoholDescription => t('dailyQuestions.alcohol.description');
  String get dailyQuestionsDrugsTitle => t('dailyQuestions.drugs.title');
  String get dailyQuestionsDrugsDescription => t('dailyQuestions.drugs.description');
  String get dailyQuestionsPoorDietTitle => t('dailyQuestions.poorDiet.title');
  String get dailyQuestionsPoorDietDescription => t('dailyQuestions.poorDiet.description');
  String get dailyQuestionsAttendanceTitle => t('dailyQuestions.attendance.title');
  String get dailyQuestionsAttendanceDescription => t('dailyQuestions.attendance.description');
  String get dailyQuestionsOthersTitle => t('dailyQuestions.others.title');
  String get dailyQuestionsOthersDescription => t('dailyQuestions.others.description');

  // Store
  String get storeTitle => t('store.title');
  String get storeSubtitle => t('store.subtitle');
  String get storeExternalLinkTitle => t('store.externalLinkTitle');
  String get storeExternalLinkMessage => t('store.externalLinkMessage');
  String get storeContinue => t('store.continue');
  String get storeVitaminsTitle => t('store.vitamins.title');
  String get storeVitaminsDescription => t('store.vitamins.description');
  String get storeWhoopTitle => t('store.whoop.title');
  String get storeWhoopDescription => t('store.whoop.description');
  String get storeLabsSorioTitle => t('store.labsSorio.title');
  String get storeLabsSorioDescription => t('store.labsSorio.description');
  String get storeMuseTitle => t('store.muse.title');
  String get storeMuseDescription => t('store.muse.description');
  String get storeLabcorpTitle => t('store.labcorp.title');
  String get storeLabcorpDescription => t('store.labcorp.description');

  // Change Password
  String get changePasswordTitle => t('changePassword.title');
  String get changePasswordPassword => t('changePassword.password');
  String get changePasswordPasswordPlaceholder => t('changePassword.passwordPlaceholder');
  String get changePasswordConfirmPassword => t('changePassword.confirmPassword');
  String get changePasswordConfirmPasswordPlaceholder => t('changePassword.confirmPasswordPlaceholder');
  String get changePasswordRequirements => t('changePassword.requirements');
  String get changePasswordValidationsMinLength => t('changePassword.validations.minLength');
  String get changePasswordValidationsHasUppercase => t('changePassword.validations.hasUppercase');
  String get changePasswordValidationsHasLowercase => t('changePassword.validations.hasLowercase');
  String get changePasswordValidationsHasNumber => t('changePassword.validations.hasNumber');
  String get changePasswordValidationsHasSpecialChar => t('changePassword.validations.hasSpecialChar');
  String get changePasswordValidationsNoSpaces => t('changePassword.validations.noSpaces');
  String get changePasswordChange => t('changePassword.change');
  String get changePasswordPasswordMismatch => t('changePassword.passwordMismatch');
  String get changePasswordError => t('changePassword.error');
  String get changePasswordSuccessTitle => t('changePassword.successTitle');
  String get changePasswordSuccessMessage => t('changePassword.successMessage');
  String get changePasswordContinue => t('changePassword.continue');

  // FAQs
  String get faqsTitle => t('faqs.title');
  String get faqsDescription => t('faqs.description');
  String get faqsQuestion1 => t('faqs.questions.q1');
  String get faqsQuestion2 => t('faqs.questions.q2');
  String get faqsQuestion3 => t('faqs.questions.q3');
  String get faqsQuestion4 => t('faqs.questions.q4');
  String get faqsQuestion5 => t('faqs.questions.q5');
  String get faqsQuestion6 => t('faqs.questions.q6');
  String get faqsQuestion7 => t('faqs.questions.q7');
  String get faqsAnswer1 => t('faqs.answers.a1');
  String get faqsAnswer2 => t('faqs.answers.a2');
  String get faqsAnswer3 => t('faqs.answers.a3');
  String get faqsAnswer4 => t('faqs.answers.a4');
  String get faqsAnswer5 => t('faqs.answers.a5');
  String get faqsAnswer6 => t('faqs.answers.a6');
  String get faqsAnswer7 => t('faqs.answers.a7');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'es'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}