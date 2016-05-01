/*
 * (c) 2014 Good Technology Corporation. All rights reserved.
 */

#ifndef DAF_AUTHGLUE_H
#define DAF_AUTHGLUE_H

#include "DigitalAuthenticationFramework.h"
#include "daf_auth_state.h"

/** \file authglue.h
 *
 *  \brief Performs DAF calls required for authentication sequences.
 *
 *  The 'authglue' library provides implementations of class DAAuthProtocol,
 *  and required support functions. A DAAuthProtocol object is created during
 *  the initial enrolment, authentication, and password-change (or key
 *  rollover) sequences, and is responsible for determining the class of the
 *  attached DAF device and making the appropriate sequence of calls to the DAF
 *  implementation. Where a user password is required, the DAAuthProtocol is also
 *  responsible for accepting the password and performing the required hashing to
 *  combine it with device secrets.
 *
 *  Call flow:
 *  - The user interface code calls \ref DAAuthEnroll, \ref DAAuthAuthenticate or
 *    \ref DAAuthChangePassphrase and receives ownership of a
 *    \p DAAuthProtocol object.
 *  - The caller checks \ref DAAuthProtocol::getLastError, \ref DAAuthProtocol::requiresExistingPassphrase
 *    and \ref DAAuthProtocol::requiresNewPassphrase flag functions, dealing with errors
 *    and passphrase acquisition as necessary.
 *    Note: authentication protocols do not do passphrase length,
 *    repetition or construction checking.  That needs to happen higher
 *    up.
 *  - The caller checks that \ref DAAuthProtocol::finished() returns true.
 *  - The caller passes the results of \ref DAAuthProtocol::getSecret and/or \ref DAAuthProtocol::getNewSecret
 *    to appropriate GD functions (unlockWithPassword,
 *    changePassword, setAuthProviderData, etc.)
 *  - The caller deletes the \p DAAuthProtocol object.
 *
 *  For each protocol, the results available via getSecret/getNewSecret are:
 *
 *  - Enrollment: \ref DAAuthProtocol::getNewSecret
 *  - Authentication: \ref DAAuthProtocol::getSecret
 *  - Change passphrase: \ref DAAuthProtocol::getSecret, and \ref DAAuthProtocol::getNewSecret
 *
 *  The \ref DAAuthState object passed in to \ref DAAuthEnroll and \ref DAAuthChangePassphrase
 *  will be modified, and should be saved in non-volatile storage.
 */

/** \brief Co-ordinates calls required for enrollment, authentication and passphrase change.
 *
 *  The 'authglue' library provides a variety of implementations of this 
 *  (abstract) class. See authglue.h documentation for an overview.
 *
 *  Implementations have their own error state, accessible via \ref getLastError.
 *  Implementations with an error set are not recoverable, and \ref finished()
 *  will never return true.  To retry, make another instance using the original
 *  function. */
class DAAuthProtocol
{
public:
  /** Virtual destructor. */
  virtual ~DAAuthProtocol() {}

  /** Retrieve the current error information for this protocol. */
  virtual DAError &getLastError() =0;

  /** Returns true if this protocol requires input of an existing user passphrase.
   *
   * See \ref DA_AUTH_PUBLIC in daf_auth_identify.h for more information. */
  virtual bool requiresExistingPassphrase() const =0;

  /** Inputs an existing passphrase.  Valid to call only if \p requiresExistingPassphrase()
   *  just returned true. */
  virtual bool inputExistingPassphrase(const std::string &string) =0;

  /** Returns true if this protocol requires input of a fresh passphrase.
   *
   * See \ref DA_AUTH_PUBLIC in daf_auth_identify.h for more information. */
  virtual bool requiresNewPassphrase() const =0;

  /** Inputs a fresh pasphrase.  Valid to call only if \p requiresNewPassphrase()
   *  just returned true. */
  virtual bool inputNewPassphrase(const std::string &string) =0;

  /** Returns true if this protocol instance completed successfully. */
  virtual bool finished() const =0;

  /** Extracts the resulting authentication secret.  This should
   *  is passed to the GD library and is used to protect the
   *  underlying container keys.
   *
   *  Valid to call only if \p finished() just returned true. */
  virtual bool getSecret(DAData &out) =0;

  /** Extracts the new authentication secret, as a result of a
   *  enrollment or passphrase change protocol.  For other protocols, this
   *  returns false.
   *
   *  Valid to call only if \p finished() just returned true. */
  virtual bool getNewSecret(DAData &out) =0;
};

/* All these return a heap-allocated DAAuthProtocol. The caller
 * must delete when done. */

/** Begins a DAF authentication enrollment process.
 *
 *  \p sess must be a working session associated with \p device.  Errors
 *  are reported either by this function returning NULL (if the device or session
 *  are broken or unidentifiable as offering authentication capabilities), or
 *  returning a DAAuthProtocol already in the error state (if the protocol
 *  went wrong, but didn't require any extra user input).
 *
 *  The returned object belongs to the caller and must be deleted. */
DAAuthProtocol * DAAuthEnroll(DADevice &device, DASession &sess, DAAuthState &state);

/** Begins a DAF re-authentication process.
 *
 *  The caller will have called \p DAAuthEnroll successfully sometime in the
 *  past with \p device and \p sess, and saved the resulting state, passed back in here
 *  as \p state.
 *
 *  Errors are reported either by returning NULL or returning a protocol object
 *  already in the error state.
 *
 *  The returned object belongs to the caller and must be deleted. */
DAAuthProtocol * DAAuthAuthenticate(DADevice &device, DASession &sess, DAAuthState &state);

/** Begins a DAF authentication roll-over process.
 *
 *  The caller will have called \p DAAuthEnroll successfully sometime in the past
 *  with \p device and \p sess, and saved the resulting state, passed back in here
 *  as \p state.
 *
 *  Errors are reported either by returning NULL or returning a protocol object
 *  already in the error state.
 *
 *  The returned object belongs to the caller and must be deleted. */
DAAuthProtocol * DAAuthChangePassphrase(DADevice &device, DASession &sess, DAAuthState &state);

#endif

