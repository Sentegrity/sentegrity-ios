/*
 * (c) 2014 Good Technology Corporation. All rights reserved.
 */

/** \file basic_metadata.h
 *
 *  \brief Basic implementation of DAMetaData
 */

#ifndef BASIC_METADATA_H
#define BASIC_METADATA_H

#include "DigitalAuthenticationFramework.h"

#include <map>

#include "basic_error.h"

/** \brief Simple implementation of DAMetaData
 *
 * Most DAF implementations can use this directly, assuming
 * the metadata values for the object are available at the time
 * that object is created.
 */
class BasicMetaData : public DAMetaData
{
public:
  /** \brief Constructor
   * Produces a metadata container with no values.
   *
   * \param err is the error reporting object for the object for which this is the
   *            metadata. Must be valid throughout the life of this object.
   */
  BasicMetaData(BasicError &err)
    : m_error(err)
    , m_strings()
    , m_flags()
    , m_datas()
  {}

  /** \brief Copy data values from another DAMetaData
   *
   * \param meta Must be a BasicMetaData object (FIXME- fails silently if not)
   */ 
  void copyFrom(const DAMetaData &meta)
  {
    const BasicMetaData *other = dynamic_cast<const BasicMetaData *>(&meta);
    if (other)
    {
      m_strings = other->m_strings;
      m_flags = other->m_flags;
      m_datas = other->m_datas;
    }
  }

  /** \brief Set a string attribute
   */
  void setString(DAAttrib which, const std::string &value)
  {
    m_strings[which] = value;
  }

  /** \brief Set a boolean(flag) attribute
   */
  void setFlag(DAAttrib which, bool value=true)
  {
    m_flags[which] = value;
  }

  /** \brief Set a byte-block attribute
   */
  void setData(DAAttrib which, const DAData &value)
  {
    m_datas[which] = value;
  }

  virtual bool getString(DAAttrib which, std::string &out)
  {
    string_map::iterator it = m_strings.find(which);

    if (it != m_strings.end())
    {
      out = it->second;
      m_error.clear();
      return true;
    }
  
    out = "";
    m_error.setCode(DAError::ATTRIB_NOT_FOUND);
    return false;
  }

  virtual bool getFlag(DAAttrib which)
  {
    flag_map::iterator it = m_flags.find(which);

    if (it != m_flags.end())
    {
      m_error.clear();
      return it->second;
    }
    
    m_error.setCode(DAError::ATTRIB_NOT_FOUND);
    return false;
  }

  virtual bool getData(DAAttrib which, DAData &out)
  {
    data_map::iterator it = m_datas.find(which);

    if (it != m_datas.end())
    {
      m_error.clear();
      out = it->second;
      return true;
    }
   
    out.clear();
    m_error.setCode(DAError::ATTRIB_NOT_FOUND);
    return false;
  }

protected:
  BasicError &m_error;  ///< Reference to error object to use on failure.

  typedef std::map<DAAttrib, std::string> string_map; ///< Holds string attributes
  typedef std::map<DAAttrib, bool> flag_map;          ///< Holds flag attributes
  typedef std::map<DAAttrib, DAData> data_map;        ///< Holds data attributes

  string_map m_strings; ///< Map containing all std::string attribute values
  flag_map m_flags;     ///< Map containing all bool attribute values
  data_map m_datas;     ///< Map containing all DAData attribute values
};

#endif
