set CC=clang
set JAVA_HOME="C:\Program Files\Java\jdk1.8.0_101"
set LLVM_HOME="C:\Program Files\LLVM"

set DLL_NAME=clang.dll

set JAVA_INCLUDES=-I%JAVA_HOME%\include -I%JAVA_HOME%\include\win32

set JAVA_OUT="target/generated-sources/java/ru/urururu/clang"
mkdir %JAVA_OUT%

set CPP_OUT="target/generated-sources/jni"
mkdir %CPP_OUT%

set OBJ_DIR="target/native/static"
mkdir %OBJ_DIR%

set SOBJ_DIR="target/native/shared"
mkdir %SOBJ_DIR%

clang -E -nostdinc -fno-blocks -I%LLVM_HOME%/include -Ifake fake.c -o %CPP_OUT%/fake.h || goto :error

swig -java -outdir %JAVA_OUT% -package ru.urururu.clang -o %CPP_OUT%/libclang_wrap.c -v %SRC_DIR%/libclang.i || goto :error

%CC% -m64 -c %CPP_OUT%/libclang_wrap.c %JAVA_INCLUDES% -I%LLVM_HOME%/include %COMMONFLAGS% -o %OBJ_DIR%/wrappers.o || goto :error

%CC% -m64 -shared -llibclang -o %SOBJ_DIR%/%DLL_NAME% %OBJ_DIR%/wrappers.o -L%LLVM_HOME%\lib %LDFLAGS% %DEBUG% -v

:error