import 'package:oauth2/oauth2.dart';

abstract class Oauth2CredentialsStorage {
  Future<Credentials?> get();

  Future<bool> set(Credentials credentials);

  Future<bool> has();

  Future<bool> remove();
}
