import 'package:encrypt/encrypt.dart';

class Encryption {
  var publicKey;
  var privateKey;

  Encryption(String userId);

  static String encryptAES(String userId) {
    String key = userId;
    int requirePadding = 16 - key.length % 16;
    for (int i = 0; i < requirePadding; i++) {
      key += "0";
    }

    var aesKey = Key.fromUtf8(key);
    var iv = IV.fromLength(16);

    var encrypter = Encrypter(AES(aesKey));
    return encrypter.encrypt(userId, iv: iv).base64.toString();
  }

  static String decryptAES(String userId, String encryptedData) {
    String key = userId;
    int requirePadding = 16 - key.length % 16;
    for (int i = 0; i < requirePadding; i++) {
      key += "0";
    }

    var aesKey = Key.fromUtf8(key);
    var iv = IV.fromLength(16);

    var encrypter = Encrypter(AES(aesKey));
    return encrypter.decrypt64(encryptedData, iv: iv);
  }
}
