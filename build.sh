#!/bin/sh

#Native build
mkdir -p ./native
cd ./native
rm -rf *

../cpython/configure --without-threads --without-pymalloc --enable-shared --disable-ipv6
make

#Javascript build
mkdir -p ../js
cd ../js
rm -rf *

#ccproxy?
EMCONFIGURE_JS=1 emconfigure ../cpython/configure --without-threads --without-pymalloc --enable-shared --disable-ipv6

# Adjust configuration.
# Remove the closing endif so we can insert new options.
sed -i 's~#endif /\*Py_PYCONFIG_H\*/~~' pyconfig.h
# Emscripten doesn't support CPU-specific assembly code.
echo '#undef HAVE_GCC_ASM_FOR_X87' >> pyconfig.h
# Emscripten does not support interrupt signals.
echo '#undef HAVE_SIGACTION' >> pyconfig.h
echo '#undef HAVE_SIGINTERRUPT' >> pyconfig.h
echo '#undef HAVE_SIGRELSE' >> pyconfig.h

#Python > 2.7.4
echo '#undef DOUBLE_IS_BIG_ENDIAN_IEEE754' >> pyconfig.h
echo '#undef DOUBLE_IS_ARM_MIXED_ENDIAN_IEEE754' >> pyconfig.h

# Put the closing endif back.
echo '#endif /*Py_PYCONFIG_H*/' >> pyconfig.h

make #aborting with pgen execution here
cp ../native/Parser/pgen Parser
chmod a+x Parser/pgen
make #aborting with python execition here

llvm-link libpython2.7.so Modules/python.o -o python.bc
emcc -O1 python.bc -o python.js

#nodejs python.js -S -c 'print 111'