/*
 * (c) 2016 BlackBerry Limited. All rights reserved.
 *
 */

#ifndef GD_GSS_API_NEGOTIATESCHEME_H_
#define GD_GSS_API_NEGOTIATESCHEME_H_

#include <stdint.h>


namespace  GD
{

namespace GSS_API
{

/** \defgroup gssstatuscodes Generic Security Service Application Program Interface constants.
 * Use these constants with the Good Dynamics (GD) programming interface for the
 * Generic Security Service Application Program Interface (GSS-API).
 * 
 * \{
 */

/** Generic Security Service Application Program Interface status code.
 * This enumeration represents the status of a GD GSS-API operation. The
 * \link GD.GSS_API.NegotiateScheme.getGssApiStatus getGssApiStatus\endlink
 * function returns one of these values.
 *
 * Some GSS-API status codes are defined by the standard, see <a
 *     HREF="https://tools.ietf.org/html/rfc2743"
 *     target="_blank"
 * >RFC 2743 - Generic Security Service Application Program Interface</a
 * > on the ietf.org website.
 *
 * Codes that aren't defined in the standard have generally accepted meanings
 * that can be found by searching the Internet. For example, the <a
 *     HREF="https://www.gnu.org/software/gss/reference/gss-api.html"
 *     target="_blank"
 * >GSS-API page</a> on the gnu.org website includes definitions in the context
 * of each operation.
 */
enum class GssStatusCode
{
    /* Major status codes. */

    /** GSS-API status code: GSS_S_COMPLETE.
     */
    STATUS_GSS_S_COMPLETE,
    
    /*
     * Calling errors.
     */

    /** GSS-API status code: GSS_S_CALL_INACCESSIBLE_READ.
     */
    STATUS_GSS_S_CALL_INACCESSIBLE_READ,

    /** GSS-API status code: GSS_S_CALL_INACCESSIBLE_WRITE.
     */
    STATUS_GSS_S_CALL_INACCESSIBLE_WRITE,

    /** GSS-API status code: GSS_S_CALL_BAD_STRUCTURE.
     */
    STATUS_GSS_S_CALL_BAD_STRUCTURE,
    
    /*
     * Routine errors.
     */

    /** GSS-API status code: GSS_S_BAD_MECH.
     */
    STATUS_GSS_S_BAD_MECH,
    
    /** GSS-API status code: GSS_S_BAD_NAME.
     */
    STATUS_GSS_S_BAD_NAME,
    
    /** GSS-API status code: GSS_S_BAD_NAMETYPE.
     */
    STATUS_GSS_S_BAD_NAMETYPE,
    

    /** GSS-API status code: GSS_S_BAD_BINDINGS.
     */
    STATUS_GSS_S_BAD_BINDINGS,

    /** GSS-API status code: GSS_S_BAD_STATUS.
     */
    STATUS_GSS_S_BAD_STATUS,

    /** GSS-API status code: GSS_S_BAD_SIG.
     */
    STATUS_GSS_S_BAD_SIG,

    /** GSS-API status code: GSS_S_BAD_MIC.
     */
    STATUS_GSS_S_BAD_MIC,

    /** GSS-API status code: GSS_S_NO_CRED.
     */
    STATUS_GSS_S_NO_CRED,

    /** GSS-API status code: GSS_S_NO_CONTEXT.
     */
    STATUS_GSS_S_NO_CONTEXT,

    /** GSS-API status code: GSS_S_DEFECTIVE_TOKEN.
     */
    STATUS_GSS_S_DEFECTIVE_TOKEN,

    /** GSS-API status code: GSS_S_DEFECTIVE_CREDENTIAL.
     */
    STATUS_GSS_S_DEFECTIVE_CREDENTIAL,

    /** GSS-API status code: GSS_S_CREDENTIALS_EXPIRED.
     */
    STATUS_GSS_S_CREDENTIALS_EXPIRED,

    /** GSS-API status code: GSS_S_CONTEXT_EXPIRED.
     */
    STATUS_GSS_S_CONTEXT_EXPIRED,

    /** GSS-API status code: GSS_S_FAILURE.
     */
    STATUS_GSS_S_FAILURE,

    /** GSS-API status code: GSS_S_BAD_QOP.
     */
    STATUS_GSS_S_BAD_QOP,

    /** GSS-API status code: GSS_S_UNAUTHORIZED.
     */
    STATUS_GSS_S_UNAUTHORIZED,

    /** GSS-API status code: GSS_S_UNAVAILABLE.
     */
    STATUS_GSS_S_UNAVAILABLE,

    /** GSS-API status code: GSS_S_DUPLICATE_ELEMENT.
     */
    STATUS_GSS_S_DUPLICATE_ELEMENT,

    /** GSS-API status code: GSS_S_NAME_NOT_MN.
     */
    STATUS_GSS_S_NAME_NOT_MN,
    
    /*
     * Supplementary status:
     */

    /** GSS-API status code: GSS_S_CONTINUE_NEEDED.
     */
    STATUS_GSS_S_CONTINUE_NEEDED,

    /** GSS-API status code: GSS_S_DUPLICATE_TOKEN.
     */
    STATUS_GSS_S_DUPLICATE_TOKEN,

    /** GSS-API status code: GSS_S_OLD_TOKEN.
     */
    STATUS_GSS_S_OLD_TOKEN,

    /** GSS-API status code: GSS_S_UNSEQ_TOKEN.
     */
    STATUS_GSS_S_UNSEQ_TOKEN,

    /** GSS-API status code: GSS_S_GAP_TOKEN.
     */
    STATUS_GSS_S_GAP_TOKEN,
    
    /** Initial value.
     */
    STATUS_UNKNOWN
};

/**
 * \}
 */

/** Generate SPNEGO header (C++).
 * This C++ class contains an interface for generating a Generic Security
 * Service Application Program Interface (GSS-API) header for the Simple and
 * Protected GSS-API Negotiation Mechanism (SPNEGO). Use of SPNEGO in Good
 * Dynamics (GD) is dependent on use of Kerberos authentication.
 *
 * The GD Runtime stores, in a secure cache, Kerberos tickets obtained in the
 * course of GD secure communication with application servers. These cached
 * tickets can be used to generate SPNEGO headers. Kerberos tickets could be
 * cached as a side effect of using the
 * \reflink GDURLLoadingSystem GDURLLoadingSystem\endlink 
 * or \reflink GDHttpRequest GDHttpRequest\endlink
 * programming interfaces, for example.
 * In addition, there is a programming interface for working with Kerberos
 * tickets directly:
 * \link GD.KRB_API.GDKerberosAuthHandler GDKerberosAuthHandler\endlink.
 *
 * This class provides a low-level interface for GSS token generation. It can
 * be used in GD applications that programmatically form their own HTTP headers
 * for authentication, for example, or that handle other protocol elements at a
 * detailed level.
 *
 * Use of this class is optional. Higher level parts of the GD secure
 * communication stack, for example
 * <tt>GDURLLoad</tt><tt>ingSystem</tt> 
 * and <tt>GDHtt</tt><tt>pRequest</tt>,
 * handle GSS and SPNEGO automatically, without the need for detailed
 * implementation in the application code.
 *
 * @see <a
 *          HREF="https://tools.ietf.org/html/rfc2743" target="_blank"
 *      >RFC 2743 - Generic Security Service Application Program Interface</a>.
 * @see <a
 *          HREF="https://tools.ietf.org/html/rfc4178" target="_blank"
 *      >RFC 4178 - The Simple and Protected Generic Security Service
 *      Application Program Interface (GSS-API) Negotiation Mechanism</a
 *      >.
 * @see <a
 *          HREF="https://tools.ietf.org/html/rfc4559" target="_blank"
 *      >RFC 4559 - SPNEGO-based Kerberos and NTLM HTTP Authentication in
 *      Microsoft Windows</a
 *      >.
 * @see All on the ietf.org website.
 */
class NegotiateScheme /* final */
{
    
public:
    /** Constructor.
     * Constructor.
     */
    NegotiateScheme();
    ~NegotiateScheme();
    
public:
    
    /** Generate an authentication token for a GSS-API header for SPNEGO.
     * Call this function to generate a Generic Security Service (GSS)
     * authentication token that is suitable for use in a GSS-API header for
     * SPNEGO. Pass in the token from a server challenge as a parameter.
     *
     * Token generation depends on there being a suitable Kerberos ticket in the
     * GD secure cache. If there is a suitable cached Kerberos ticket when this
     * function is called, then it is used to generate the token. Otherwise,
     * token generation fails. After failure, the application could take an
     * action that would cause a Kerberos ticket to be cached, for example
     * calling one of the setUpKerberosTicket functions in the
     * \link GD.KRB_API.GDKerberosAuthHandler GDKerberosAuthHandler\endlink
     * class, and then call this function again.
     *
     * This function doesn't return a success or failure code. To discover
     * whether token generation succeeded or failed, call the
     * \ref getGssApiStatus() function every time.
     *
     * It might be necessary to call this function more than once, and to pass
     * different server challenge token values. This could happen if the server
     * requires more than one challenge-response exchange, for example. When
     * getGssApiStatus() returns <tt>STATUS_GSS_S_COMPLETE</tt> then negotiation
     * is complete.
     *
     * Pass as a paramater a specifier for the authentication host to be used
     * for the negotiation. Format the value as follows:\n
     * <em><tt>server.address.com</tt></em>:<em><tt>portNumber</tt></em>\n
     * Where:
     * - <em><tt>server.address.com</tt></em> is a fully qualified domain name
     *   (FQDN).
     * - <em><tt>portNumber</tt></em> can be omitted if it is 80. If the port
     *   number is omitted, also omit the colon (:) separator.
     * .
     * 
     * @param token <tt>char*</tt> pointer to memory containing the
     *              Base64-encoded initial token from the server challenge, and
     *              a null terminator.
     *
     * @param hostname <tt>char*</tt> pointer to memory containing the
     *                 authentication host specifier, and a null terminator.
     *
     * @param allow_delegation <tt>bool</tt> flag for whether to allow Kerberos
     *                         delegation to be used to obtain the token. Note
     *                         that delegation might not be allowed by the
     *                         authentication service, which would take
     *                         precedence over this parameter value.
     *
     * @return <tt>char*</tt> pointer to memory containing a Base64-encoded
     *         token for a GSS-API header for SPNEGO, and a null terminator.\n
     *         The returned value, if non-null, will be a pointer to memory that
     *         has been allocated from the heap. The caller of this function
     *         must release the memory.
     */
    char* generateGssApiData(const char* token, const char* hostname, const bool allow_delegation);
    
    /** Get the status of the last GSS-API operation.
     * Call this function to get the status of the last GSS-API operation,
     * specifically to determine the success or failure of the last call to the
     * \ref generateGssApiData() function.
     *
     * The <tt>STATUS_UNKNOWN</tt> value is returned if there is no current
     * context, for example if token generation hasn't been attempted yet.
     *
     * @return <tt>GssStatusCode</tt> value representing the status.
     */
    GssStatusCode getGssApiStatus() const;
    
    /** Check whether GSS security context establishment has been initiated.
     * Call this function to check whether establishment of a GSS security
     * context has been initiated.
     *
     * This function doesn't necessarily return <tt>false</tt> if security
     * context establishment has completed.
     * 
     * @return <tt>true</tt> if GSS context establishment has been initiated.
     * @return <tt>false</tt> otherwise.
     */
    bool gssContextEstablishmentInitiated() const;

    
private:
    void* _impl;
};


} // end of namespace GSS_API
    
} // end of namespace GD

#endif /* GDNEGOTIATESCHEME_H_ */
