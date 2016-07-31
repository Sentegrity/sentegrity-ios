/*
 * (c) 2014 Good Technology Corporation. All rights reserved.
 */

#ifndef DAF_AUTH_COMMON_H
#define DAF_AUTH_COMMON_H

#include <cassert>
#include <cstdio>

#include "authglue.h"
#include "daf_auth_identify.h"
#include "daf_auth_state.h"

#include "basic_error.h"
#include "daf_log.h"

namespace DAFCrypto
{
  /* Clears data as best it can. */
  void zero_data(DAData &data);

  /* Applies SHA256 to msg and returns the result. */
  DAData sha256(const DAData &msg);

  /* Applies SHA512 to msg and returns the result. */
  DAData sha512(const DAData &msg);

  /* Returns len crypto-strength random bytes. */
  DAData random_bytes(size_t len);

  /* Returns len bytes of output from PBKDF2_SHA256(pw, salt, iterations). */
  DAData pbkdf2_sha256(const DAData &pw, const DAData &salt, unsigned iterations, size_t len);

  /* Returns len bytes of output from PBKDF2_SHA512(pw, salt, iterations). */
  DAData pbkdf2_sha512(const DAData &pw, const DAData &salt, unsigned iterations, size_t len);

  /* Base64 encodes in, returning the result. */
  std::string base64_encode(const DAData &in);

  /* Base64 decodes in into out, returning false if in is invalid.
   * out is cleared before appending the base64 encoding. */
  bool base64_decode(const std::string &in, DAData &out);
}

struct ProtocolError : public BasicError
{
  ProtocolError()
    : BasicError()
    , m_has_cause(false)
    , m_cause()
  {}

  void clear()
  {
    BasicError::clear();
    m_has_cause = false;
    m_cause.clear();
  }

  void getAsStringUTF8(std::string &str)
  {
    BasicError::getAsStringUTF8(str);
    if (m_has_cause)
    {
      str.append(" caused by ");
      str.append(m_cause);
    }
  }

  void set(int err, DAError &cause)
  {
    m_has_cause = true;
    m_cause.clear();
    cause.getAsStringUTF8(m_cause);
    setCode(err);
  }

  void set(int err)
  {
    clear();
    setCode(err);
  }

private:
  bool m_has_cause;
  std::string m_cause;
};

struct ProtocolResult
{
  ProtocolResult()
    : m_flags(0)
    , m_secret()
    , m_new_secret()
  {}

  ~ProtocolResult()
  {
    DAFCrypto::zero_data(m_secret);
    DAFCrypto::zero_data(m_new_secret);
  }

  ProtocolResult& withNewSecret(const DAData &secret)
  {
    m_new_secret = secret;
    m_flags |= has_new_secret;
    return *this;
  }

  ProtocolResult& withSecret(const DAData &secret)
  {
    m_secret = secret;
    m_flags |= has_secret;
    return *this;
  }

  bool getSecret(DAData &out) const
  {
    if (m_flags & has_secret)
    {
      out = m_secret;
      return true;
    } else {
      return false;
    }
  }

  bool getNewSecret(DAData &out) const
  {
    if (m_flags & has_new_secret)
    {
      out = m_new_secret;
      return true;
    } else {
      return false;
    }
  }

private:
  enum {
    has_state = 1,
    has_secret = 2,
    has_new_secret = 4
  };
  unsigned m_flags;
  std::string m_state;
  DAData m_secret;
  DAData m_new_secret;
};

#endif
