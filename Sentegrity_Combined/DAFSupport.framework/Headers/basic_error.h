/*
 * (c) 2014 Good Technology Corporation. All rights reserved.
 */

/** \file basic_error.h
 *
 *  \brief Simple implementation of DAError
 */

#ifndef BASIC_ERROR_H
#define BASIC_ERROR_H
#include "DigitalAuthenticationFramework.h"

#include <cstdlib>

/** \brief Simple implementation of DAError
 *
 * Simple DAF implementations can use this as-is; more
 * complex implementations may wish to extend this, e.g. 
 * to record error codes returned by hardware devices.
 */
class BasicError : public DAError
{
public:
  BasicError() : m_err(0) {}

  virtual int getCode()
  {
    return m_err;
  }

  /** \brief Set error code in error code.
   *  \param e Error code (see DAError for values).
   *  \return true if success, false if error.
   */
  bool setCode(int e)
  {
    m_err = e;
    return (e==SUCCESS);
  }

  virtual void clear()
  {
    setCode(SUCCESS);
  }

  virtual void getAsStringUTF8(std::string &out)
  {
    switch (getCode())
    {
#if !(DOXYGEN)
#define F(code, str) case (code): out = str; break;
      ALL_ERRORS(F);
#undef F
#endif
    default:
      out = "Unknown error";
      abort(); /* Should never happen */
    }
  }

protected:
  int m_err; ///< Error code; see DAError for values
};

#endif
