# Declarations for the IDAM C library

#cdef extern from "idamclientserver.h":
#     ctypedef struct DATA_BLOCK:
#        pass

cdef extern from "idamclient.h":
    # Getting and setting properties
    void setIdamProperty(const char *property)
    bint getIdamProperty(const char *property) # return boolean as integer
    void resetIdamProperty(const char *property)
    void resetIdamProperties()
    
    # Set server to connect to
    void putIdamServerHost(const char *host)
    void putIdamServerPort(int port)
    
    # Get server properties
    char *getIdamServerHost()
    int getIdamServerPort()
    int getIdamClientVersion()
    int getIdamServerVersion()

    # API calls to open connections
    int idamGetAPI(const char *data_object, const char *data_source)
    
    # Close connections
    void idamFree(int handle)
    void idamFreeAll()

    # Error checking
    
    bint getIdamSourceStatus(int handle) # Returns bool
    char *getIdamErrorMsg(int handle) # NOTE: Does this allocate memory? Should it be const char*?
    
    # Data access
    
    int getIdamDataNum(int handle)
    int getIdamRank(int handle)
    int getIdamOrder(int handle)
    
    
