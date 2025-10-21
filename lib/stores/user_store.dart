// lib/stores/user_store.dart
// ignore_for_file: unnecessary_overrides

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:listify_application/models/auth.dart';
import 'package:listify_application/services/auth_service.dart';
import 'package:listify_application/services/user_service.dart'; // <-- eklendi

class UserStore extends ChangeNotifier {
  final AuthService _auth = AuthService();

  User? _fbUser;
  User? get fbUser => _fbUser;
  bool get isLoggedIn => _fbUser != null;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  /// Son e-posta/Google akışı yeni kullanıcı mı oluşturdu?
  bool? _lastIsNewUser;
  bool? get lastIsNewUser => _lastIsNewUser;

  UserStore() {
    _auth.authStateChanges().listen((u) {
      _fbUser = u;
      notifyListeners();
    });
  }

  // --------- Public actions ---------

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();
    try {
      final cred = await _auth.signInWithGoogle();
      _lastIsNewUser = cred.additionalUserInfo?.isNewUser;

      // Firestore users doc'unu garanti altına al
      final email = cred.user?.email;
      final displayName = cred.user?.displayName;
      final ok = await _ensureUserDocument(email: email, displayName: displayName,
          forceCreate: _lastIsNewUser == true);
      return ok;
    } on FirebaseAuthException catch (e) {
      _setError(_mapAuthError(e));
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUpWithEmail(Auth auth) async {
    _setLoading(true);
    _clearError();
    try {
      final cred = await _auth.signUpWithEmail(auth);
      _lastIsNewUser = cred.additionalUserInfo?.isNewUser ?? true;

      final ok = await _ensureUserDocument(
        email: cred.user?.email ?? auth.email,
        displayName: cred.user?.displayName, // yoksa null
        forceCreate: true, // signup → kesin oluştur
      );
      return ok;
    } on FirebaseAuthException catch (e) {
      _setError(_mapAuthError(e));
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithEmail(Auth auth) async {
    _setLoading(true);
    _clearError();
    try {
      final cred = await _auth.signInWithEmail(auth);
      _lastIsNewUser = cred.additionalUserInfo?.isNewUser ?? false;

      final ok = await _ensureUserDocument(
        email: cred.user?.email ?? auth.email,
        displayName: cred.user?.displayName,
        forceCreate: false, // giriş → varsa geç, yoksa oluştur
      );
      return ok;
    } on FirebaseAuthException catch (e) {
      _setError(_mapAuthError(e));
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    _clearError();
    try {
      await _auth.signOut();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void clearError() => _clearError();

  // --------- Helpers ---------

  /// Firestore'da users koleksiyonunda AppUser dokümanı olduğundan emin ol.
  /// - forceCreate=true ise direkt oluşturur (signup/new user).
  /// - forceCreate=false ise email ile arar; yoksa oluşturur.
  Future<bool> _ensureUserDocument({
    required String? email,
    String? displayName,
    required bool forceCreate,
  }) async {
    try {
      if (email == null || email.isEmpty) {
        // Email olmadan kullanıcı dokümanı standardize edemeyiz
        return false;
      }

      final us = UserService.instance;

      if (!forceCreate) {
        final exists = await us.getByEmail(email);
        if (exists != null) {
          return true; // zaten var
        }
      }

      await us.createUser(
        email: email,
        displayName: displayName,
        isDeleted: false,
      );
      return true;
    } catch (e) {
      _setError('Kullanıcı profili oluşturulamadı: $e');
      return false;
    }
  }

  Future<bool> sendPasswordReset(String email) async {
  _setLoading(true);
  _clearError();
  try {
    await _auth.sendPasswordResetEmail(email);
    return true;
  } on FirebaseAuthException catch (e) {
    _setError(_mapAuthError(e));
    return false;
  } catch (e) {
    _setError(e.toString());
    return false;
  } finally {
    _setLoading(false);
  }
}

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Geçersiz e-posta adresi.';
      case 'user-disabled':
        return 'Hesap devre dışı.';
      case 'user-not-found':
        return 'Bu e-postayla kullanıcı bulunamadı.';
      case 'wrong-password':
        return 'Şifre hatalı.';
      case 'email-already-in-use':
        return 'Bu e-posta zaten kayıtlı.';
      case 'weak-password':
        return 'Şifre yeterince güçlü değil.';
      case 'operation-not-allowed':
        return 'Bu giriş yöntemi aktif değil.';
      case 'account-exists-with-different-credential':
        return 'Bu e-posta farklı bir yöntemle kayıtlı.';
      default:
        return 'Bir hata oluştu: ${e.message ?? e.code}';
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
