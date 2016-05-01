/*
 * (c) 2014 Good Technology Corporation. All rights reserved.
 */

/** \file daf_auth_state.h
 *
 *  \brief Internal state stored by authglue library
 */

#ifndef DAF_AUTH_STATE_H
#define DAF_AUTH_STATE_H

#include "daf_auth_identify.h"

struct json_object;

/** \brief Long term state for authglue library
 *
 * This class is used internally by the authglue library.
 * The DAF implementation's startup data is embedded in
 * the data stored by the authglue layer. Note that, although
 * we distinguish between "no data was stored" and "an empty
 * length string was stored", the layers above us, in general,
 * do not.
 */
class DAAuthState
{
public:
  /** ctor with empty object. */
  DAAuthState();
  
  /** ctor with (deep) copy of another state object. */
  DAAuthState(const DAAuthState &other);

  /** assignment by deep copy. */
  void operator=(const DAAuthState &other);

  /** dtor, freeing underlying message. */
  ~DAAuthState();

  /** Produce a string format of underlying JSON message. */
  std::string marshal() const;

  /** Replace object by unmarshaling provided string, returning
   * false if that string has invalid JSON encoding. */
  bool unmarshal(const std::string &str);

  /* --- Auth class --- */
  /** Get the stored authentication class,
   * returning false if there is no valid
   * stored class. */
  bool getAuthClass(DAAuthClass &cls);

  /** Save the authentication class. */
  void setAuthClass(DAAuthClass cls);

  /* --- Key serial --- */
  /** Save the given key serial number. */
  void setKeySerial(const std::string &ks);

  /** Return true if we have a saved key serial number. */
  bool hasKeySerial();

  /** Retrieve saved key serial number, returning false
   * if there is no valid stored key serial number. */
  bool getKeySerial(std::string &ks_out);

  /* --- User string --- */
   
  /** Save (opaque) data as the user string */
  void setUserString(const std::string &us);
  
  /** Retrieve data stored by above call */
  bool getUserString(std::string &us_out);
  
  /* --- DAMessage --- */
  /** Save the contents of the given DAMessage (all fields). */
  void setDAMessage(const DAMessage &msg);

  /** Retrieve saved DAMessage contents into \p msg, returning
   ** false if there is not one, or if it is invalid. */
  bool getDAMessage(DAMessage &msg);

private:
  /* The underlying object.  Never NULL. */
  struct json_object *m_json;

  /* Take the given DAData contents, and make a json_object
   * which expresses it (as a base64 encoded string) */
  struct json_object * encodeBytes(const DAData &bytes);
  
  /* Take the given base64 encoded c-string, and fill in
   * \p out with the raw string.  Returns false if base64
   * encoding is broken. */
  bool decodeBytes(const char *b64_cstr, DAData &out);
 
  /* Set a simple string value in object. */
  void setString(const char *key, const char *val);

  /* Return true if there is a mapping of \p key to anything. */
  bool hasValue(const char *key);

  /* Retreive the string value of the mapping of \p key.
   * Returns false if there is no mapping, or it isn't
   * to a string. */
  bool getString(const char *key, std::string &out);
};

#endif
