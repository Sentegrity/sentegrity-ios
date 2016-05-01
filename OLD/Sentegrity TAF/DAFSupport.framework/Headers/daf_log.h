/*
 * (c) 2014 Good Technology Corporation. All rights reserved.
 */

#ifndef DAF_LOG_H
#define DAF_LOG_H

#include "DigitalAuthenticationFramework.h"
#ifdef HAS_USEFUL_H
# include "useful.h"
#else
# define PRINTF_LIKE(a,b)
#endif

enum DAFLogLevel
{
  DAFLog_Debug,      DAFLog_D = DAFLog_Debug,
  DAFLog_Verbose,    DAFLog_V = DAFLog_Verbose,
  DAFLog_Info,       DAFLog_I = DAFLog_Info,
  DAFLog_Warning,    DAFLog_W = DAFLog_Warning,
  DAFLog_Error,      DAFLog_E = DAFLog_Error
};

/** Emits (with printf-like semantics) \p fmt to whatever debug or logging
 *  output the platform has, followed by a newline or similar separator
 *  (so \p fmt should not end with a newline). */
extern void DAFLog(DAFLogLevel lvl, const char *fmt, ...) PRINTF_LIKE(2, 3);

/** Reports \p msg and then a string error code, similar to
 *  perror(). Error level is DAFLog_Verbose if no error,
 *  and DAFLog_Error if an error.
 */
extern void DAFLogError(const char *msg, DAError &err);

/** Logs a block of data to the DAF logging mechanism
 *  Data block is prefixed with given 'msg'. Note that, as
 *  a security measure, output from DAFLogData() disappears
 *  unless preprocessor macro DAF_ENABLE_INSECURE_DEBUG is defined.
 *  If you want to retain data output in release builds, use DAFLogData_Insecure().
 */
extern void DAFLogData_Insecure(DAFLogLevel lvl, const char *msg, const DAData &block);

#ifdef DAF_ENABLE_INSECURE_DEBUG
# define DAFLogData(lvl,msg,blk) DAFLogData_Insecure(lvl,msg,blk)
#else
# define DAFLogData(l,m,b)
#endif

#endif
