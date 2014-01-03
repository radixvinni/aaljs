Empythoned
==========

[Empythoned](https://github.com/replit/empythoed) is a build script that uses [Emscripten](https://github.com/kripken/emscripten)
to compile CPython for use in a browser. It attempts to compile the main
interpreter as a single small executable for running with nodejs.

The project has not been updated for 2 years, so i used [this tutorial](https://github.com/jallwine/emscripten_test). 
The project is in its infancy. Right now the core interpreter works very well,
but libraries either don't work at all or contain various bugs.

Aaljs
===========

This project aims to compile a binding of MPEI AAL library for use in javascript.
Using the whole standart library is not an aim. To build this lib use old_shared_libs
branch of emscripten.

The script
===============================

It works for Python 2.7.x (here is 2.7.2).

The build is runnig in two separate directories, one for native
and one for JavaScript.

In the JavaScript directory it runs:

````
    EMCONFIGURE_JS=1 emconfigure ./configure --without-threads --without-pymalloc --enable-shared --disable-ipv6
````

If you are on Mac OS X, you will also want ``disable-toolbox-glue``.
If you are on an older version of Python (such as 2.7.2), you may
not need the ``--disable-ipv6`` option.

If you are on Python 2.7.4, you will need to edit the
``Makefile`` generated and remove the ``MULTIARCH=`` line(s)
and uncomment corresponding lines in build.sh.

After the build, it links:

````
llvm-link libpython2.7.so Modules/python.o -o python.bc
````

If you are on Mac OS X, you will want to look for ``libpython2.7.dylib``
instead of ``libpython2.7.so``.

Thanks to rasjidw and everyone else who has helped with this!

