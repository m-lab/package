#!/bin/bash

set -x 
set -e

if [ -z "$SOURCE_DIR" ] ; then
    echo "Expected SOURCE_DIR in environment"
    exit 1
fi
if [ -z "$BUILD_DIR" ] ; then
    echo "Expected BUILD_DIR in environment"
    exit 1
fi

if test -d $BUILD_DIR ; then
    rm -rf $BUILD_DIR/*
fi

# install dependencies such as development tools
yum groupinstall -y 'Development tools'

# build tool
pushd $SOURCE_DIR/
    ./configure --prefix=$BUILD_DIR
    make
    make install
popd 

cp -r $SOURCE_DIR/init           $BUILD_DIR/
