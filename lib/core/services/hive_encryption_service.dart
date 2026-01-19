import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

class HiveEncryption {
  static const _keyName = 'hive_encryption_key';
  static final _secureStorage = FlutterSecureStorage();

  static Future<List<int>> getKey() async {
    final storedKey = await _secureStorage.read(key: _keyName);

    if (storedKey != null) {
      return base64Url.decode(storedKey);
    }

    final key = Hive.generateSecureKey();
    await _secureStorage.write(key: _keyName, value: base64UrlEncode(key));
    return key;
  }
}
