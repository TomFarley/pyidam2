# Pythonic interface to IDAM library

cimport cidam

import numpy as np
cimport numpy as np

def setHost(host):	
    """
    Set the host name of the IDAM server
    """
    if len(host) >= cidam.MAXNAME:
        raise ValueError("Host name is too long. Maximum length %d" % (cidam.MAXNAME))
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

class Dimension:
    """
    Represents a dimension of a data array
    
    Attributes
    ==========
    
    label    Short label (string)
    units    Units as string
    data     NumPy array of dimension values
    errl     NumPy array of low-side errors
    errh     NumPy array of high-side errors
    
    """
    def __init__(self, handle=None, index=0):
        self.label = ""
        self.units = ""
        self.data = None
        self.errl = None
        self.errh = None
        
        if handle != None:
        
            # Check that the handle is valid
            if not cidam.getIdamSourceStatus(handle):
                # Error of some kind
                raise IdamError(cidam.getIdamErrorMsg(handle))

            # Check that the index is valid
            if index < 0 or index >= cidam.getIdamRank(handle):
                raise IdamError("Dimension index is out of range")

            # Get dimension descriptions
            self.label = cidam.getIdamDimLabel(handle, index)
            self.units = cidam.getIdamDimUnits(handle, index)
            
            # Get size of the data, create NumPy array, read values
            size = cidam.getIdamDimNum(handle, index)
            self.data = np.empty(size, dtype=np.float32)
            cidam.getIdamFloatDimData(handle, index, <float*> np.PyArray_DATA(self.data))
            # Get the errors, if available
            if cidam.getIdamDimErrorType(handle, index) != cidam.TYPE_UNKNOWN:
                self.errl = np.empty(size, dtype=np.float32)
                cidam.getIdamFloatDimAsymmetricError(handle, index, 0, 
                                                     <float*> np.PyArray_DATA(self.errl))
                if not cidam.getIdamDimErrorAsymmetry(handle, index):
                    # Symmetric error
                    self.errh = self.errl
                else:
                    # Asymmetric error
                    self.errh = np.empty(size, dtype=np.float32)
                    cidam.getIdamFloatDimAsymmetricError(handle, index, 1, 
                                                         <float*> np.PyArray_DATA(self.errh))

class Data:
    """
    Represents a data item from IDAM
    
    Attributes
    ==========

    data      NumPy array containing the data
    errl      Low-side error (may be None)
    errh      High-side error (may be None)
    
    name      The name used to request the data (e.g. "amc_plasma current")
    source    Source of the data as a string (e.g. "15100")
    label     Short description (e.g. "Plasma Current")
    units     Data units (e.g. "kA")
    desc      longer description (if set)

    dim       A list of Dimension objects corresponding to data array indices
    
    order     Index of time dimension

    time      Same as dim[order]. May be None
    
    """

    def __init__(self, data, source, host=None, port=None, verbose=False):
        # Make sure the inputs are strings
        data = str(data)
        source = str(source)
        
        if host != None: # Change the host
            oldhost = cidam.getIdamServerHost()
            cidam.putIdamServerHost(host)
        
        if port != None: # Change the port
            oldport = cidam.getIdamServerPort()
            cidam.putIdamServerPort(port)
        
        try:
            if verbose:
                print("Connecting to %s:%d" % (cidam.getIdamServerHost(), cidam.getIdamServerPort()))
                print("Reading '%s' from '%s'" % (data, source))
            # Open connection 
            handle = cidam.idamGetAPI(data, source)
            
            if not cidam.getIdamSourceStatus(handle):
                # Error of some kind
                raise IdamError(cidam.getIdamErrorMsg(handle))
            try:
                # Read properties
                self.label = cidam.getIdamDataLabel(handle)
                self.units = cidam.getIdamDataUnits(handle)
                self.desc  = cidam.getIdamDataDesc(handle)
                
                # Get the size and shape of the data array
                n     = cidam.getIdamDataNum(handle)
                rank  = cidam.getIdamRank(handle)
                order = cidam.getIdamOrder(handle)
                
                # NOTE: Order of the dimensions is reversed
                self.order = rank - 1 - order
                
                dimsize = []
                for i in range(rank):
                    dimlen = cidam.getIdamDimNum(handle, i)
                    dimsize.append(dimlen)
                
                # Create an empty array of type float
                self.data = np.empty(dimsize, dtype=np.float32)
                # Read data into array, passing underlying float*
                cidam.getIdamFloatData(handle, <float*> np.PyArray_DATA(self.data))
                
                # Get the data errors (low and high asymmetric)
                if cidam.getIdamErrorType(handle) != cidam.TYPE_UNKNOWN:
                    # Got error data
                    self.errl = np.empty(dimsize)
                    cidam.getIdamFloatAsymmetricError(handle, 0, <float*> np.PyArray_DATA(self.errl))
                    if not cidam.getIdamErrorAsymmetry(handle):
                        # Error is symmetric. Just point to the same data
                        self.errh = self.errl
                    else:
                        # Need separate array
                        self.errh = np.empty(dimsize)
                        cidam.getIdamFloatAsymmetricError(handle, 1, <float*> np.PyArray_DATA(self.errh))
                else:
                    self.errl = None
                    self.errh = None
                
                # Read the dimensions
                self.dim = []
                for i in range(rank):
                    self.dim.append(Dimension(handle, i))
                    
                # Create shortcut to time dimension
                self.time = None
                if self.order >= 0 and self.order < rank:
                    self.time = self.dim[self.order]
            finally:
                # Close connection
                cidam.idamFree(handle);
            
        finally:
            # Tidy up, restore host and port
            if host != None:
                cidam.putIdamServerHost(oldhost) 
            if port != None:
                cidam.putIdamServerPort(oldport)
        
