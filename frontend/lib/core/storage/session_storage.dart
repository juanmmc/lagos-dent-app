import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/domain/models/auth_session.dart';
import '../../features/auth/domain/models/user_role.dart';

final sessionStorageProvider = Provider<SessionStorage>((ref) {
  return const SessionStorage(FlutterSecureStorage());
});

class SessionStorage {
  const SessionStorage(this._storage);

  final FlutterSecureStorage _storage;
  static AuthSession? _cachedSession;

  static AuthSession? get cachedSession => _cachedSession;

  static const _tokenKey = 'auth.token';
  static const _roleKey = 'auth.role';
  static const _personIdKey = 'auth.personId';
  static const _profileIdKey = 'auth.profileId';
  static const _deviceTokenKey = 'device.token';

  Future<void> save(AuthSession session) async {
    _cachedSession = session;
    await _storage.write(key: _tokenKey, value: session.token);
    await _storage.write(key: _roleKey, value: session.role.name);
    await _storage.write(key: _personIdKey, value: session.personId);
    await _storage.write(key: _profileIdKey, value: session.profileId);
  }

  Future<AuthSession?> read() async {
    final cached = _cachedSession;
    if (cached != null) return cached;

    final token = await _storage.read(key: _tokenKey);
    final role = await _storage.read(key: _roleKey);
    final personId = await _storage.read(key: _personIdKey);
    final profileId = await _storage.read(key: _profileIdKey);

    if (token == null ||
        role == null ||
        personId == null ||
        profileId == null) {
      return null;
    }

    final parsedRole = UserRole.values
        .where((it) => it.name == role)
        .firstOrNull;
    if (parsedRole == null) return null;

    final session = AuthSession(
      token: token,
      role: parsedRole,
      personId: personId,
      profileId: profileId,
    );

    _cachedSession = session;
    return session;
  }

  Future<void> clear() async {
    _cachedSession = null;
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _roleKey);
    await _storage.delete(key: _personIdKey);
    await _storage.delete(key: _profileIdKey);
  }

  // Device Token methods
  Future<void> saveDeviceToken(String token) async {
    await _storage.write(key: _deviceTokenKey, value: token);
  }

  Future<String?> getDeviceToken() async {
    return _storage.read(key: _deviceTokenKey);
  }

  Future<void> clearDeviceToken() async {
    await _storage.delete(key: _deviceTokenKey);
  }
}
