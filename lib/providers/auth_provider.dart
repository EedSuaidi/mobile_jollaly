import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  bool _isLoading = false;
  bool _initialized = false;
  String? _token;
  String? _email;
  String? _userId;
  String? _error;

  bool get isLoading => _isLoading;
  bool get initialized => _initialized;
  String? get token => _token;
  String? get email => _email;
  String? get userId => _userId;
  String? get error => _error;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  Future<void> initialize() async {
    final session = await _service.loadSession();
    _token = session.token;
    _email = session.email;
    _userId = session.userId;
    _initialized = true;
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _service.login(email: email, password: password);
      _token = res.token;
      _email = res.email;
      _userId = res.userId;
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<({bool success, String? message})> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _service.register(
        name: name,
        email: email,
        password: password,
      );
      return (success: true, message: 'Registered ${res.email}');
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return (success: false, message: _error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _service.logout();
    _token = null;
    _email = null;
    _userId = null;
    _error = null;
    notifyListeners();
  }
}
