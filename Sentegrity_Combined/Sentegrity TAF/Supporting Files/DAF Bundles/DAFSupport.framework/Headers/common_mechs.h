/*
 * (c) 2014 Good Technology Corporation. All rights reserved.
 */

/** \file common_mechs.h
 *
 *  \brief Commonly-used DAMechanism values
 */

#ifndef COMMON_MECHS_H
#define COMMON_MECHS_H

#include "DigitalAuthenticationFramework.h"

/** \brief Creates commonly-used \ref DAMechanism values
 *  
 * This class contains a collection of static methods to
 * return DAMechanism values representing commonly-used
 * cryptographic mechanisms.
 */
class CommonMech
{
public:
  /// id-hmacWithSHA224 from RFC4231
  static DAMechanism hmacWithSHA224() { return DAUtils::mkData("\x06\x08\x2a\x86\x48\x86\xf7\x0d\x02\x08"); }

  /// id-hmacWithSHA256 from RFC4231
  static DAMechanism hmacWithSHA256() { return DAUtils::mkData("\x06\x08\x2a\x86\x48\x86\xf7\x0d\x02\x09"); }

  /// id-hmacWithSHA384 from RFC4231
  static DAMechanism hmacWithSHA384() { return DAUtils::mkData("\x06\x08\x2a\x86\x48\x86\xf7\x0d\x02\x0a"); }

  /// id-hmacWithSHA512 from RFC4231
  static DAMechanism hmacWithSHA512() { return DAUtils::mkData("\x06\x08\x2a\x86\x48\x86\xf7\x0d\x02\x0b"); }

  /// id-aes128-CBC (NIST)
  static DAMechanism aes128_CBC() { return DAUtils::mkData("\x06\x09\x60\x86\x48\x01\x65\x03\x04\x01\x02"); }

  /// id-aes192-CBC (NIST)
  static DAMechanism aes192_CBC() { return DAUtils::mkData("\x06\x09\x60\x86\x48\x01\x65\x03\x04\x01\x16"); }

  /// id-aes256-CBC (NIST)
  static DAMechanism aes256_CBC() { return DAUtils::mkData("\x06\x09\x60\x86\x48\x01\x65\x03\x04\x01\x2a"); }

  /// id-aes128-GCM (NIST)
  static DAMechanism aes128_GCM() { return DAUtils::mkData("\x06\x09\x60\x86\x48\x01\x65\x03\x04\x01\x06"); }

  /// id-aes192-GCM (NIST)
  static DAMechanism aes192_GCM() { return DAUtils::mkData("\x06\x09\x60\x86\x48\x01\x65\x03\x04\x01\x1a"); }

  /// id-aes256-GCM (NIST)
  static DAMechanism aes256_GCM() { return DAUtils::mkData("\x06\x09\x60\x86\x48\x01\x65\x03\x04\x01\x2e"); }

  /// RSASSA-PKCS1-v1.5 sha1WithRSAEncryption from RFC2437
  static DAMechanism sha1WithRSAEncryption() { return DAUtils::mkData("\x06\x09\x2a\x86\x48\x86\xf7\x0d\x01\x01\x05"); }

  /// RSASSA-PKCS1-v1.5 sha224WithRSAEncryption from RFC5754
  static DAMechanism sha224WithRSAEncryption() { return DAUtils::mkData("\x06\x09\x2a\x86\x48\x86\xf7\x0d\x01\x01\x0e"); }

  /// RSASSA-PKCS1-v1.5 sha256WithRSAEncryption from RFC5754
  static DAMechanism sha256WithRSAEncryption() { return DAUtils::mkData("\x06\x09\x2a\x86\x48\x86\xf7\x0d\x01\x01\x0b"); }

  /// RSASSA-PKCS1-v1.5 sha384WithRSAEncryption from RFC5754
  static DAMechanism sha384WithRSAEncryption() { return DAUtils::mkData("\x06\x09\x2a\x86\x48\x86\xf7\x0d\x01\x01\x0c"); }

  /// RSASSA-PKCS1-v1.5 sha512WithRSAEncryption from RFC5754
  static DAMechanism sha512WithRSAEncryption() { return DAUtils::mkData("\x06\x09\x2a\x86\x48\x86\xf7\x0d\x01\x01\x0d"); }
  
  /// ecdsa-with-SHA224 from RFC5754
  static DAMechanism ecdsa_with_SHA224() { return DAUtils::mkData("\x06\x08\x2a\x86\x48\xce\x3d\x04\x03\x01"); }
  
  /// ecdsa-with-SHA256 from RFC5754
  static DAMechanism ecdsa_with_SHA256() { return DAUtils::mkData("\x06\x08\x2a\x86\x48\xce\x3d\x04\x03\x02"); }
  
  /// ecdsa-with-SHA384 from RFC5754
  static DAMechanism ecdsa_with_SHA384() { return DAUtils::mkData("\x06\x08\x2a\x86\x48\xce\x3d\x04\x03\x03"); }
  
  /// ecdsa-with-SHA512 from RFC5754
  static DAMechanism ecdsa_with_SHA512() { return DAUtils::mkData("\x06\x08\x2a\x86\x48\xce\x3d\x04\x03\x04"); }

  /// rsaEncryption from RFC2437
  static DAMechanism rsaEncryption() { return DAUtils::mkData("\x06\x09\x2a\x86\x48\x86\xf7\x0d\x01\x01\x01"); }
  
  /// id-RSAES-OAEP from RFC2437
  static DAMechanism RSAES_OAEP() { return DAUtils::mkData("\x06\x09\x2a\x86\x48\x86\xf7\x0d\x01\x01\x07"); }

  /// id-RSASSA-PSS from RFC3447
  static DAMechanism RSASSA_PSS() { return DAUtils::mkData("\x06\x09\x2a\x86\x48\x86\xf7\x0d\x01\x01\x0a"); }
};

#endif
