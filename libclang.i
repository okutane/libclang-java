%module libclang

%{
#include <clang-c/Index.h>
%}
 
/* Parse the header file to generate wrappers */
%include "target/generated-sources/jni/fake.h"

%pragma(java) jniclasscode=%{
  static {
     System.loadLibrary("clang");
  }
%}