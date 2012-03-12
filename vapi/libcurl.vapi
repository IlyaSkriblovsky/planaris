[CCode(cheader_filename = "curl/curl.h")]
namespace Curl
{
    namespace Global
    {
        [CCode(cprefix = "CURL_GLOBAL_")]
        public enum Flags
        {
            NOTHING = 0,
            SSL     = 1,
            WIN32   = 2,
            ALL     = 3,
            DEFAULT = 3
        }

        public void init(Flags flags);
    }


    [Compact]
    [CCode(cname = "CURL", free_function = "curl_easy_cleanup")]
    public class Easy
    {
        [CCode(cname = "curl_easy_init")]
        public Easy();

        public Code setopt(Opt opt, void *value);

        [CCode(sentinel = "")]
        public Code getinfo(Info info, ...);

        public Code perform();
    }


    [CCode(cname = "struct curl_httppost")]
    public struct HttpPost
    {
        [CCode(cname = "curl_formadd", sentinel = "CURLFORM_END")]
        public static FormCode formadd(HttpPost **first, HttpPost **last, ...);

        [CCode(cname = "curl_formfree")]
        public static void formfree(HttpPost *first);
    }


    [CCode(cname = "CURLcode", cprefix = "CURLE_")]
    public enum Code
    {
        OK = 0,
        UNSUPPORTED_PROTOCOL,    /* 1 */
        FAILED_INIT,             /* 2 */
        URL_MALFORMAT,           /* 3 */
        OBSOLETE4,               /* 4 - NOT USED */
        COULDNT_RESOLVE_PROXY,   /* 5 */
        COULDNT_RESOLVE_HOST,    /* 6 */
        COULDNT_CONNECT,         /* 7 */
        FTP_WEIRD_SERVER_REPLY,  /* 8 */
        REMOTE_ACCESS_DENIED,    /* 9 a service was denied by the server
                                  due to lack of access - when login fails
                                  this is not returned. */
        OBSOLETE10,              /* 10 - NOT USED */
        FTP_WEIRD_PASS_REPLY,    /* 11 */
        OBSOLETE12,              /* 12 - NOT USED */
        FTP_WEIRD_PASV_REPLY,    /* 13 */
        FTP_WEIRD_227_FORMAT,    /* 14 */
        FTP_CANT_GET_HOST,       /* 15 */
        OBSOLETE16,              /* 16 - NOT USED */
        FTP_COULDNT_SET_TYPE,    /* 17 */
        PARTIAL_FILE,            /* 18 */
        FTP_COULDNT_RETR_FILE,   /* 19 */
        OBSOLETE20,              /* 20 - NOT USED */
        QUOTE_ERROR,             /* 21 - quote command failure */
        HTTP_RETURNED_ERROR,     /* 22 */
        WRITE_ERROR,             /* 23 */
        OBSOLETE24,              /* 24 - NOT USED */
        UPLOAD_FAILED,           /* 25 - failed upload "command" */
        READ_ERROR,              /* 26 - couldn't open/read from file */
        OUT_OF_MEMORY,           /* 27 */
        /* Note: CURLE_OUT_OF_MEMORY may sometimes indicate a conversion error
               instead of a memory allocation error if CURL_DOES_CONVERSIONS
               is defined
        */
        OPERATION_TIMEDOUT,      /* 28 - the timeout time was reached */
        OBSOLETE29,              /* 29 - NOT USED */
        FTP_PORT_FAILED,         /* 30 - FTP PORT operation failed */
        FTP_COULDNT_USE_REST,    /* 31 - the REST command failed */
        OBSOLETE32,              /* 32 - NOT USED */
        RANGE_ERROR,             /* 33 - RANGE "command" didn't work */
        HTTP_POST_ERROR,         /* 34 */
        SSL_CONNECT_ERROR,       /* 35 - wrong when connecting with SSL */
        BAD_DOWNLOAD_RESUME,     /* 36 - couldn't resume download */
        FILE_COULDNT_READ_FILE,  /* 37 */
        LDAP_CANNOT_BIND,        /* 38 */
        LDAP_SEARCH_FAILED,      /* 39 */
        OBSOLETE40,              /* 40 - NOT USED */
        FUNCTION_NOT_FOUND,      /* 41 */
        ABORTED_BY_CALLBACK,     /* 42 */
        BAD_FUNCTION_ARGUMENT,   /* 43 */
        OBSOLETE44,              /* 44 - NOT USED */
        INTERFACE_FAILED,        /* 45 - CURLOPT_INTERFACE failed */
        OBSOLETE46,              /* 46 - NOT USED */
        TOO_MANY_REDIRECTS ,     /* 47 - catch endless re-direct loops */
        UNKNOWN_TELNET_OPTION,   /* 48 - User specified an unknown option */
        TELNET_OPTION_SYNTAX ,   /* 49 - Malformed telnet option */
        OBSOLETE50,              /* 50 - NOT USED */
        PEER_FAILED_VERIFICATION, /* 51 - peer's certificate or fingerprint
                                   wasn't verified fine */
        GOT_NOTHING,             /* 52 - when this is a specific error */
        SSL_ENGINE_NOTFOUND,     /* 53 - SSL crypto engine not found */
        SSL_ENGINE_SETFAILED,    /* 54 - can not set SSL crypto engine as
                                  default */
        SEND_ERROR,              /* 55 - failed sending network data */
        RECV_ERROR,              /* 56 - failure in receiving network data */
        OBSOLETE57,              /* 57 - NOT IN USE */
        SSL_CERTPROBLEM,         /* 58 - problem with the local certificate */
        SSL_CIPHER,              /* 59 - couldn't use specified cipher */
        SSL_CACERT,              /* 60 - problem with the CA cert (path?) */
        BAD_CONTENT_ENCODING,    /* 61 - Unrecognized transfer encoding */
        LDAP_INVALID_URL,        /* 62 - Invalid LDAP URL */
        FILESIZE_EXCEEDED,       /* 63 - Maximum file size exceeded */
        USE_SSL_FAILED,          /* 64 - Requested FTP SSL level failed */
        SEND_FAIL_REWIND,        /* 65 - Sending the data requires a rewind
                                  that failed */
        SSL_ENGINE_INITFAILED,   /* 66 - failed to initialise ENGINE */
        LOGIN_DENIED,            /* 67 - user, password or similar was not
                                  accepted and we failed to login */
        TFTP_NOTFOUND,           /* 68 - file not found on server */
        TFTP_PERM,               /* 69 - permission problem on server */
        REMOTE_DISK_FULL,        /* 70 - out of disk space on server */
        TFTP_ILLEGAL,            /* 71 - Illegal TFTP operation */
        TFTP_UNKNOWNID,          /* 72 - Unknown transfer ID */
        REMOTE_FILE_EXISTS,      /* 73 - File already exists */
        TFTP_NOSUCHUSER,         /* 74 - No such user */
        CONV_FAILED,             /* 75 - conversion failed */
        CONV_REQD,               /* 76 - caller must register conversion
                                  callbacks using curl_easy_setopt options
                                  CURLOPT_CONV_FROM_NETWORK_FUNCTION,
                                  CURLOPT_CONV_TO_NETWORK_FUNCTION, and
                                  CURLOPT_CONV_FROM_UTF8_FUNCTION */
        SSL_CACERT_BADFILE,      /* 77 - could not load CACERT file, missing
                                  or wrong format */
        REMOTE_FILE_NOT_FOUND,   /* 78 - remote file not found */
        SSH,                     /* 79 - error from the SSH layer, somewhat
                                  generic so the error message will be of
                                  interest when this has happened */

        SSL_SHUTDOWN_FAILED,     /* 80 - Failed to shut down the SSL
                                  connection */
        AGAIN,                   /* 81 - socket is not ready for send/recv,
                                  wait till it's ready and try again (Added
                                  in 7.18.2) */
        SSL_CRL_BADFILE,         /* 82 - could not load CRL file, missing or
                                  wrong format (Added in 7.19.0) */
        SSL_ISSUER_ERROR,        /* 83 - Issuer check failed.  (Added in
                                  7.19.0) */
        FTP_PRET_FAILED,         /* 84 - a PRET command failed */
        RTSP_CSEQ_ERROR,         /* 85 - mismatch of RTSP CSeq numbers */
        RTSP_SESSION_ERROR,      /* 86 - mismatch of RTSP Session Identifiers */
        FTP_BAD_FILE_LIST,       /* 87 - unable to parse FTP file list */
        CHUNK_FAILED,            /* 88 - chunk callback reported error */

        LAST /* never use! */
    }



    [CCode(cname = "CURLFORMcode", cprefix = "CURL_FORMADD_")]
    public enum FormCode
    {
        OK, /* first, no error */

        MEMORY,
        OPTION_TWICE,
        NULL,
        UNKNOWN_OPTION,
        INCOMPLETE,
        ILLEGAL_ARRAY,
        DISABLED, /* libcurl was built with this disabled */

        LAST /* last */
    }


    [CCode(cname = "CURLopt", cprefix = "CURLOPT_")]
    public enum Opt
    {
        FILE,
        WRITEDATA,
        URL,
        PORT,
        PROXY,
        USERPWD,
        PROXYUSERPWD,
        RANGE,
        INFILE,
        READDATA,
        ERRORBUFFER,
        WRITEFUNCTION,
        READFUNCTION,
        TIMEOUT,
        INFILESIZE,
        POSTFIELDS,
        REFERER,
        FTPPORT,
        USERAGENT,
        LOW_SPEED_LIMIT,
        LOW_SPEED_TIME,
        RESUME_FROM,
        COOKIE,
        HTTPHEADER,
        RTSPHEADER,
        HTTPPOST,
        SSLCERT,
        KEYPASSWD,
        CRLF,
        QUOTE,
        WRITEHEADER,
        HEADERDATA,
        COOKIEFILE,
        SSLVERSION,
        TIMECONDITION,
        TIMEVALUE,
        CUSTOMREQUEST,
        STDERR,
        POSTQUOTE,
        WRITEINFO,
        VERBOSE,
        HEADER,
        NOPROGRESS,
        NOBODY,
        FAILONERROR,
        UPLOAD,
        POST,
        DIRLISTONLY,
        APPEND,
        NETRC,
        FOLLOWLOCATION,
        TRANSFERTEXT,
        PUT,
        PROGRESSFUNCTION,
        PROGRESSDATA,
        AUTOREFERER,
        PROXYPORT,
        POSTFIELDSIZE,
        HTTPPROXYTUNNEL,
        INTERFACE,
        KRBLEVEL,
        SSL_VERIFYPEER,
        CAINFO,
        MAXREDIRS,
        FILETIME,
        TELNETOPTIONS,
        MAXCONNECTS,
        CLOSEPOLICY,
        FRESH_CONNECT,
        FORBID_REUSE,
        RANDOM_FILE,
        EGDSOCKET,
        CONNECTTIMEOUT,
        HEADERFUNCTION,
        HTTPGET,
        SSL_VERIFYHOST,
        COOKIEJAR,
        SSL_CIPHER_LIST,
        HTTP_VERSION,
        FTP_USE_EPSV,
        SSLCERTTYPE,
        SSLKEY,
        SSLKEYTYPE,
        SSLENGINE,
        SSLENGINE_DEFAULT,
        DNS_USE_GLOBAL_CACHE,
        DNS_CACHE_TIMEOUT,
        PREQUOTE,
        DEBUGFUNCTION,
        DEBUGDATA,
        COOKIESESSION,
        CAPATH,
        BUFFERSIZE,
        NOSIGNAL,
        SHARE,
        PROXYTYPE,
        ENCODING,
        PRIVATE,
        HTTP200ALIASES,
        UNRESTRICTED_AUTH,
        FTP_USE_EPRT,
        HTTPAUTH,
        SSL_CTX_FUNCTION,
        SSL_CTX_DATA,
        FTP_CREATE_MISSING_DIRS,
        PROXYAUTH,
        FTP_RESPONSE_TIMEOUT,
        SERVER_RESPONSE_TIMEOUT,
        IPRESOLVE,
        MAXFILESIZE,
        INFILESIZE_LARGE,
        RESUME_FROM_LARGE,
        MAXFILESIZE_LARGE,
        NETRC_FILE,
        USE_SSL,
        POSTFIELDSIZE_LARGE,
        TCP_NODELAY,
        FTPSSLAUTH,
        IOCTLFUNCTION,
        IOCTLDATA,
        FTP_ACCOUNT,
        COOKIELIST,
        IGNORE_CONTENT_LENGTH,
        FTP_SKIP_PASV_IP,
        FTP_FILEMETHOD,
        LOCALPORT,
        LOCALPORTRANGE,
        CONNECT_ONLY,
        CONV_FROM_NETWORK_FUNCTION,
        CONV_TO_NETWORK_FUNCTION,
        CONV_FROM_UTF8_FUNCTION,
        MAX_SEND_SPEED_LARGE,
        MAX_RECV_SPEED_LARGE,
        FTP_ALTERNATIVE_TO_USER,
        SOCKOPTFUNCTION,
        SOCKOPTDATA,
        SSL_SESSIONID_CACHE,
        SSH_AUTH_TYPES,
        SSH_PUBLIC_KEYFILE,
        SSH_PRIVATE_KEYFILE,
        FTP_SSL_CCC,
        TIMEOUT_MS,
        CONNECTTIMEOUT_MS,
        HTTP_TRANSFER_DECODING,
        HTTP_CONTENT_DECODING,
        NEW_FILE_PERMS,
        NEW_DIRECTORY_PERMS,
        POSTREDIR,
        SSH_HOST_PUBLIC_KEY_MD5,
        OPENSOCKETFUNCTION,
        OPENSOCKETDATA,
        COPYPOSTFIELDS,
        PROXY_TRANSFER_MODE,
        SEEKFUNCTION,
        SEEKDATA,
        CRLFILE,
        ISSUERCERT,
        ADDRESS_SCOPE,
        CERTINFO,
        USERNAME,
        PASSWORD,
        PROXYUSERNAME,
        PROXYPASSWORD,
        NOPROXY,
        TFTP_BLKSIZE,
        SOCKS5_GSSAPI_SERVICE,
        SOCKS5_GSSAPI_NEC,
        PROTOCOLS,
        REDIR_PROTOCOLS,
        SSH_KNOWNHOSTS,
        SSH_KEYFUNCTION,
        SSH_KEYDATA,
        MAIL_FROM,
        MAIL_RCPT,
        FTP_USE_PRET,
        RTSP_REQUEST,
        RTSP_SESSION_ID,
        RTSP_STREAM_URI,
        RTSP_TRANSPORT,
        RTSP_CLIENT_CSEQ,
        RTSP_SERVER_CSEQ,
        INTERLEAVEDATA,
        INTERLEAVEFUNCTION,
        WILDCARDMATCH,
        CHUNK_BGN_FUNCTION,
        CHUNK_END_FUNCTION,
        FNMATCH_FUNCTION,
        CHUNK_DATA,
        FNMATCH_DATA,
        LASTENTRY /* the last unused */
    }


    [CCode(cname = "CURLformoption", cprefix = "CURLFORM_")]
    public enum FormOption
    {
        NOTHING,

        COPYNAME,
        PTRNAME,
        NAMELENGTH,
        COPYCONTENTS,
        PTRCONTENTS,
        CONTENTSLENGTH,
        FILECONTENT,
        ARRAY,
        OBSOLETE,
        FILE,

        BUFFER,
        BUFFERPTR,
        BUFFERLENGTH,

        CONTENTTYPE,
        CONTENTHEADER,
        FILENAME,
        END,
        OBSOLETE2,

        STREAM,

        LASTENTRY /* the last unused */
    }


    [CCode(cname = "CURLINFO", cprefix = "CURLINFO_")]
    public enum Info
    {
        EFFECTIVE_URL,
        RESPONSE_CODE,
        TOTAL_TIME,
        NAMELOOKUP_TIME,
        CONNECT_TIME,
        PRETRANSFER_TIME,
        SIZE_UPLOAD,
        SIZE_DOWNLOAD,
        SPEED_DOWNLOAD,
        SPEED_UPLOAD,
        HEADER_SIZE,
        REQUEST_SIZE,
        SSL_VERIFYRESULT,
        FILETIME,
        CONTENT_LENGTH_DOWNLOAD,
        CONTENT_LENGTH_UPLOAD,
        STARTTRANSFER_TIME,
        CONTENT_TYPE,
        REDIRECT_TIME,
        REDIRECT_COUNT,
        PRIVATE,
        HTTP_CONNECTCODE,
        HTTPAUTH_AVAIL,
        PROXYAUTH_AVAIL,
        OS_ERRNO,
        NUM_CONNECTS,
        SSL_ENGINES,
        COOKIELIST,
        LASTSOCKET,
        FTP_ENTRY_PATH,
        REDIRECT_URL,
        PRIMARY_IP,
        APPCONNECT_TIME,
        CERTINFO,
        CONDITION_UNMET,
        RTSP_SESSION_ID,
        RTSP_CLIENT_CSEQ,
        RTSP_SERVER_CSEQ,
        RTSP_CSEQ_RECV,
        PRIMARY_PORT,
        LOCAL_IP,
        LOCAL_PORT
    }
}
