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
  F(DAError::OS_ERROR, "Operating system call failed")
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
    {}

    /* Default destructor, copy constructor and assignment operator
     * is OK. */
    
    /** \brief Return Crypto Algorithm
     *
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

    /** \brief Set Crypto Algorithm
     */
    void setMechanism(const DAMechanism &mech)
    {
        m_mech = mech;
        m_flags |= HAVE_MECH;
    }

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
    
protected:
    DAData       m_plaintext;	///< Plaintext bytes
    DAData       m_ciphertext;	///< Ciphertext bytes
    DAData       m_iv;		///< IV bytes
    DAMechanism  m_mech;	///< Mechanism (OID)
    unsigned     m_flags;	///< Flags (\ref HAVE_PLAINTEXT etc)

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
 * by the object. Attributes can be of string, flag (boolean) or data (byte
 * block) types.
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
} DAAttrib;

/** \brief General Metadata interface
 *
 * Used for both sessions and keys.
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
     */
    virtual bool getString(DAAttrib which, std::string &data) =0;
    
    /** \brief Get boolean attribute
     *
     * 
     */
    virtual bool getFlag(DAAttrib which) =0;

    /** \brief Get byteblock attribute
     *
     */
    virtual bool getData(DAAttrib which, DAData &data) =0;
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
