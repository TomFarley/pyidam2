# Pythonic interface to IDAM library

cimport cidam

def setHost(host):	
    """
    Set the host name of the IDAM server
    """
    cidam.putIdamServerHost(host)

def setPort(port):
    """
    Set the port number of the IDAM server
    """
    cidam.putIdamServerPort(port)

def setProperty(property, value=True):
    """
    Sets an IDAM property to True or False
    """
    if value:
        cidam.setIdamProperty(property)
    else:
        cidam.resetIdamProperty(property)

def getProperty(property):
    "Get a property for client/server behavior"
    return cidam.getIdamProperty(property)

class IdamError(Exception):
    """
    IDAM error
    """
    def __init__(self, msg):
        self.msg = msg
    def __str__(self):
        return repr(self.msg)

cdef class Data:
    """
    Represents a data item from IDAM
    """
    
    cdef const char* _name
    cdef const char* _source

    def __cinit__(self, data, source, host=None, port=None):
        
        self._name = "hello"
        self._source = "something"
        
        if host != None: # Change the host
            oldhost = cidam.getIdamServerHost()
            cidam.putIdamServerHost(host)
        
        if port != None: # Change the port
            oldport = cidam.getIdamServerPort()
            cidam.putIdamServerPort(port)
        
        try:
            # Open connection
            handle = cidam.idamGetAPI(data, source)
            
            if not cidam.getIdamSourceStatus(handle):
                # Error of some kind
                raise IdamError(cidam.getIdamErrorMsg(handle))
            try:
                # Read data, properties
                pass
            
            finally:
                # Close connection
                cidam.idamFree(handle);
            
        finally:
            # Tidy up, restore host and port
            if host != None:
                cidam.putIdamServerHost(oldhost) 
            if port != None:
                cidam.putIdamServerPort(oldport)
        
    property name:
        "Name used to request the data"
        def __get__(self):
            return self._name
        # Read-only, so no __set__ method

    property source:
        "Source of the data"
        def __get__(self):
            return self._source
    
