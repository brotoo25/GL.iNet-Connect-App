import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:crypt/crypt.dart';

/// Helper class for Unix password hashing required by GL.iNet authentication
class CryptoHelper {
  /// Crypt base64 alphabet for encoding (different from standard base64)
  static const String _cryptBase64Alphabet =
      './0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';

  /// Normalize salt to extract up to 8 characters
  static String _normalizeSalt(String salt) {
    // Remove any existing hash prefix if present
    if (salt.startsWith(r'$1$')) {
      salt = salt.substring(3);
    }
    // Extract up to first $ or 8 characters
    final dollarIndex = salt.indexOf(r'$');
    if (dollarIndex != -1) {
      salt = salt.substring(0, dollarIndex);
    }
    // Limit to 8 characters
    return salt.length > 8 ? salt.substring(0, 8) : salt;
  }

  /// Convert integer value to crypt base64 encoding
  static String _to64(int value, int length) {
    final buffer = StringBuffer();
    var val = value;
    for (var i = 0; i < length; i++) {
      buffer.write(_cryptBase64Alphabet[val & 0x3f]);
      val >>= 6;
    }
    return buffer.toString();
  }

  /// Implements FreeBSD MD5-crypt algorithm (algorithm 1)
  static String md5Crypt(String password, String salt) {
    // Normalize salt to 8 characters
    final normalizedSalt = _normalizeSalt(salt);

    // Convert password and salt to bytes
    final passwordBytes = utf8.encode(password);
    final saltBytes = utf8.encode(normalizedSalt);

    // Step 1: Compute alternate sum (MD5(password + salt + password))
    var digest =
        md5.convert([...passwordBytes, ...saltBytes, ...passwordBytes]);
    var alternateBytes = digest.bytes;

    // Step 2: Start building the main hash
    var mainBytes = <int>[];
    mainBytes.addAll(passwordBytes);
    mainBytes.add(0x24); // '$'
    mainBytes.add(0x31); // '1'
    mainBytes.add(0x24); // '$'
    mainBytes.addAll(saltBytes);

    // Step 3: Add alternate bytes based on password length
    var passwordLength = passwordBytes.length;
    for (var i = passwordLength; i > 0; i -= 16) {
      mainBytes.addAll(alternateBytes.sublist(0, i > 16 ? 16 : i));
    }

    // Step 4: Add bits from password length
    for (var i = passwordLength; i > 0; i >>= 1) {
      if ((i & 1) != 0) {
        mainBytes.add(0);
      } else {
        mainBytes.add(passwordBytes[0]);
      }
    }

    // Step 5: Compute initial digest
    digest = md5.convert(mainBytes);
    var digestBytes = List<int>.from(digest.bytes);

    // Step 6: Perform 1000 rounds of mixing
    for (var round = 0; round < 1000; round++) {
      var roundBytes = <int>[];

      if ((round & 1) != 0) {
        roundBytes.addAll(passwordBytes);
      } else {
        roundBytes.addAll(digestBytes);
      }

      if (round % 3 != 0) {
        roundBytes.addAll(saltBytes);
      }

      if (round % 7 != 0) {
        roundBytes.addAll(passwordBytes);
      }

      if ((round & 1) != 0) {
        roundBytes.addAll(digestBytes);
      } else {
        roundBytes.addAll(passwordBytes);
      }

      digest = md5.convert(roundBytes);
      digestBytes = List<int>.from(digest.bytes);
    }

    // Step 7: Encode the final digest using crypt base64
    final output = StringBuffer();

    // Encode in specific order as per MD5-crypt specification
    final indices = [
      [0, 6, 12],
      [1, 7, 13],
      [2, 8, 14],
      [3, 9, 15],
      [4, 10, 5]
    ];

    for (var group in indices) {
      var value = (digestBytes[group[0]] << 16) |
          (digestBytes[group[1]] << 8) |
          digestBytes[group[2]];
      output.write(_to64(value, 4));
    }

    // Last group has only 2 bytes
    var value = digestBytes[11];
    output.write(_to64(value, 2));

    // Return in format $1$<salt>$<checksum>
    return '\$1\$$normalizedSalt\$${output.toString()}';
  }

  /// Implements SHA256-crypt using the crypt package (algorithm 5)
  static String sha256Crypt(String password, String salt) {
    final crypt = Crypt.sha256(password, salt: salt);
    return crypt.toString();
  }

  /// Implements SHA512-crypt using the crypt package (algorithm 6)
  static String sha512Crypt(String password, String salt) {
    final crypt = Crypt.sha512(password, salt: salt);
    return crypt.toString();
  }

  /// Computes Unix password hash based on the specified algorithm
  ///
  /// Takes algorithm as '1' (MD5-crypt), '5' (SHA256-crypt), or '6' (SHA512-crypt)
  /// Returns the full Unix hash string
  static String computeUnixHash(
      String password, String salt, String algorithm) {
    switch (algorithm) {
      case '1':
        return md5Crypt(password, salt);
      case '5':
        return sha256Crypt(password, salt);
      case '6':
        return sha512Crypt(password, salt);
      default:
        throw ArgumentError(
            'Unsupported algorithm: $algorithm. Use 1, 5, or 6.');
    }
  }

  /// Computes the final login hash for GL.iNet authentication
  ///
  /// By default (legacy), computes MD5 of 'username:unixHash:nonce'.
  /// On newer firmware, 'hash-method' from challenge may be 'sha256' or 'sha512'.
  static String computeLoginHash(
      String username, String unixHash, String nonce) {
    final input = '$username:$unixHash:$nonce';
    final bytes = utf8.encode(input);
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  /// Flexible variant that honors the 'hash-method' field from challenge
  /// method: 'md5' (default), 'sha256', or 'sha512'
  static String computeLoginHashWithMethod(
      String method, String username, String unixHash, String nonce) {
    final input = '$username:$unixHash:$nonce';
    final data = utf8.encode(input);
    switch (method.toLowerCase()) {
      case 'sha256':
        return sha256.convert(data).toString();
      case 'sha512':
        return sha512.convert(data).toString();
      case 'md5':
      default:
        return md5.convert(data).toString();
    }
  }
}
