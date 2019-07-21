#!/bin/bash

# Exit on failure
set -e

JAVA_HOME=`/usr/libexec/java_home -v 1.8`
LLVM_HOME=${LLVM_HOME:-/usr/local/Cellar/llvm/7.0.1}

case `uname` in
    Linux)
        export CC=gcc
        export CXX=g++
        export LD=g++

        DLL_NAME=libclang.so

        JAVA_INCLUDES="-I$JAVA_HOME/include/ -I$JAVA_HOME/include/linux/"
        LDFLAGS="-lpthread -ltermcap"

        # todo nice to have
        #LDFLAGS="$LDFLAGS -Wl,-z,defs"
    ;;
    Darwin)
        CC=clang
        CXX=clang++
        LD=clang++

        DLL_NAME=libclang.jnilib

        JAVA_INCLUDES="-I$JAVA_HOME/include/ -I$JAVA_HOME/include/darwin/"
        LDFLAGS="-ltermcap -L/usr/local/opt/libffi/lib"
    ;;
    *)
        echo Unknown environment: `uname`
        exit 1
    ;;
esac

JAVA_OUT="target/generated-sources/java/ru/urururu/clang"
mkdir -p $JAVA_OUT

CPP_OUT="target/generated-sources/jni"
mkdir -p $CPP_OUT

OBJ_DIR="target/native/static"
mkdir -p $OBJ_DIR

SOBJ_DIR="target/native/shared"
mkdir -p $SOBJ_DIR

clang -E -nostdinc -fno-blocks -I$LLVM_HOME/include -Ifake fake.c -o $CPP_OUT/fake.h

swig -java -outdir $JAVA_OUT -package ru.urururu.clang -o $CPP_OUT/libclang_wrap.c -v $SRC_DIR/libclang.i

$CC -c $CPP_OUT/libclang_wrap.c $JAVA_INCLUDES -I$LLVM_HOME/include $COMMONFLAGS -o $OBJ_DIR/wrappers.o

$CC -shared -lclang -o $SOBJ_DIR/$DLL_NAME $OBJ_DIR/wrappers.o -L$LLVM_HOME/lib $LDFLAGS $DEBUG