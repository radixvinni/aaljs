#if EMSCRIPTEN

#include "Python.h"
#include <sys/types.h>


static PyObject *em_urlopen(PyObject *self, PyObject *args)
{
    char *url, *params=NULL, *result;
    if (!PyArg_ParseTuple(args, "s|s:urlopen", &url, &params)) {
      return NULL;
    }
    //TODO: use --js-library instead or EM_ASM macro in newer versions.
    if(params==NULL)
    result = emscripten_run_script_string(" \
      if (window.XMLHttpRequest) {              \
	AJAX=new XMLHttpRequest();              \
      } else {                                  \
	AJAX=new ActiveXObject('Microsoft.XMLHTTP');\
      }\
      if (AJAX) {\
	AJAX.open('GET', Pointer_stringify(url), false);\
	AJAX.send(null);\
	AJAX.responseText;\
      }"
    );
    else
    result = emscripten_run_script_string(" \
      if (window.XMLHttpRequest) {\
	AJAX=new XMLHttpRequest();              \
      } else {                                  \
	AJAX=new ActiveXObject('Microsoft.XMLHTTP');\
      }\
      if (AJAX) {\
	AJAX.open('POST', Pointer_stringify(url), false);\
	AJAX.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');\
	AJAX.send(Pointer_stringify(params));\
	AJAX.responseText;\
      }"
    );
    return Py_BuildValue("s", result);

}

PyDoc_STRVAR(s__doc__,
"urlopen(url, params) -> string\n\
this function opens ajax request in emscripten environment\n\
which loads a corresponding file on the web and returns it as a string.\n\
If the second optional parameter is used(containing urlencoded parameters),\n\
the POST method will be used.");


static PyMethodDef s_methods[] = {
    {"urlopen",           em_urlopen, METH_VARARGS, s__doc__},
    {NULL,              NULL}           /* sentinel */
};

PyMODINIT_FUNC
init_socket(void)
{
    Py_InitModule("_socket", s_methods);
}
#endif
