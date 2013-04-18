#!/bin/bash

set -x
set -e

export RPMBUILD=$PWD/build/slicebase-$(uname -i)
export TMPBUILD=$PWD/build/tmp

# NOTE: for each non-comment line
grep -v "^#" slice-tags.list | \
while read slicetag repo slicename ; do 

    # NOTE: remove old slice dir, if present 
    test -d $slicename && rm -rf $slicename

    # NOTE: checkout repo
    git clone $repo $slicename

    # NOTE: set slice-specific source & build dirs
    export SOURCE_DIR=$PWD/$slicename
    export BUILD_DIR=/home/$slicename

    pushd $SOURCE_DIR
        # NOTE: checkout the specific slicetag
        git checkout --quiet $slicetag

        # NOTE: pull in submodules if present.
        if test -f .gitmodules ; then
            git submodule update --init --recursive 
        fi

        # NOTE: perform build & pass 'export'd vars through environment
        ./package/buildslice.sh $slicename
    popd
done

