/*
 * (c) 2016 BlackBerry Limited. All rights reserved.
 *
 */

#ifndef GD_KRB_API_GDKERBEROSAUTHHANDLER_H_
#define GD_KRB_API_GDKERBEROSAUTHHANDLER_H_

#include <stdint.h>


namespace GD
{

namespace KRB_API
{
    
enum class Krb5ErrorCode : int32_t; // see definitions further.

/** Manage the Good Dynamics cache of Kerberos credentials (C++).
 * The GD Runtime stores, in a secure cache, Kerberos tickets obtained in the
 * course of GD secure communication with application servers. This C++ class
 * contains a number of functions for managing the cache, which also includes
 * ticket request parameters and configuration.
 */
class GDKerberosAuthHandler  /* final */
{
    
public:
    /** Constructor.
     * Constructor.
     */
    GDKerberosAuthHandler();
    ~GDKerberosAuthHandler();
    
public:

    /** Check whether Kerberos authentication delegation is allowed or
     *  disallowed.
     * Call this function to check whether Kerberos authentication delegation is
     * allowed or disallowed, within Good Dynamics secure communication.
     *
     * Kerberos authentication delegation can be allowed and disallowed by
     * calling the \link GDKerberosAuthHandler::setAllowDelegation
     * setAllowDelegation\endlink function, below.
     *
     * @return <tt>true</tt> if Kerberos delegation is allowed within Good
     *                       Dynamics secure communication.
     * @return <tt>false</tt> otherwise
     */
    static bool getAllowDelegation();
    
    /** Allow or disallow Kerberos authentication delegation.
     * Call this function to allow or disallow Kerberos delegation within
 * Good Dynamics secure communications. By default, Kerberos delegation is not
 * allowed.
 *
 * When Kerberos delegation is allowed, the Good Dynamics Runtime behaves as
 * follows:
 * - Kerberos requests will be for tickets that can be delegated.
 * - Application servers that are trusted for delegation can be sent tickets
 *   that can be delegated, if such tickets were issued.
 * .
 *
 * When Kerberos delegation is not allowed, the Good Dynamics Runtime behaves as
 * follows:
 * - Kerberos requests will not be for tickets that can be delegated.
 * - No application server will be sent tickets that can be delegated, even if
 *   such tickets were issued.
 * .
 *
 * After this function has been called, delegation will remain allowed or
 * disallowed until this function is called again with a different setting.
 *
 * Note: User and service configuration in the Kerberos Domain Controller
 * (typically a Microsoft Active Directory server) is required in order for
 * delegation to be successful. On its own, calling this function will not
 * make Kerberos delegation work in the whole end-to-end application.
     *
     * When this function is called, the Kerberos ticket and credentials caches
     * will be cleared. I.e. there is an effective call to the
     * <tt>clearCache</tt> function, below.
     *
     * @param allow <tt>bool</tt> for the setting: <tt>true</tt> to allow
     *              delegation, <tt>false</tt> to disallow.
     */
    static void setAllowDelegation(bool allow);
    
    /** Clear cached Kerberos authentication credentials and tickets.
     * Call this function to clear the cached Kerberos authentication
     * credentials and tickets. The session cache and permanent cache will both
     * be cleared.
     */
    static void clearCache();
    
    /** Get a Kerberos ticket with a user name and password.
     * Call this function to create an initial Kerberos ticket for
     * authentication. This will be a Ticket-to-Get-Tickets (TGT), for a
     * specified user principal. The ticket will be stored in the Good Dynamics
     * secure cache, if created.
     *
     * Good Dynamics secure communication supports Kerberos authentication of
     * only one active user principal at a time.
     *
     * The user principal name must be in the
     * <em>user</em><tt>\@</tt><em>realm</em> long form. The short form
     * <em>shortrealm</em><tt>\\</tt><em>user</em> is not supported.
     * 
     * @param username <tt>char*</tt> pointer to memory containing the user
     *                 principal name, and a null terminator.
     * 
     * @param password <tt>char*</tt> pointer to memory containing the Kerberos
     *                 authentication password for the user principal, and a
     *                 null terminator.
     *
     * @return <tt>KDC_ERR_NONE</tt> if ticket creation succeeded, or a
     *         different <tt>Krb5ErrorCode</tt> value representing the reason
     *         for failure.
     */
    Krb5ErrorCode setUpKerberosTicket(const char* username, const char* password);
    
    /** Get a Kerberos ticket via delegation, with implicit credentials.
     * Call this function to create a Kerberos ticket for authentication. This
     * will be a service ticket obtained by Kerberos Constrained Delegation
     * (KCD) to a specified authentication host, with implicit credentials.
     *
     * Specify the authentication service address by its fully qualified domain
     * name (FQDN) and port number.
     *
     * Check that implicit credentials are allowed, by calling the
     * \ref implicitCredentialsAllowed() function, before calling this function.
     *
     * @param host <tt>char*</tt> pointer to memory containing the FQDN of the
     *             authentication server, and a null terminator.
     *
     * @param port <tt>int</tt> for the port number of the authentication
     *             service.
     *
     * @return <tt>KDC_ERR_NONE</tt> if ticket creation succeeded, or a
     *         different <tt>Krb5ErrorCode</tt> value representing the reason
     *         for failure.
     */
    Krb5ErrorCode setUpKerberosTicket(const char* host, int port);
    
    /** Whether implicit credentials are allowed.
     * Call this function to check whether implicit credentials are allowed.
     *
     * If implicit credentials are allowed, then the
     * \ref setUpKerberosTicket(const char* host, int port) variant can be used.
     * In that variant, a ticket is obtained by Kerberos Constrained Delegation
     * (KCD). Otherwise, only the 
     * \ref setUpKerberosTicket(const char* username, const char* password)
     * variant can be used.
     * 
     * @return <tt>true</tt> if implicit credentials are allowed.
     * @return <tt>false</tt> otherwise.
     */
    bool implicitCredentialsAllowed();
    
private:
    void *authKerberos;
};

/** \defgroup kerberoscodes Kerberos constants.
 * Use these constants with the Good Dynamics (GD) programming interface for
 * Kerberos authentication.
 * 
 * \{
 */

/** Kerberos 5 error codes.
 * This enumeration represents the status of a GD Kerberos operation. The
 * <tt>setUpKerberosTicket</tt> functions in the
 * \link GD.KRB_API.GDKerberosAuthHandler GDKerberosAuthHandler\endlink
 * class return one of these values.
 * 
 * \see <A
 *     HREF="http://web.mit.edu/kerberos/krb5-1.5/krb5-1.5.4/doc/krb5-admin/Kerberos-V5-Library-Error-Codes.html"
 *     target="_blank"
 * >Kerberos V5 Library Error Codes</A> on the mit.edu website.
 */
enum class Krb5ErrorCode
{
    KDC_ERR_NONE = -1765328384,
    KDC_ERR_NAME_EXP = -1765328383,
    KDC_ERR_SERVICE_EXP = -1765328382,
    KDC_ERR_BAD_PVNO = -1765328381,
    KDC_ERR_C_OLD_MAST_KVNO = -1765328380,
    KDC_ERR_S_OLD_MAST_KVNO = -1765328379,
    KDC_ERR_C_PRINCIPAL_UNKNOWN = -1765328378,
    KDC_ERR_S_PRINCIPAL_UNKNOWN = -1765328377,
    KDC_ERR_PRINCIPAL_NOT_UNIQUE = -1765328376,
    KDC_ERR_NULL_KEY = -1765328375,
    KDC_ERR_CANNOT_POSTDATE = -1765328374,
    KDC_ERR_NEVER_VALID = -1765328373,
    KDC_ERR_POLICY = -1765328372,
    KDC_ERR_BADOPTION = -1765328371,
    KDC_ERR_ETYPE_NOSUPP = -1765328370,
    KDC_ERR_SUMTYPE_NOSUPP = -1765328369,
    KDC_ERR_PADATA_TYPE_NOSUPP = -1765328368,
    KDC_ERR_TRTYPE_NOSUPP = -1765328367,
    KDC_ERR_CLIENT_REVOKED = -1765328366,
    KDC_ERR_SERVICE_REVOKED = -1765328365,
    KDC_ERR_TGT_REVOKED = -1765328364,
    KDC_ERR_CLIENT_NOTYET = -1765328363,
    KDC_ERR_SERVICE_NOTYET = -1765328362,
    KDC_ERR_KEY_EXPIRED = -1765328361,
    KDC_ERR_PREAUTH_FAILED = -1765328360,
    KDC_ERR_PREAUTH_REQUIRED = -1765328359,
    KDC_ERR_SERVER_NOMATCH = -1765328358,
    KDC_ERR_KDC_ERR_MUST_USE_USER2USER = -1765328357,
    KDC_ERR_PATH_NOT_ACCEPTED = -1765328356,
    KDC_ERR_SVC_UNAVAILABLE = -1765328355,
    KRB_AP_ERR_BAD_INTEGRITY = -1765328353,
    KRB_AP_ERR_TKT_EXPIRED = -1765328352,
    KRB_AP_ERR_TKT_NYV = -1765328351,
    KRB_AP_ERR_REPEAT = -1765328350,
    KRB_AP_ERR_NOT_US = -1765328349,
    KRB_AP_ERR_BADMATCH = -1765328348,
    KRB_AP_ERR_SKEW = -1765328347,
    KRB_AP_ERR_BADADDR = -1765328346,
    KRB_AP_ERR_BADVERSION = -1765328345,
    KRB_AP_ERR_MSG_TYPE = -1765328344,
    KRB_AP_ERR_MODIFIED = -1765328343,
    KRB_AP_ERR_BADORDER = -1765328342,
    KRB_AP_ERR_ILL_CR_TKT = -1765328341,
    KRB_AP_ERR_BADKEYVER = -1765328340,
    KRB_AP_ERR_NOKEY = -1765328339,
    KRB_AP_ERR_MUT_FAIL = -1765328338,
    KRB_AP_ERR_BADDIRECTION = -1765328337,
    KRB_AP_ERR_METHOD = -1765328336,
    KRB_AP_ERR_BADSEQ = -1765328335,
    KRB_AP_ERR_INAPP_CKSUM = -1765328334,
    KRB_AP_PATH_NOT_ACCEPTED = -1765328333,
    KRB_ERR_RESPONSE_TOO_BIG = -1765328332,
    KRB_ERR_GENERIC = -1765328324,
    KRB_ERR_FIELD_TOOLONG = -1765328323,
    KDC_ERR_CLIENT_NOT_TRUSTED = -1765328322,
    KDC_ERR_KDC_NOT_TRUSTED = -1765328321,
    KDC_ERR_INVALID_SIG = -1765328320,
    KDC_ERR_DH_KEY_PARAMETERS_NOT_ACCEPTED = -1765328319,
    KDC_ERR_WRONG_REALM = -1765328316,
    AP_ERR_USER_TO_USER_REQUIRED = -1765328315,
    KDC_ERR_CANT_VERIFY_CERTIFICATE = -1765328314,
    KDC_ERR_INVALID_CERTIFICATE = -1765328313,
    KDC_ERR_REVOKED_CERTIFICATE = -1765328312,
    KDC_ERR_REVOCATION_STATUS_UNKNOWN = -1765328311,
    KDC_ERR_REVOCATION_STATUS_UNAVAILABLE = -1765328310,
    KDC_ERR_CLIENT_NAME_MISMATCH = -1765328309,
    KDC_ERR_INCONSISTENT_KEY_PURPOSE = -1765328308,
    KDC_ERR_DIGEST_IN_CERT_NOT_ACCEPTED = -1765328307,
    KDC_ERR_PA_CHECKSUM_MUST_BE_INCLUDED = -1765328306,
    KDC_ERR_DIGEST_IN_SIGNED_DATA_NOT_ACCEPTED = -1765328305,
    KDC_ERR_PUBLIC_KEY_ENCRYPTION_NOT_SUPPORTED = -1765328304,
    KDC_ERR_INVALID_HASH_ALG = -1765328290,
    KDC_ERR_INVALID_ITERATION_COUNT = -1765328289,
    ERR_RCSID = -1765328256,
    LIBOS_BADLOCKFLAG = -1765328255,
    LIBOS_CANTREADPWD = -1765328254,
    LIBOS_BADPWDMATCH = -1765328253,
    LIBOS_PWDINTR = -1765328252,
    PARSE_ILLCHAR = -1765328251,
    PARSE_MALFORMED = -1765328250,
    CONFIG_CANTOPEN = -1765328249,
    CONFIG_BADFORMAT = -1765328248,
    CONFIG_NOTENUFSPACE = -1765328247,
    BADMSGTYPE = -1765328246,
    CC_BADNAME = -1765328245,
    CC_UNKNOWN_TYPE = -1765328244,
    CC_NOTFOUND = -1765328243,
    CC_END = -1765328242,
    NO_TKT_SUPPLIED = -1765328241,
    KRB5KRB_AP_WRONG_PRINC = -1765328240,
    KRB5KRB_AP_ERR_TKT_INVALID = -1765328239,
    PRINC_NOMATCH = -1765328238,
    KDCREP_MODIFIED = -1765328237,
    KDCREP_SKEW = -1765328236,
    IN_TKT_REALM_MISMATCH = -1765328235,
    PROG_ETYPE_NOSUPP = -1765328234,
    PROG_KEYTYPE_NOSUPP = -1765328233,
    WRONG_ETYPE = -1765328232,
    PROG_SUMTYPE_NOSUPP = -1765328231,
    REALM_UNKNOWN = -1765328230,
    SERVICE_UNKNOWN = -1765328229,
    KDC_UNREACH = -1765328228,
    NO_LOCALNAME = -1765328227,
    MUTUAL_FAILED = -1765328226,
    RC_TYPE_EXISTS = -1765328225,
    RC_MALLOC = -1765328224,
    RC_TYPE_NOTFOUND = -1765328223,
    RC_UNKNOWN = -1765328222,
    RC_REPLAY = -1765328221,
    RC_IO = -1765328220,
    RC_NOIO = -1765328219,
    RC_PARSE = -1765328218,
    RC_IO_EOF = -1765328217,
    RC_IO_MALLOC = -1765328216,
    RC_IO_PERM = -1765328215,
    RC_IO_IO = -1765328214,
    RC_IO_UNKNOWN = -1765328213,
    RC_IO_SPACE = -1765328212,
    TRANS_CANTOPEN = -1765328211,
    TRANS_BADFORMAT = -1765328210,
    LNAME_CANTOPEN = -1765328209,
    LNAME_NOTRANS = -1765328208,
    LNAME_BADFORMAT = -1765328207,
    CRYPTO_INTERNAL = -1765328206,
    KT_BADNAME = -1765328205,
    KT_UNKNOWN_TYPE = -1765328204,
    KT_NOTFOUND = -1765328203,
    KT_END = -1765328202,
    KT_NOWRITE = -1765328201,
    KT_IOERR = -1765328200,
    NO_TKT_IN_RLM = -1765328199,
    DES_BAD_KEYPAR = -1765328198,
    DES_WEAK_KEY = -1765328197,
    BAD_ENCTYPE = -1765328196,
    BAD_KEYSIZE = -1765328195,
    BAD_MSIZE = -1765328194,
    CC_TYPE_EXISTS = -1765328193,
    KT_TYPE_EXISTS = -1765328192,
    CC_IO = -1765328191,
    FCC_PERM = -1765328190,
    FCC_NOFILE = -1765328189,
    FCC_INTERNAL = -1765328188,
    CC_WRITE = -1765328187,
    CC_NOMEM = -1765328186,
    CC_FORMAT = -1765328185,
    CC_NOT_KTYPE = -1765328184,
    INVALID_FLAGS = -1765328183,
    NO_2ND_TKT = -1765328182,
    NOCREDS_SUPPLIED = -1765328181,
    SENDAUTH_BADAUTHVERS = -1765328180,
    SENDAUTH_BADAPPLVERS = -1765328179,
    SENDAUTH_BADRESPONSE = -1765328178,
    SENDAUTH_REJECTED = -1765328177,
    PREAUTH_BAD_TYPE = -1765328176,
    PREAUTH_NO_KEY = -1765328175,
    PREAUTH_FAILED = -1765328174,
    RCACHE_BADVNO = -1765328173,
    CCACHE_BADVNO = -1765328172,
    KEYTAB_BADVNO = -1765328171,
    PROG_ATYPE_NOSUPP = -1765328170,
    RC_REQUIRED = -1765328169,
    ERR_BAD_HOSTNAME = -1765328168,
    ERR_HOST_REALM_UNKNOWN = -1765328167,
    SNAME_UNSUPP_NAMETYPE = -1765328166,
    KRB_AP_ERR_V4_REPLY = -1765328165,
    REALM_CANT_RESOLVE = -1765328164,
    TKT_NOT_FORWARDABLE = -1765328163,
    FWD_BAD_PRINCIPAL = -1765328162,
    GET_IN_TKT_LOOP = -1765328161,
    CONFIG_NODEFREALM = -1765328160,
    SAM_UNSUPPORTED = -1765328159,
    SAM_INVALID_ETYPE = -1765328158,
    SAM_NO_CHECKSUM = -1765328157,
    SAM_BAD_CHECKSUM = -1765328156,
    OBSOLETE_FN = -1765328146,
    ERR_BAD_S2K_PARAMS = -1765328139,
    ERR_NO_SERVICE = -1765328138,
    CC_NOSUPP = -1765328137,
    DELTAT_BADFORMAT = -1765328136,
    PLUGIN_NO_HANDLE = -1765328135,
    PLUGIN_OP_NOTSUPP = -1765328134
};

/**
 * \}
 */

} // namespace KRB_API

} // namespace GD

#endif /* GDKERBEROSAUTHHANDLER_H_ */
