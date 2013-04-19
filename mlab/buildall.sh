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
    git clone --recursive $repo $slicename

    # NOTE: set slice-specific source & build dirs
    export SOURCE_DIR=$PWD/$slicename
    export BUILD_DIR=/home/$slicename

    pushd $SOURCE_DIR
        # NOTE: checkout the specific slicetag
        git checkout --quiet $slicetag

        # NOTE: perform build & pass 'export'd vars through environment
        ./package/slicebuild.sh $slicename
    popd
done

