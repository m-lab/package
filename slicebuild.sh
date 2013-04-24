#!/bin/bash

set -e

if [ -z "$1" ] ; then
    echo "
Usage: $0 <slicename>
    slicename might be: iupui_npad, mlab_neubot, etc.
    For testing, you can use any name, i.e. foobar

By default, $0 uses two locations for sources and output:
    SOURCE_DIR -- by default PWD.
    BUILD_DIR  -- by default /home/$SLICENAME

Both can be set from the environment.

$0 performs all the steps needed to turn your experiment into an RPM package.
   * bootstraps the local repositories (if needed)
   * prepares/builds the slice using provided 'prepare.sh'
   * collect the versions of all repositories
   * generates an rpm spec file
   * and builds the rpm."
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
mkdir -p $BUILD_DIR
if test -f $SOURCE_DIR/init/prepare.sh ; then
    $SOURCE_DIR/init/prepare.sh
fi

# TODO: make this better; handle svn, handle urls, parsable.
$PACKAGE_DIR/sliceversion.sh > $BUILD_DIR/version

# NOTE: generate slice spec file with slicebase hooks
$PACKAGE_DIR/slicespec.sh > $SPECFILE

# NOTE: actually build rpm
make -f $PACKAGE_DIR/slice.mk
