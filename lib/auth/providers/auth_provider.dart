import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../core/services/secure_storage_service.dart';
import '../model/auth_method.dart';
import '../model/auth_status.dart';
import '../repo/auth_repo.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepo = AuthRepository();
  late final StreamSubscription<User?>? _authSub;

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSub;
  final SecureStorageService _storage = SecureStorageService();
  AuthStatus _authStatus = AuthStatus.authenticating;

  String? _email;
  String? _error;
  Uri? uri;

  AuthStatus get status => _authStatus;
  String? get error => _error;

  Timer? _resendTimer;
  int _resendSecondsLeft = 0;

  int get resendSecondsLeft => _resendSecondsLeft;
  bool get canResend => _resendSecondsLeft == 0;

  bool get isEmailLocked => _authStatus == AuthStatus.linkSent && !canResend;

  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  User? _user;

  String? get uid => _user?.uid;

  AuthMethod _method = AuthMethod.magicLink;
  AuthMethod get method => _method;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _listenToIncomingLinks();
    _listenToAuthChanges();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _linkSub?.cancel();
    _resendTimer?.cancel();
    super.dispose();
  }

  Future<void> sendLink(String email) async {
    _authStatus = AuthStatus.sendingLink;
    notifyListeners();

    _error = null;
    _email = email;
    _storage.write(key: 'email', value: _email);

    try {
      _startResendCooldown();
      await _authRepo.sendLinkToEmail(email);
      _authStatus = AuthStatus.linkSent;
    } catch (e) {
      if (kDebugMode) debugPrint(e.toString());
      _error = e.toString();
      _authStatus = AuthStatus.error;
    }
    notifyListeners();
  }

  Future<void> authenticate({String? confirmedEmail}) async {
    _authStatus = AuthStatus.authenticating;
    notifyListeners();

    if (confirmedEmail != null) {
      _email = confirmedEmail;
    } else {
      _email ??= await _storage.read(key: 'email');
    }

    try {
      if (_email == null) {
        _authStatus = AuthStatus.emailConfirmation;
      } else if (uri != null) {
        await _authRepo.verifyLink(
          email: confirmedEmail ?? _email!,
          emailLink: uri.toString(),
        );
        uri = null;
        _error = null;
        _storage.delete(key: 'email');
        _authStatus = AuthStatus.loggedIn;
      }
    } catch (e) {
      if (kDebugMode) debugPrint(e.toString());
      _error = e.toString();
      _authStatus = AuthStatus.error;
    }
    notifyListeners();
  }

  void _listenToIncomingLinks() {
    _linkSub = _appLinks.uriLinkStream.listen(
      (uri) {
        this.uri = uri;
        authenticate();
      },
      onError: (e) {
        if (kDebugMode) debugPrint(e.toString());
        _error = e.toString();
        _authStatus = AuthStatus.error;
        notifyListeners();
      },
    );
  }

  void _listenToAuthChanges() {
    _authSub = _authRepo.authStateChanges().listen((user) async {
      if (user == null) {
        _authStatus = AuthStatus.loggedOut;
        _isLoggedIn = false;
      } else {
        _user = user;
        _isLoggedIn = true;
        _authStatus = AuthStatus.loggedIn;
      }
      notifyListeners();
    });
  }

  void _startResendCooldown() {
    _resendTimer?.cancel();
    _resendSecondsLeft = 15;

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _resendSecondsLeft--;

      if (_resendSecondsLeft <= 0) {
        timer.cancel();
        _resendSecondsLeft = 0;
      }

      notifyListeners();
    });
  }

  void changeEmail() {
    _resendTimer?.cancel();
    _resendSecondsLeft = 0;
    _email = null;
    _error = null;

    _authStatus = AuthStatus.loggedOut;

    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await _authRepo.signOut();
      _authStatus = AuthStatus.loggedOut;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _authStatus = AuthStatus.error;
    }
  }

  String? consumeError() {
    final message = _error;
    _error = null;
    return message;
  }

  void switchAuthMethod(AuthMethod method) {
    _method = method;
    _error = null;
    notifyListeners();
  }

  Future<void> loginWithEmailPassword(String email, String password) async {
    _authStatus = AuthStatus.authenticating;
    notifyListeners();

    try {
      await _authRepo.signInWithEmailPassword(email: email, password: password);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _authStatus = AuthStatus.error;
    }

    notifyListeners();
  }

  Future<void> signupWithEmailPassword(String email, String password) async {
    _authStatus = AuthStatus.authenticating;
    notifyListeners();

    try {
      await _authRepo.signUpWithEmailPassword(email: email, password: password);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _authStatus = AuthStatus.error;
    }

    notifyListeners();
  }
}
