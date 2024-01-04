import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProivder();
    test('Should not be initialized', () {
      expect(provider.isInitialized, false);
    });
    test('Cannot log out if not initialised', () {
      expect(
        provider.logOut(),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });

    test('Should be able to initialise', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

// testing for timeouts, helpful in API calls and checking for slow responses
    test('User should be null after initialisation', () async {
      await provider.initialize();
      expect(provider.getCurrentUser, null);
    });

    test('should be able to initliase in less than 2 seconds', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    }, timeout: const Timeout(Duration(seconds: 2)));

    test('create user should delegate to login', () async {
      await provider.initialize();
      final badEmailUser = provider.createUser(
        email: 'foo@bar.com',
        password: 'anypassword',
      );
    });
  }); // end of group
}

class NotInitializedException implements Exception {}

class MockAuthProivder implements AuthProvider {
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;
  AuthUser? _user;
  @override
  Future<AuthUser> createUser(
      {required String email, required String password}) async {
    if (!_isInitialized) {
      throw NotInitializedException();
    }

    await Future.delayed(const Duration(seconds: 1));

    return logIn(email: email, password: password);
  }

  @override
  AuthUser? get getCurrentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1), () {
      _isInitialized = true;
    });
  }

  @override
  Future<AuthUser> logIn({required String email, required String password}) {
    if (!_isInitialized) {
      throw NotInitializedException();
    }

    if (email == 'foo@bar.com') throw UserNotFoundAuthException();
    if (password == 'wrongpassword') throw WrongPasswordAuthException();

    const user = AuthUser(isEmailVerified: false);
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!_isInitialized) {
      throw NotInitializedException();
    }

    if (_user == null) {
      throw UserNotLoggedInAuthException();
    }

    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!_isInitialized) {
      throw NotInitializedException();
    }

    final user = _user;
    if (user == null) {
      throw UserNotFoundAuthException();
    }

    const updatedUser = AuthUser(isEmailVerified: true);
    _user = updatedUser;
  }
}
