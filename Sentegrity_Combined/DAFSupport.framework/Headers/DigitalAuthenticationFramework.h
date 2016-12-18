/*
 * (c) 2014 Good Technology Corporation. All rights reserved.
 */

/** \file DigitalAuthenticationFramework.h
 *
 *  \brief Main C++ interface to authentication device
 */

#ifndef DIGITALAUTHENTICATIONFRAMEWORK_H
#define DIGITALAUTHENTICATIONFRAMEWORK_H

#include <string>
#include <cstring>
#include <vector>
#include <stdint.h>

/** \brief Identifies the version of the DAF SDK
 */
extern "C" const char *DAF_SDK_version_string;

/** \brief A data block represented as a sequence of bytes.
 *
 * Used in a number of places to hold cryptographic plaintexts and
 * ciphertexts, and as various kinds of authentication data. DAUtils
 * provides a few convenience functions for creating these.
 */
typedef std::vector<uint8_t> DAData;

/** \brief Identifier of a cryptographic mechanism.
 * 
 *  Mechanisms are specified using the DER encoding of their OID; this
 *  takes the form of a sequence of bytes. Class CommonMech provides
 *  convenience functions for constructing commonly-used mechanism
 *  identifiers.
 */
typedef std::vector<uint8_t> DAMechanism;

// forward declarations
class DADriver;
class DAError;
class DADevice;
class DAMetaData;
class DASession;
class DAKey;
class DAMessage;

/** \brief Top-level functions provided by the device driver.
 *
 */
class DADriver
{
public:
    /** \brief Initialization function
     *
     * This must be called during app startup, before any
     * other calls, and before any UI is displayed.
     */
    static void initialize();

    /** \brief Returns pointer to device object. NB how this
     *   is chosen is not determined by this interface, it's
     *   assumed a device-specific UI will choose it.
     *
     *  \return Pointer to device object, or NULL if error.
     *          Note you don't own this pointer, and shouldn't
     *          try to delete it when you no longer need it.
     */
    static DADevice *getDevice();

    /** \brief Get current error status for device driver.
     *         You can check this at any time, even if no 
     *         error has occurred.
     */
    static DAError &getLastError();
};

/** \brief Interface for error reporting
 *
 */
class DAError
{
public:
    enum {
      SUCCESS             = 0, ///< No error occurred
      NO_MEMORY           = 1, ///< General memory allocation failure
      NOT_PROVISIONED     = 2, ///< Driver has not been set up with a device.
      DEVICE_NOT_FOUND    = 3, ///< Cannot find the device.
      NO_MORE_SESSIONS    = 4, ///< The maximum allowed number of concurrent sessions are already connected.
      DEVICE_DISCONNECTED = 5, ///< Link to device lost unexpectedly
      DEVICE_PROTOCOL_ERR = 6, ///< Error from protocol stack talking to device
      BAD_AUTH_TOKEN      = 7, ///< authToken provided to CreateSession was bad
      KEY_NOT_FOUND       = 8, ///< Requested key does not exist
      ATTRIB_NOT_FOUND    = 9, ///< Requested attribute not available.
      MECH_NOT_FOUND      = 10, ///< Requested mechanism is not supported
      VERIFY_FAILED       = 11, ///< Verification of signature failed
      NOT_IMPLEMENTED     = 12, ///< Method is not implemented
      BAD_PARAMETERS      = 13, ///< Missing or invalid parameters to method
      OS_ERROR            = 14, ///< Operating system call failed
      UNSUPPORTED_HASH    = 15, ///< Requested hash function cannot be used here
    };
    // ... and so on. Derived classes will doubtless need their own.
  
    /** \brief virtual destructor
     *
     */
    virtual ~DAError() {};

    /** \brief get error code
     *
     * \return SUCCESS if no error, otherwise NO_MEMORY, NOT_PROVISIONED etc
     */
    virtual int getCode() =0;

    /** \brief test if error has occurred
     *
     */
    bool isError() { return getCode() != SUCCESS; };

    /** \brief reset the current error state.
     *
     */
    virtual void clear() =0;

    /** \brief get error as string message.
     *
     * Note there is deliberately no success/failure indication 
     * for this method.
     */
    virtual void getAsStringUTF8(std::string &errmsg) =0;
};

#if !(DOXYGEN)
#define ALL_ERRORS(F) \
  F(DAError::SUCCESS, "Success") \
  F(DAError::NO_MEMORY, "General memory allocation failure") \
  F(DAError::NOT_PROVISIONED, "Driver has not been set up with a device") \
  F(DAError::DEVICE_NOT_FOUND, "Cannot find the device") \
  F(DAError::NO_MORE_SESSIONS, "The maximum allowed number of concurrent sessions are already connected") \
  F(DAError::DEVICE_DISCONNECTED, "Link to device lost unexpectedly") \
  F(DAError::DEVICE_PROTOCOL_ERR, "Error from protocol stack talking to device") \
  F(DAError::BAD_AUTH_TOKEN, "authToken provided to CreateSession was bad") \
  F(DAError::KEY_NOT_FOUND, "Requested key does not exist") \
  F(DAError::ATTRIB_NOT_FOUND, "Requested attribute not available") \
  F(DAError::MECH_NOT_FOUND, "Requested mechanism is not supported") \
  F(DAError::VERIFY_FAILED, "Invalid signature or ciphertext") \
  F(DAError::NOT_IMPLEMENTED, "Function or method is not implemented") \
  F(DAError::BAD_PARAMETERS, "Missing or invalid parameters to method") \
  F(DAError::OS_ERROR, "Operating system call failed") \
  F(DAError::UNSUPPORTED_HASH, "Requested hash function cannot be used here")
#endif

/** \brief Interface to device object.
 *
 * Note this generally represents configured information about
 * a hardware device. The device itself doesn't have to be
 * connected at the time this object exists.
 */
class DADevice
{
public:
    /** \brief virtual destructor
     *
     */
    virtual ~DADevice() {};

    /** \brief Get metadata object describing device
     *
     * \return Reference to metadata object. This can be
     *         assumed to stay static throughout the life
     *         of the DADevice object.
     */
    virtual DAMetaData &getInfo () =0;

    /** \brief Connects to the authentication device, using
     *         the supplied credentials. 
     *
     * \param authToken Opaque authorisation data, returned by
     *                  device-specific UI.
     * \return Pointer to session, or NULL if error. This pointer
     *         should be deleted to close the session. 
     */
    virtual DASession *createSession (DAData &authToken) =0;
    
    /** \brief Return current error status. You can check this
     *         at any time, even if no error has occurred.
     */
    virtual DAError &getLastError() =0;
};

/** \brief Interface to "session" object.
 *
 * A session represents a live connection to a device. 
 * Keys are only visible when the device is connected.
 */
class DASession
{
public:
    /** \brief virtual destructor
     *
     */
    virtual ~DASession() {};

    /** \brief Get reference to device object for this session.
     */
    virtual DADevice &getDevice () =0;
    
    /** \brief Get metadata object describing connected device
     *
     * Note that at present, we don't have any attributes which
     * are session-specific, so this can return the same
     * information as \ref DADevice::getInfo().
     */
    virtual DAMetaData &getInfo () =0;

    /** \brief Check if communication to device is currently working.
     *
     *  May be used to poll for user-initiated
     *  device disconnection. Generally, you'll have to
     *  delete the session and recreate it once the
     *  connection has been dropped.
     */
    virtual bool isConnected() =0;
    
    /** \brief Get number of keys that this session has access to.
     * 
     * \return Number of keys (>=0), or < 0 if error.
     */
    virtual int getKeyCount() =0;
    
    /** \brief Get key by index.
     * \param  index - Key index from 0 to DASession::GetKeyCount()-1
     *         Note that there is no promise that key indices remain
     *         consistent between different sessions; this method is
     *         largely useful for enumerating all keys within one session.
     * \return Pointer to a key object, or NULL if error. The caller doesn't
     *         own this pointer, and shouldn't try to delete it.
     */
    virtual DAKey *getKey(int index) =0;
    
    /** \brief Get key by serial number
     *  \param serial - serial number string; if the call succeeds this
     *         will exactly match the DA_SERIAL attribute from the returned
     *         key.
     * \return Pointer to a key object, or NULL if error. The caller doesn't
     *         own this pointer, and shouldn't try to delete it.
     */
    virtual DAKey *getKey(const std::string &serial) =0;
    
    /** \brief Return current error status. You can check this
     *         at any time, even if no error has occurred.
     */
    virtual DAError &getLastError() =0;
};

/** \brief Interface to Key objects
 *
 * Keys are owned by DASession objects, and operate on DAMessages.
 */
class DAKey
{
public:
    /** \brief virtual destructor
     *
     */
    virtual ~DAKey() {};
    
    /** \brief get metadata object describing this key
     *
     */
    virtual DAMetaData &getInfo()=0;

    /** \brief Encrypt the given message
     * Returns success = true
     */
    virtual bool encrypt(DAMessage &msg)=0;

    /** \brief Decrypt the given message
     * Returns success = true
     */
    virtual bool decrypt(DAMessage &msg)=0;

    /** \brief Sign the given message
     * Returns success = true
     */
    virtual bool sign(DAMessage &msg)=0;

    /** \brief Verify the given message
     * Returns success = true
     */
    virtual bool verify(DAMessage &msg)=0;

    /** \brief Retrieve key data
     *
     * This is only called for class-0 and class-1 keys. Keys
     * capable of cryptographic operation should not implement this.
     *
     * Returns success = true
     */
    virtual bool getData(DAData &data)=0;

    /** \brief Set key data
     *
     * For class-1 keys, this is called during the 'change
     * 'passphrase' sequence, if generateMaterial() returns
     * a NOT_IMPLEMENTED error. The data to be stored will be
     * 32 bytes (STORAGE_MESSAGE_SIZE) bytes long.
     * If the key cannot store messages of this size, it
     * must implement the generateMaterial() method.
     *
     * Returns success = true
     */
    virtual bool setData(const DAData &data)=0;

    /** \brief Generates or regenerates key material.
     *
     * For class-1 keys, this is called during the 'change
     * passphrase' sequence to roll over a key. This should replace the
     * key's current value with new, random data. This method may
     * return a NOT_IMPLEMENTED error, in which case the DAF logic
     * will call setData(). 
     *
     * Returns success = true, false if error
     */
    virtual bool generateMaterial()=0;

    /** \brief Return a vector of mechanisms supported by this key.
     */
    virtual std::vector<DAMechanism> getMechanisms() =0;
    
    static const int STORAGE_MESSAGE_SIZE = 32;
    /**< \brief Size of random data stored for class-1 keys
     */

    static const int ENCRYPT_MESSAGE_SIZE = 32;
    /**< \brief Size of plaintext message passed to class 2 and 3 encrypt-decrypt keys
     */
    
    static const int ONEWAY_MESSAGE_SIZE = 32;
    /**< \brief Size of plaintext message passed to class 2 and 3 MAC/signature keys
     */
};

/** \brief Identification of hash algorithm used for signature. 
 *
 * For signatures using public-key algorithms, the caller may deliver
 * the hash of a message instead of the message itself. The hash algorithm
 * used is identified using a DADigestType enum.
 */
typedef enum
{
  DA_DIGEST_NONE = 0, ///< Message has not been hashed
  
  DA_DIGEST_SHA1 = 1,   ///< SHA-1 hash (20 bytes)
  DA_DIGEST_SHA224 = 2, ///< SHA-224 hash (28 bytes)
  DA_DIGEST_SHA256 = 3, ///< SHA-256 hash (32 bytes)
  DA_DIGEST_SHA384 = 4, ///< SHA-384 hash (48 bytes)
  DA_DIGEST_SHA512 = 5, ///< SHA-512 hash (64 bytes)
  
  DA_DIGEST_SSL3_MD5_SHA1 = 6, ///< 36-byte MD5+SHA1 dual hash, used by SSL3 and TLS 1.0-1.1
}
  DADigestType;

/** \brief Encapsulates a message and various (optional) crypto parameters
 *
 * Keys operate on Messages.
 *
 */
class DAMessage
{
public:
    /** \brief Constructor
     * Creates an empty message with all zero-length entries.
     */
    DAMessage()
        : m_plaintext()
        , m_ciphertext()
        , m_iv()
        , m_mech()
        , m_flags(0)
        , m_digestType(DA_DIGEST_NONE)
    {}

    /* Default destructor, copy constructor and assignment operator
     * is OK. */
    
    /** \brief Return cryptographic mechanism identifier.
     *
     * This is, in most cases, a value chosen from class CommonMech.
     * It is set by the DAKey::sign() and DAKey::encrypt() methods, and
     * must be set by the called before DAKey::verify() and DAKey::decrypt().
     *
     * \return true if a mechanism was set (and mech had a value assigned).
     * Returns false if no mechanism is set.
     */
    bool getMechanism(DAMechanism &mech) const
    {
        if (m_flags & HAVE_MECH)
        {
            mech = m_mech;
            return true;
        } else {
            return false;
        }
    }
    
    /** \brief Return IV
     */
    bool getIV(DAData &iv) const
    {
        if (m_flags & HAVE_IV)
        {
            iv = m_iv;
            return true;
        } else {
            return false;
        }
    }
    
    /** \brief Get the original plaintext/signed message
     */
    bool getPlaintext(DAData &data) const
    {
        if (m_flags & HAVE_PLAINTEXT)
        {
            data = m_plaintext;
            return true;
        } else {
            return false;
        }
    }

    /** \brief Get the final encrypted message or signature
     */
    bool getCiphertext(DAData &data) const
    {
        if (m_flags & HAVE_CIPHERTEXT)
        {
            data = m_ciphertext;
            return true;
        } else {
            return false;
        }
    }

    /** \brief Gets digest (hash) type used for signature
     * \return DA_DIGEST_NONE if message is not hashed
     */
    DADigestType getDigestType() const
    {
        return m_digestType;
    }

    /** \brief Set Crypto Algorithm
     */
    void setMechanism(const DAMechanism &mech)
    {
        m_mech = mech;
        m_flags |= HAVE_MECH;
    }

    /** \brief Set mechanism appropriately for RSA-SSA-PKCS1 signatures.
     *
     *   Chooses a suitable DAMechanism (see common_mechs.h) for the
     *   hash algorithm identified by the m_digestType field, and sets
     *   it as the m_mech field.
     *
     *   \return false if invalid mechanism in m_digestType.
     */
    bool setMechanismForRSAPkcs1Signature();

    /** \brief Set mechanism appropriately for DSA algorithm.
     *
     *  Chooses a suitable DAMechanism (see common_mechs.h) for the 
     *  hash algorithm identified by the m_digestType field, and sets
     *  it as the m_mech field.
     *
     *  \return false if invalid mechanism in m_digestType.
     */
    bool setMechanismForDSA();
    
    /** \brief Set mechanism appropriately for ECDSA algorithm.
     *
     *  Chooses a suitable DAMechanism (see common_mechs.h) for the 
     *  hash algorithm identified by the m_digestType field, and sets
     *  it as the m_mech field.
     *
     *  \return false if invalid mechanism in m_digestType.
     */
    bool setMechanismForECDSA();

    /** \brief Set IV
     */
    void setIV(const DAData &iv)
    {
        m_iv = iv;
        m_flags |= HAVE_IV;
    }
    
    /** \brief Set plaintext buffer
     */
    void setPlaintext(const DAData &data)
    {
        m_plaintext = data;
        m_flags |= HAVE_PLAINTEXT;
    }
    
    /** \brief Set ciphertext buffer
     */
    void setCiphertext(const DAData &data)
    {
        m_ciphertext = data;
        m_flags |= HAVE_CIPHERTEXT;
    }

    /** \brief Set digest type
     */
    void setDigestType( DADigestType dtype )
    {
        m_digestType = dtype;
    }
    
    /** \brief Remove Crypto Algorithm */
    void unsetMechanism()
    {
        m_mech = DAMechanism();
        m_flags &= ~HAVE_MECH;
    }

    /** \brief Remove IV */
    void unsetIV()
    {
        m_iv = DAData();
        m_flags &= ~HAVE_IV;
    }

    /** \brief Remove plaintext */
    void unsetPlaintext()
    {
        m_plaintext = DAData();
        m_flags &= ~HAVE_PLAINTEXT;
    }

    /** \brief Remove ciphertext */
    void unsetCiphertext()
    {
        m_ciphertext = DAData();
        m_flags &= ~HAVE_CIPHERTEXT;
    }
    
    /** \brief Unset digestType */
    void unsetDigestType()
    {
      setDigestType(DA_DIGEST_NONE);
    }

    /** \brief Ensure a DAMessage contains a message hash for signature.
     *
     * If the digest type (see getDigestType()) is not DA_DIGEST_NONE,
     * leaves the message unchanged, and returns true.
     *
     * Otherwise, if the mechanism (see getMechanism()) has already been
     * set, applies the hash algorithm appropriate to that mechanism. The
     * message's plaintext field is replaced by the hash, and the digest
     * type is set accordingly. This method will return true if the 
     * operation succeeded, and false if the mechanism was not recognised.
     *
     * If the mechanism was not set, a default hash algorithm is chosen
     * (in this release, SHA-256). The plaintext is replaced by its hash, 
     * and the digest type field is set (to DA_DIGEST_SHA256). The method
     * then returns true.
     *
     * \return true if operation succeeded, false if the mechanism was set
     * on entry but not for a supported hash type.
     */
    bool applyDefaultDigest();
    
    /** \brief Create a byte string suitable for RSA PKCS#1 signature
     *
     *  \param msg Byte-block returned. This is the DER encoding of a SEQUENCE 
     *     containing the OID of the hash function followed by the hash value.
     *     See e.g. RFC 3447 section 9.2. This function will also apply a default
     *     hash function if the message doesn't have a digest type set.
     *
     *  \return true if operation succeeded, false if the DAMessage is invalid/unsuitable.
     */
    bool getPkcs1SignatureData( DAData &msg );
    
    /** \brief Get hash type associated with a mechanism 
     *
     * \param mech  Specifier for an (asymmetric) signature mechanism
     * 
     * \return Digest type associated with this mechanism, or DA_DIGEST_NONE if it's unrecognised.
     */ 
    static DADigestType getDigestFromMech( const DAMechanism &mech );
    
protected:
    DAData       m_plaintext;	///< Plaintext bytes
    DAData       m_ciphertext;	///< Ciphertext bytes
    DAData       m_iv;		///< IV bytes
    DAMechanism  m_mech;	///< Mechanism (OID)
    unsigned     m_flags;	///< Flags (\ref HAVE_PLAINTEXT etc)
    DADigestType m_digestType; ///< Digest used for signed message

    enum {
      HAVE_PLAINTEXT = 1,	///< m_plaintext has been set
      HAVE_CIPHERTEXT = 2,	///< m_ciphertext has been set
      HAVE_IV = 4,		///< m_iv has been set
      HAVE_MECH = 8		///< m_mech has been set
    };
};

/** \brief Attribute selector
 *
 * A DADevice object, and each DAKey object, has a number of attributes
 * to describe it. These are accessed via the DAMetaData interface provided
 * by the object. Attributes can be of string, flag (boolean), data (byte
 * block) or size (integer) types.
 */
typedef enum
{
    DA_NAME             = 0,    ///< (string) User-visible name of device or key
    DA_SERIAL           = 2,    ///< (string) Unique serial number of device or key

    DA_HARDWARE         = 1000, ///< (flag) True if implemented in hardware
    DA_PROTECTED_PATH   = 1002, ///< (flag) True if path to device has eavesdropping protection
    DA_AUTHENTIC_PATH   = 1003, ///< (flag) True if path to device is authenticated
    DA_PASSWORD_AUTH    = 1004, ///< (flag) True if authentication token is regular password
    
    DA_SMIME_SIGN       = 1100, ///< (flag) True if key can be used for S/MIME signing
    DA_SMIME_DECRYPT    = 1101, ///< (flag) True if key can be used for S/MIME decryption
    DA_USER_AUTHENTICATE= 1102, ///< (flag) True if key can be used for user authentication
    DA_TLS_CLIENT_AUTH  = 1103, ///< (flag) True if key can be used for SSL/TLS client auth
    DA_READ_WRITE       = 1104, ///< (flag) True if SetData() and/or GenerateMaterial() work
    DA_STORAGE          = 1105, ///< (flag) True if GetData() and SetData() work
    DA_SYMM_CRYPT       = 1106, ///< (flag) True if both encrypt() and decrypt() work
    DA_SYMM_SIGN        = 1107, ///< (flag) True if both sign() and verify() work
    
    DA_CERTIFICATE      = 2100, ///< (data) X.509 certificate for key

    DA_SIGNATURE_SIZE   = 3000, ///< (size) Size of signature in bytes
    DA_MAX_DECRYPT_SIZE = 3001, ///< (size) Max size of a decrypted plaintext (in bytes)
} DAAttrib;

/** \brief General metadata interface
 *
 * All objects which can have attributes (see DAAttrib) provide an implementation
 * of the DAMetaData interface (generally returned by that object's getInfo()
 * method).
 *
 */
class DAMetaData
{
public:
    /** \brief Virtual Destructor
     *
     */
    virtual ~DAMetaData() {};
    
    /** \brief Get String attribute
     *
     * \param which  Identifies the attribute to get
     * \param data   On return, set to the value of the requested attribute.
     *
     * \return true if the key has the requested string attribute (and data
     * has been set). false if the requested attribute is not present.
     */
    virtual bool getString(DAAttrib which, std::string &data) =0;
    
    /** \brief Get boolean attribute
     *
     * \param which identifies the flag value to query
     *
     * \return true if the requested flag attribute is present, false
     * if the flag is not set / not present.
     *
     * Queries whether a particular flag is set. Note that there is
     * no semantic difference between a flag being 'not set' and the
     * flag attribute being 'not present'.
     */
    virtual bool getFlag(DAAttrib which) =0;

    /** \brief Get byteblock attribute
     *
     * For DA_CERTIFICATE attributes, index is set to 0 to return
     * the X.509 certificate for the key. If additional certificates
     * are required to validate this, these should be provided for
     * index=1, index=2, and so on. The caller can discover the certificate
     * chain by enumerating successive index values, until the method
     * returns false.
     *
     * \return true if the key has the requested attribute (and data
     * has been set). false if the requested attribute is not present. 
     */
    virtual bool getData(DAAttrib which, DAData &data, size_t index=0) =0;

    /** \brief Get size attribute
     *
     * Used with DA_SIGNATURE_SIZE and DA_MAX_DECRYPT_SIZE attributes to
     * return the sizes (in bytes) of signatures and decrypted data,
     * respectively.
     * Keys with DA_SMIME_SIGN or DA_TLS_CLIENT_AUTH flags set must
     * also have a DA_SIGNATURE_SIZE attribute. Keys with DA_SMIME_DECRYPT
     * must have DA_MAX_DECRYPT_SIZE.
     *
     * \return true if the key has the requested size attribute (and len_r
     * must have been set), false if the requested attribute is not present. 
     */
    virtual bool getSize(DAAttrib which, size_t &len_r) =0; 

};

/** \brief Utility functions
 *
 */
class DAUtils
{
public:
    /** \brief Create a DAData from pointer and length
     *  \param data pointer to data; this will be copied into the DAData object
     *  \param len  length of data in bytes
     */
    static DAData mkData(const void *data, size_t len)
    {
        DAData ret;
        const uint8_t *ptr = static_cast<const uint8_t *>(data);
        while (len-- > 0)
            ret.push_back(*ptr++);
        return ret;
    }

    /** \brief Create a DAData from a std::string
     *  \param str String to be copied. str.size() bytes are copied - this will not add
     *             a terminating 0 byte at the end.
     */
    static DAData mkData(std::string &str)
    {
        return mkData(str.data(), str.size());
    }

    /** \brief Create a DAData from a C string
     *  \param str Null-terminated C string to be copied. strlen(str) bytes are copied -
     *             this will not include the terminating 0 byte.
     */
    static DAData mkData(const char *str)
    {
        return mkData(str, strlen(str));
    }
    
};

#endif
