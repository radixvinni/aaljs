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
#echo '#undef DOUBLE_IS_BIG_ENDIAN_IEEE754' >> pyconfig.h
#echo '#undef DOUBLE_IS_ARM_MIXED_ENDIAN_IEEE754' >> pyconfig.h

echo '#define PY_NO_SHORT_FLOAT_REPR' >> pyconfig.h

# Put the closing endif back.
echo '#endif /*Py_PYCONFIG_H*/' >> pyconfig.h

make #aborting with pgen execution here
cp ../native/Parser/pgen Parser
chmod a+x Parser/pgen
make #aborting with python execition here


AAL="../AAF/AAL/Converter.cpp
      ../AAF/AAL/DecompositionManager.cpp
      ../AAF/AAL/Ellipticcurves.cpp
      ../AAF/AAL/EllipticcurvesGF2.cpp
      ../AAF/AAL/EllipticcurvesGF3.cpp
      ../AAF/AAL/FactorizationAlgorithms.cpp
      ../AAF/AAL/HashClass.cpp
      ../AAF/AAL/Hash.cpp
      ../AAF/AAL/IntegerBinom.cpp
      ../AAF/AAL/IntegerBinomEllipticcurves.cpp
      ../AAF/AAL/Integer.cpp
      ../AAF/AAL/Matrix.cpp
      ../AAF/AAL/NumberVector.cpp
      ../AAF/AAL/Polynom.cpp
      ../AAF/AAL/PolynomGF2_m_4.cpp
      ../AAF/AAL/PolynomGF2_mY_7.cpp
      ../AAF/AAL/PolynomGF3.cpp
      ../AAF/AAL/PolynomGF3_m_6.cpp
      ../AAF/AAL/PolynomGF3_mY_9.cpp
      ../AAF/AAL/PolynomGF7.cpp
      ../AAF/AAL/PolynomGF7_m_14.cpp
      ../AAF/AAL/PolynomGF7_m14.cpp
      ../AAF/AAL/PolynomGF7_m_2.cpp
      ../AAF/AAL/PolynomGF7_mY_13.cpp
      ../AAF/AAL/PolynomGF7_mY_26.cpp
      ../AAF/AAL/PolynomGF7_mY_3.cpp
      ../AAF/AAL/PrimeTester.cpp
      ../AAF/AAL/ProbingDivisionAlgorithmDecomposition.cpp
      ../AAF/AAL/ProbingDivisionAlgorithmDecompositionThread.cpp
      ../AAF/AAL/TableManager.cpp
      AALPYTHON_wrap.cxx"

cp pyconfig.h ../aal/Bindings
cd ../aal/Bindings

function build_module {
  echo "  Building $1..."

  # Compile.
  FLAGS="-fPIC -fno-strict-aliasing -I.. -IInclude -I../../cpython/Include -I../../cpython/Modules/expat -Wstrict-prototypes"
  FILES=""
  for ((i=2; i<=$#; i++)); do
    emcc $FLAGS ${!i} -o `basename ${!i}`.o
    FILES="$FILES `basename ${!i}`.o"
  done

  # Link.
  llvm-link ../../js/libpython2.7.so $FILES ../../js/Modules/python.o -o ../../js/python.bc
}

build_module _AAL $AAL
cd ../../js

#emcc -O1 python.bc -o python.js
#nodejs python.js -S -c 'print 111'

cp pyconfig.h ../cpython
cd ../cpython
./build_modules

mkdir -p dist/lib/python2.7/config
mkdir -p dist/include/python2.7
cp -r Lib/* dist/lib/python2.7
rm -rf dist/lib/python2.7/{idlelib,lib-tk,multiprocessing,curses,bsddb}
rm -rf dist/lib/python2.7/plat-{aix3,aix4,atheos,beos5,darwin,freebsd4,freebsd5,freebsd6,freebsd7,freebsd8,generic,irix5,irix6,mac,netbsd1,next3,os2emx,riscos,sunos5,unixware7}
rm -rf dist/lib/python2.7/test
rm -rf dist/lib/python2.7/*/test{,s}

cp Makefile Modules/{Setup*,config.c} dist/lib/python2.7/config
cp pyconfig.h dist/include/python2.7/

cp ../aal/Bindings/AAL.py dist/lib/python2.7/

cat pre_fs.js > fs.js
python map_filesystem.py dist >> fs.js
cat post_fs.js >> fs.js
emcc -O2 ../js/python.bc -s NAMED_GLOBALS=1 -s INVOKE_RUN=0 --pre-js fs.js\
 -s EXPORTED_FUNCTIONS="['_Py_Initialize', '_PySys_SetArgv', '_PyErr_Clear',\
 '_PyEval_EvalCode', '_PyString_AsString', '_Py_DecRef', '_PyErr_Print',\
 '_PyErr_Fetch', '_init_AAL']" -s ASM_JS=0 -s LINKABLE=1 -o dist/python.js

cp ../dist/index.html ../dist/worker.js dist
