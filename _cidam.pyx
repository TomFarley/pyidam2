"""
Python interface to IDAM C library

Simple wrapper around C calls, with some doc strings
added.

For a more pythonic interface, use the pyidam module.
"""

import numpy as np
cimport numpy as np

cimport cidam

## Properties

def setIdamProperty(property):
    "Sets a property to True"
    cidam.setIdamProperty(property)

def getIdamProperty(property):
    "Returns True/False for given property"
    return cidam.getIdamProperty(property)

def resetIdamProperty(property):
    "Sets a property to False"
    cidam.resetIdamProperty(property)

def resetIdamProperties():
    "Sets all properties to False"
    cidam.resetIdamProperties()

## Set server

def putIdamServerHost(host):
    "Set the host name of the IDAM server"
    if len(host) >= cidam.MAXNAME:
        raise ValueError("Host name is too long. Maximum length %d" % (cidam.MAXNAME))
    cidam.putIdamServerHost(host)

def putIdamServerPort(port):
    "Set the port number of the IDAM server"
    cidam.putIdamServerPort(port)

## Get server properties

def getIdamServerHost():
    "Return IDAM server host as String"
    return cidam.getIdamServerHost()

def getIdamServerPort():
    "Return IDAM server port as integer"
    return cidam.getIdamServerPort()

def getIdamClientVersion():
    "Return IDAM client version number"
    return cidam.getIdamClientVersion()

def getIdamServerVersion():
    "Return IDAM server version"
    return cidam.getIdamServerVersion()

## API calls to open and close connections

def idamGetAPI(data, source):
    """
    Given strings specifying data and source, 
    returns an IDAM connection handle
    """
    return cidam.idamGetAPI(data, source)

def idamFree(handle):
    "Closes an IDAM connection, frees handle"
    cidam.idamFree(handle)

def idamFreeAll():
    "Closes all IDAM connections, frees handles"
    cidam.idamFreeAll()

## Error checking

def getIdamSourceStatus(handle):
    "Returns True if the handle is valid"
    return cidam.getIdamSourceStatus(handle)

def getIdamErrorMsg(handle):
    "Returns error message as a string"
    return cidam.getIdamErrorMsg(handle)

## Data access

def getIdamDataNum(handle):
    "Return the size of the data (number of elements)"
    return cidam.getIdamDataNum(handle)

def getIdamRank(handle):
    "Return the rank of the data"
    return cidam.getIdamRank(handle)

def getIdamOrder(handle):
    "Return the index of the time dimension"
    return cidam.getIdamOrder(handle)

def getIdamFloatData(handle, np.ndarray data):
    """
    Given an IDAM handle and NumPy array,
    puts data into the Numpy array. 
    Checks that the type and size of the array are correct
    """
    
    # Check the type of the array. IDAM expects a float*
    assert data.dtype == np.float32

    # Check the size of the array
    n = cidam.getIdamDataNum(handle)
    if data.size < n:
        # Could resize, but for now throw an exception
        raise ValueError("NumPy array too small")

    # Check that the array is contiguous and writeable
    if not data.flags["C_CONTIGUOUS"]:
        raise ValueError("NumPy array must be contiguous")
    if not data.flags["WRITEABLE"]:
        raise ValueError("NumPy array must be writeable")
    
    cidam.getIdamFloatData(handle, <float*> np.PyArray_DATA(data))

