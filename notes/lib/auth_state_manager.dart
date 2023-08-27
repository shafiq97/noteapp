// auth_state_manager.dart

import 'package:flutter/foundation.dart';

class AuthStateManager with ChangeNotifier {
  bool _isAuthenticatedForPrivate = false;

  bool get isAuthenticatedForPrivate => _isAuthenticatedForPrivate;

  void setAuthenticatedForPrivate(bool value) {
    _isAuthenticatedForPrivate = value;
    notifyListeners();
  }
}
