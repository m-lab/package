#!/bin/bash

set -e

if [ -z "$1" ] ; then
    echo "
Usage: $0 <slicename>
    For example: iupui_npad, mlab_neubot, etc.
    HINT: for testing, you can use anything, i.e. foobar

$0 performs all the steps needed to turn your experiment into an RPM package.
   * checkout all the submodules for your slice.
   * prepare the slice using provided 'prepare.sh'
   * collect the versions of all repositories
   * generates an rpm spec file
   * builds the rpm from the spec file and output of earlier steps."

    exit 1
fi

export SLICENAME=$1
export SOURCE_DIR=${SOURCE_DIR:-$PWD}
export BUILD_DIR=${BUILD_DIR:-/home/$SLICENAME}
export RPMBUILD=${RPMBUILD:-$SOURCE_DIR/build/slicebase-$(uname -i)}
export TMPBUILD=${TMPBUILD:-$SOURCE_DIR/build/tmp}

test -d $RPMBUILD || mkdir -p $RPMBUILD
test -d $TMPBUILD || mkdir -p $TMPBUILD

export PACKAGE_DIR=$SOURCE_DIR/package
export SPECFILE=$TMPBUILD/$SLICENAME-slicebase.spec

set -x
# NOTE: pull in any git & svn submodules
$PACKAGE_DIR/bootstrap.sh 

# NOTE: prepare will remove contents of $BUILD_DIR
$SOURCE_DIR/init/prepare.sh

# TODO: make this better; handle svn, handle urls, parsable.
$PACKAGE_DIR/sliceversion.sh > $BUILD_DIR/version

# NOTE: generate slice spec file with slicebase hooks
$PACKAGE_DIR/slicespec.sh > $SPECFILE

# NOTE: actually build rpm
make -f $PACKAGE_DIR/slice.mk
