/*
 * (c) 2014 Good Technology Corporation. All rights reserved.
 */

#ifndef DAF_AUTH_IDENTIFY_H
#define DAF_AUTH_IDENTIFY_H

#include "DigitalAuthenticationFramework.h"

/** \file daf_auth_identify.h
 *
 * \brief Identification of DAF device capabilities.
 *
 * The DAF code (see authglue.h) assigns the device a
 * DAAuthClass value, based on the capabilities of
 * the keys which are available, and on attribute flags set
 * in the device's DAMetaData. This determines which calls
 * are made to the device implementation by DAAuthProtocol.
 *
 * The actual enum value is a bit-mask of DA_AUTH_HAS_CRYPTO,
 * DA_AUTH_PUBLIC flags, etc. The flags are coded such that
 * higher enum values are preferred over lower ones; the 
 * authglue code will pick the 'best' class to use if there is
 * a choice.
 * 
 * The ordering is:
 *
 *  - no-crypto < crypto
 *  - public < authenticated
 *  - asymmetric < symmetric (slower)
 *  - oneway < invertible
 *  - identity < storage
 *
 * Note that combinations of flags other than those given below are 
 * illegal.
 */

#define DA_AUTH_HAS_CRYPTO      0x01000000	///< Device can do cryptographic ops
#define DA_AUTH_NO_CRYPTO       0x00000000	///< Device has no usable crypto
#define DA_AUTH_CRYPTO_MASK     0xff000000	///< Mask for testing crypto capability


#define DA_AUTH_AUTHENTICATED   0x00010000	///< Device has \ref DA_PROTECTED_PATH and \ref DA_AUTHENTIC_PATH set
#define DA_AUTH_PUBLIC          0x00000000	///< Non-secure path to device (needs user password)
#define DA_AUTH_AUTH_MASK       0x00ff0000	///< Mask for testing secure path capability


#define DA_AUTH_CRYPT_SYMM      0x00002000	///< Can do symmetric crypto (encrypt/decrypt or MAC)
#define DA_AUTH_CRYPT_ASYMM     0x00001000	///< Can do asymmetic crypto (encrypt/decrypt or signature)
#define DA_AUTH_CRYPT_INVERT    0x00000200	///< Can do invertible transformation (i.e. encryption/decryption)
#define DA_AUTH_CRYPT_ONEWAY    0x00000100	///< Can do one-way transformation (signature or HMAC)
#define DA_AUTH_CRYPT_MASK      0x0000ff00	///< Mask for all crypto type flags
#define DA_AUTH_CRYPT_SYMM_MASK 0x0000f000	///< Mask for testing symmetric/asymmetric
#define DA_AUTH_CRYPT_INVT_MASK 0x00000f00	///< Mask for testing invertible/oneway
#define DA_AUTH_CRYPT_NONE      0x00000000	///< No usable crypto functions


#define DA_AUTH_HAS_STORAGE     0x00000010	///< Device can store data

#define DA_AUTH_VALID           0x00000001	///< Device is usable for authentication

/** \def DA_AUTH_PUBLIC
 * Devices which do not report both \ref DA_PROTECTED_PATH and \ref DA_AUTHENTIC_PATH
 * flags set are considered to have no secure connection for transmitting secret data.
 * For these devices, DAAuthProtocol will require that a user password is supplied
 * in addition to the data supplied by the device. These are hashed together to give
 * the authentication secret.
 */
 
#if !(DOXYGEN)
#define DA_AUTH_CLASSES(f)                    \
  f(DA_AUTH_CLASS_UNKNOWN, 0)                 \
  /* Identification-only. */                  \
  f(DA_AUTH_CLASS0,                           \
    DA_AUTH_NO_CRYPTO |                       \
    DA_AUTH_PUBLIC |                          \
    DA_AUTH_VALID)                            \
  /* Persistent storage. */                   \
  f(DA_AUTH_CLASS1_AUTHENTICATED,             \
    DA_AUTH_NO_CRYPTO |                       \
    DA_AUTH_AUTHENTICATED |                   \
    DA_AUTH_HAS_STORAGE |                     \
    DA_AUTH_VALID)                            \
  f(DA_AUTH_CLASS1_PUBLIC,                    \
    DA_AUTH_NO_CRYPTO |                       \
    DA_AUTH_PUBLIC |                          \
    DA_AUTH_HAS_STORAGE |                     \
    DA_AUTH_VALID)                            \
  /* Basic symmetric crypto. */               \
  f(DA_AUTH_CLASS2_AUTHENTICATED_INVERTIBLE,  \
    DA_AUTH_HAS_CRYPTO |                      \
    DA_AUTH_AUTHENTICATED |                   \
    DA_AUTH_CRYPT_SYMM |                      \
    DA_AUTH_CRYPT_INVERT |                    \
    DA_AUTH_VALID)                            \
  f(DA_AUTH_CLASS2_PUBLIC_INVERTIBLE,         \
    DA_AUTH_HAS_CRYPTO |                      \
    DA_AUTH_PUBLIC |                          \
    DA_AUTH_CRYPT_SYMM |                      \
    DA_AUTH_CRYPT_INVERT)                     \
  f(DA_AUTH_CLASS2_AUTHENTICATED_ONEWAY,      \
    DA_AUTH_HAS_CRYPTO |                      \
    DA_AUTH_AUTHENTICATED |                   \
    DA_AUTH_CRYPT_SYMM |                      \
    DA_AUTH_CRYPT_ONEWAY)                     \
  f(DA_AUTH_CLASS2_PUBLIC_ONEWAY,             \
    DA_AUTH_HAS_CRYPTO |                      \
    DA_AUTH_PUBLIC |                          \
    DA_AUTH_CRYPT_SYMM |                      \
    DA_AUTH_CRYPT_ONEWAY)                     \
  /* Public key crypto. */                    \
  f(DA_AUTH_CLASS3_AUTHENTICATED_INVERTIBLE,  \
    DA_AUTH_HAS_CRYPTO |                      \
    DA_AUTH_AUTHENTICATED |                   \
    DA_AUTH_CRYPT_ASYMM |                     \
    DA_AUTH_CRYPT_INVERT)                     \
  f(DA_AUTH_CLASS3_PUBLIC_INVERTIBLE,         \
    DA_AUTH_HAS_CRYPTO |                      \
    DA_AUTH_PUBLIC |                          \
    DA_AUTH_CRYPT_ASYMM |                     \
    DA_AUTH_CRYPT_INVERT)                     \
  f(DA_AUTH_CLASS3_AUTHENTICATED_ONEWAY,      \
    DA_AUTH_HAS_CRYPTO |                      \
    DA_AUTH_AUTHENTICATED |                   \
    DA_AUTH_CRYPT_ASYMM |                     \
    DA_AUTH_CRYPT_ONEWAY)                     \
  f(DA_AUTH_CLASS3_PUBLIC_ONEWAY,             \
    DA_AUTH_HAS_CRYPTO |                      \
    DA_AUTH_PUBLIC |                          \
    DA_AUTH_CRYPT_ASYMM |                     \
    DA_AUTH_CRYPT_ONEWAY)
#endif

/* Class 4 devices get identified as one of the above for the
 * purposes of authentication. */

/** \brief Authentication device type
 */
enum DAAuthClass
{
#if DOXYGEN
#error "This section purely for documentation, do not compile"
  DA_AUTH_CLASS_UNKNOWN,
  /**< \ref DAIdentifyAuthDevice was unable to find a usable key for authentication (this is an error).
   */
  DA_AUTH_CLASS0,
  /**< At least one key has the \ref DA_STORAGE flag set (but not \ref DA_READ_WRITE).
   * A class 0 device is capable of providing a single, fixed value to
   * identify itself; this value is presented as a DAKey (see BasicReadonlyKey)
   * and is read via the getData() method.
   */
  DA_AUTH_CLASS1_PUBLIC,
  /**< One or more keys has \ref DA_STORAGE and \ref DA_READ_WRITE flags set.
   * A class 1 device must be able to store and recall at least one data block
   * of size \ref DAKey::STORAGE_MESSAGE_SIZE. This data block is used as an authentication
   * secret.
   */
  DA_AUTH_CLASS1_AUTHENTICATED,
  /**< As \ref DA_AUTH_CLASS1_PUBLIC, but device has 'secure' communications.
   */
  DA_AUTH_CLASS2_AUTHENTICATED_INVERTIBLE,
  /**< One or more keys does symmetric encryption and decryption.
   * The DAAuthProtocol will use the key to encrypt a short (\ref DAKey::ENCRYPT_MESSAGE_SIZE
   * bytes) random value; the ciphertext is stored on disk. During the authentication
   * sequence the ciphertext is decrypted using the same key, and the plaintext
   * used as the authentication secret.
   */
  DA_AUTH_CLASS2_AUTHENTICATED_ONEWAY,
  /**< One or more keys does MAC generation or similar.
   *
   * For these devices, DAF will ask for the MAC of a random input message to be
   * generated. The input block (size \ref DAKey::ONEWAY_MESSAGE_SIZE) is stored on disk;
   * the generated MAC is used as an authentication secret.
   */
  DA_AUTH_CLASS2_PUBLIC_INVERTIBLE,
  /**< One or more keys does symmetric encryption/decryption; no secure path to device.
   * Some devices may offer cryptographic operations, but do not have a secure
   * communications channel to the phone to transmit the data. \ref DAIdentifyAuthDevice
   * will identify and use such a device, but it is deprecated and support may be
   * withdrawn, or disabled by policy, in a future release.
   */
  DA_AUTH_CLASS2_PUBLIC_ONEWAY,
  /**< <em>Deprecated, see DA_AUTH_CLASS2_PUBLIC_INVERTIBLE</em>.
   */
  DA_AUTH_CLASS3_AUTHENTICATED_INVERTIBLE,
  /**< One or more keys does public key encryption / decryption.
   * Operation is like \ref DA_AUTH_CLASS2_AUTHENTICATED_INVERTIBLE; the key must
   * be able to encrypt and decrypt a message of length \ref DAKey::ENCRYPT_MESSAGE_SIZE.
   */
  DA_AUTH_CLASS3_AUTHENTICATED_ONEWAY,
  /**< One or more keys does signature with a public-key algorithm.
   * Note that this must be a <em>deterministic</em> signature algorithm, as the 
   * value of the signature is used as the authentication secret.  
   */
  DA_AUTH_CLASS3_PUBLIC_INVERTIBLE,
  /**< <em>Deprecated, see \ref DA_AUTH_CLASS2_PUBLIC_INVERTIBLE</em>.
   */
  DA_AUTH_CLASS3_PUBLIC_ONEWAY,
  /**< <em>Deprecated, see \ref DA_AUTH_CLASS2_PUBLIC_INVERTIBLE</em>.
   */
#else
#define C(tag,val) tag = val,
  DA_AUTH_CLASSES(C)
#undef C
#endif
};

/** Examines a key from the given device (\p dev and \p key) and decides
 *  which authentication protocol class we should use, only considering
 *  this key.
 *
 *  Returns false if we can't work out what class to use. */
bool DAIdentifyAuthKey(DADevice &dev, DAKey &key, DAAuthClass &class_out);

/** Examines the device and session (\p dev and \p sess) and decides
 *  which authentication protocol class we should use.
 *
 *  Returns false if we can't work out what class to use (for instance,
 *  because the session has no keys available). */
bool DAIdentifyAuthDevice(DADevice &dev, DASession &sess, DAAuthClass &class_out);

/** Stringifies a member of the DAAuthClass enum. */
const char * DAAuthClassToString(DAAuthClass cls);

/** Reverses DAAuthClassToString, returning DA_AUTH_CLASS_UNKNOWN for invalid values. */
DAAuthClass DAStringToAuthClass(const char *str);

#endif

