
import _cidam

def test(host="mast.fusion.org.uk", port=56565):
    _cidam.putIdamServerHost(host)
    _cidam.putIdamServerPort(port)

    handle = _cidam.idamGetAPI("amc_plasma current", "15100")
    
    print("Status: " + str(_cidam.getIdamSourceStatus(handle)))
    
    _cidam.idamFree(handle)


import pyidam
import matplotlib.pyplot as plt

def test2(host="mast.fusion.org.uk", port=56565):
    
    d = pyidam.Data("amc_plasma current", 15100)
    
    plt.plot(d.data)
    plt.show()


if __name__ == "__main__":
    test2()
