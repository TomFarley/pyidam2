from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

ext_modules=[
    Extension("pyidam",
              ["pyidam.pyx"],
              libraries=["idam"]) # Unix-like specific
    ,
    Extension("_cidam",
              ["_cidam.pyx"],
              libraries=["idam"])
]

setup(
    name = "PyIDAM2",
    cmdclass = {"build_ext": build_ext},
    ext_modules = ext_modules
)

