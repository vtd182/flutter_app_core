import 'package:flutter_app_core/src/http/oauth2/credentials_storages/oauth2_credentials_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:oauth2/oauth2.dart';

class Oauth2CredentialsSecureStorage extends Oauth2CredentialsStorage {
  final FlutterSecureStorage _storage;
  final String _key;

  Oauth2CredentialsSecureStorage(
    this._storage,
    this._key,
  );

  @override
  Future<Credentials?> get() async {
    final json = await _storage.read(key: _key);
    return json != null ? Credentials.fromJson(json) : null;
  }

  @override
  Future<bool> set(Credentials credentials) async {
    await _storage.write(key: _key, value: credentials.toJson());
    return true;
  }

  @override
  Future<bool> has() {
    return _storage.containsKey(key: _key);
  }

  @override
  Future<bool> remove() async {
    await _storage.delete(key: _key);
    return true;
  }
}
