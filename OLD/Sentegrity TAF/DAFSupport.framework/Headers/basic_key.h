/*
 * (c) 2014 Good Technology Corporation. All rights reserved.
 */

/** \file basic_key.h
 *
 *  \brief Base class and trivial implementations of DAKey
 */

#ifndef BASIC_KEY_H
#define BASIC_KEY_H

#include "DigitalAuthenticationFramework.h"

#include "basic_error.h"
#include "basic_metadata.h"

/** \brief Base class for simple keys
 *
 * This contains boiler-plate code for implementing
 * error and DAMetaData handling for keys. Note it is not
 * usable directly, as it provides no working operations.
 */
class BasicKey : public DAKey
{
public:
  /** Constructor
   * \param err reference to the BasicError object for the
   * DASession which contains this key.
   */
  BasicKey(BasicError &err)
    : m_error(err)
    , m_meta(m_error)
  {}

  DAMetaData & getInfo()
  {
    return m_meta;
  }

  virtual bool encrypt(DAMessage &msg) { return _notImpl(); }
  virtual bool decrypt(DAMessage &msg) { return _notImpl(); }
  virtual bool sign(DAMessage &msg) { return _notImpl(); }
  virtual bool verify(DAMessage &msg) { return _notImpl(); }
  virtual bool setData(const DAData &data) { return _notImpl(); }
  virtual bool getData(DAData &out) { return _notImpl(); }
  virtual bool generateMaterial() { return _notImpl(); }

  // Class-0 and Class-1 keys can use this base method,
  // as they provide no crypto mechanisms.
  virtual std::vector<DAMechanism> getMechanisms()
  {
    std::vector<DAMechanism> out;
    m_error.clear();
    return out;
  }
    
  /** \brief Set serial number to be returned by metadata 
   */
  void setSerial(const std::string &serial)
  {
    m_meta.setString(DA_SERIAL, serial);
  }

protected:
  BasicError &m_error;  ///< Reference to object where this key can report errors.
  BasicMetaData m_meta; ///< Metadata for this key. Subclasses can set fields within this data.
  bool _notImpl() { m_error.setCode(DAError::NOT_IMPLEMENTED); return false; }
  ///< Stub for not-implemented methods: sets a NOT_IMPLEMENTED error and returns false.
};

/** \brief Simple key implementation for class-0 devices
 *
 * This can be used directly if the key data is known at the
 * time the key object is created. Note that the key data is
 * retained in memory for the lifetime of the object; this may
 * make in unsuitable for high-security applications.
 */
class BasicReadonlyKey : public BasicKey
{
public:
  /** Constructor
   * \param err  reference to the BasicError object for the
   * \param data data block to return from \ref getData() method
   */
  BasicReadonlyKey(BasicError &err, const DAData &data)
    : BasicKey(err)
    , m_bytes(data)
  {
    m_meta.setFlag(DA_STORAGE, true);
  }
  
  virtual bool getData(DAData &out)
  {
    out = m_bytes;
    m_error.clear();
    return true;
  }
  
protected:
  DAData m_bytes; ///< Data to be returned by getData()
};

#endif
