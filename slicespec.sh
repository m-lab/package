#!/bin/bash

# NOTE:
# slicespec.sh [<slicename>]
# 
#     slicespec.sh produces (on stdout) the rpm spec file for the provided
#     slicename.  It uses a generic slice spec as a template, and lists all the
#     files found under $BUILD_DIR.  In particular, this script should be called
#     AFTER the slice's 'prepare.sh' script.
#
#     Defaults:
#       SOURCE_DIR - if SOURCE_DIR is not set below it defaults to $PWD
#       BUILD_DIR  - if BUILD_DIR is not set below it defaults to /home/<slicename>
# 
#     Env: 
#       SLICENAME  - if the first parameter is not given, SLICENAME is taken
#                    from environment. If it's not found, slicespec will exit.
#       SOURCE_DIR - read from environment.
#       BUILD_DIR  - read from environment.

set -e

SLICENAME=${SLICENAME:-$1}
if [ -z "$SLICENAME" ] ; then
    echo "Error: Usage: $0 <slicename>"
    exit 1
fi

if ! test -f ~/.rpmmacros ; then
    # NOTE: disables creation of the extra "debuginfo" rpm
    echo "%debug_package %{nil}" > ~/.rpmmacros
else 
    if ! grep -q debug_package ~/.rpmmacros ; then
        echo "PLEASE BE AWARE:" 
        echo " By default, rpmbuild generates debuginfo packages."
        echo " These files are not used by M-Lab in production."
        echo " You can disable them by setting in ~/.rpmmacros:"
        echo " %debug_package %{nil}"
    fi
fi

SOURCE_DIR=${SOURCE_DIR:-$PWD}
BUILD_DIR=${BUILD_DIR:-/home/$SLICENAME}
PACKAGE_DIR=$SOURCE_DIR/package

cd $SOURCE_DIR

rpminstall_list=$( mktemp -p /tmp tmp.XXXXXX )
rpmfiles_list=$( mktemp -p /tmp tmp.XXXXXX )

$PACKAGE_DIR/rpmlist.sh install $SLICENAME > $rpminstall_list
$PACKAGE_DIR/rpmlist.sh files $SLICENAME > $rpmfiles_list

slicetag=$( $PACKAGE_DIR/slicetag.sh get )
rpmversion="-DRPMVERSION="$( echo $slicetag | awk -F- '{print $1}' )
rpmtag="-DRPMTAG="$( echo $slicetag | awk -F- '{print $2}' )
# TODO: maybe set this conditionally.
date="-DRPMDATE="$(date +%Y%m%dT%H00)
date=

# NOTE: writes to stdout
m4 -DRPMSLICE=$SLICENAME \
   -DSLICEinstall=$rpminstall_list \
   -DSLICEfiles=$rpmfiles_list \
   ${rpmversion} \
   ${rpmtag}  \
   ${date} \
   $PACKAGE_DIR/generic-slice.spec.m4 

# clean up
rm -f $rpminstall_list
rm -f $rpmfiles_list
