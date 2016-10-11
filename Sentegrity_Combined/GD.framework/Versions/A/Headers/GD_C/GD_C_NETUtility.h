/*
 * (c) 2016 BlackBerry Limited. All rights reserved.
 */

#include <stdio.h>

#ifndef GD_C_NETUTILITY_H
#define GD_C_NETUTILITY_H

/** \addtogroup capilist
 * @{
 */

/** Good Dynamics name service lookup completion callback.
 * Pass a reference to a function of this type as the <tt>callback</tt>
 * parameter to the GD_nslookup() function.
 *
 * The callback receives one parameter.
 * @param jsonResponse <tt>char *</tt> containing a JSON string representation
 *                     of the results, or an empty string, or <tt>NULL</tt>. See
 *                     GD_nslookup() for details.
 */
typedef void (*nslookupCompletionCallback)(const char* jsonResponse);

/** Good Dynamics name service lookup completion extended callback.
 * Pass a reference to a function of this type as the <tt>callback</tt>
 * parameter to the GD_nslookupEx() function.
 *
 * The callback receives two parameters.
 * @param jsonResponse <tt>char *</tt> containing a JSON string representation
 *                     of the results, or an empty string, or <tt>NULL</tt>. See
 *                     GD_nslookup() for details.
 *                     
 * @param data <tt>void *</tt> pointer to the extended data that was passed to
 *             the original function call.
 */
typedef void (*nslookupCompletionCallbackEx)(const char* jsonResponse, const void* data);

/** Enumerated constants for use with the Good Dynamics name service.
 * Use these constants to specify the type of results required for a Good
 * Dynamics name service lookup. The type parameter of the GD_nslookup()
 * function always takes one of these values.
 */
typedef enum GD_nslookup_type_t {
    /** Specify a CNAME lookup.
     */
    GD_nslookup_CNAME = 0,

    /** Specify an A record lookup.
     */
    GD_nslookup_ARECORD
} GD_nslookup_type;

#ifdef __cplusplus
extern "C" {
#endif
    
#ifndef GD_C_API
# define GD_C_API
#endif
    
#ifndef GD_C_API_EXT
# define GD_C_API_EXT
#endif
    
    
/** Execute a Good Dynamics name service lookup.
 * 
 * Call this function to execute a Good Dynamics name service lookup. The lookup
 * can be for canonical name (CNAME) or address record (A record).
 *
 * The lookup will be executed from an enterprise endpoint of the Good Dynamics
 * deployment to which the application is connected. The endpoint could be a
 * Good Proxy server located behind the enterprise firewall or in its perimeter
 * network (also known as DMZ, demilitarized zone, and screened subnet).
 * 
 * The lookup is asynchronous. When the lookup completes, a completion callback
 * will be invoked. The callback will be passed a <tt>char*</tt> pointer to
 * memory containing the results represented as a JSON string, if the lookup was
 * successful. If the specified host is not listed for client connection in the
 * enterprise Good Control server, then an empty string is passed to the
 * callback instead. If an error occurred, then <tt>NULL</tt> is passed.
 *
 * @param host <tt>char*</tt> pointer to memory containing the name to look up.
 *
 * @param type <tt>GD_nslookup_type</tt> specifying the type of result required,
 *             either CNAME or A record.
 *
 * @param callback function to execute when the lookup completes. The function
 *                 receives one parameter as described above.
 */
GD_C_API void GD_nslookup(const char* host, GD_nslookup_type type, nslookupCompletionCallback callback);
    
/** Execute a Good Dynamics name service lookup with a callback extension.
 * Call this function to execute a Good Dynamics name service lookup and supply
 * extended data to the results callback. This function does the same lookup as
 * the \ref GD_nslookup() function, see above.
 *
 * The completion callback will receive extended data, which is passed as a
 * parameter to this function.
 * 
 * @param host <tt>char*</tt> pointer to memory containing the name to look up.
 *
 * @param type <tt>GD_nslookup_type</tt> specifying the type of result required,
 *             either CNAME or A record.
 *
 * @param callback function to execute when the lookup completes. The function
 *                 receives a response parameter, as described above under
 *                 \ref GD_nslookup(), and extended data, as passed in the
 *                 <tt>data</tt> parameter, below.
 *
 * @param data <tt>void*</tt> pointer to the extended data for the callback.
 */
GD_C_API void GD_nslookupEx(const char* host, GD_nslookup_type type, nslookupCompletionCallbackEx callback, const void* data);

/** Get a fully qualified domain name for a host server.
 * Call this function to retrieve a fully qualified domain name (FQDN) for a
 * specified host server. An FQDN will be available after a successful socket
 * connection has been made to the server.
 *
 * The host specifier passed to this function must be the same as was used when
 * the socket connection was set up. The returned value will be the FQDN to
 * which the host specifier resolved at set-up time.
 *
 * The returned value, if any, will be a pointer to memory that has been
 * allocated from the heap using <tt>malloc</tt>. The caller must release the
 * memory, by calling <tt>free</tt>.
 * 
 * @param host <tt>char*</tt> pointer to memory containing the specifier for the
 *             server.
 *
 * @return <tt>char*</tt> pointer to allocated memory containing the FQDN, or
 *         <tt>NULL</tt> if an FQDN isn't available.
 */
GD_C_API char* GD_getFqdn(const char* host);
    
#ifdef __cplusplus
}
#endif

/** @}
 */

#endif /* GD_C_NETUTILITY_H */
