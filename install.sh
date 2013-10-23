#!/bin/sh

# Compile pyidam modules in place for testing

IDAMPATH="../idam/new"


CFLAGS="-I$IDAMPATH" LDFLAGS="-L$IDAMPATH" python setup.py build_ext -i

