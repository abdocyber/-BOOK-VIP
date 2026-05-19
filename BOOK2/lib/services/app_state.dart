class AppState {
  AppState._();

  static bool firebaseReady = false;
  static String firebaseError = '';

  static bool appDisabled = false;
  static String appDisabledMessage = 'التطبيق متوقف مؤقتًا، يرجى المحاولة لاحقًا';
}
