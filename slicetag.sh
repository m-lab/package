#!/bin/bash

function settag () {
    local RELEASE=$1

    if ! test -f .gitmodules && ! test -f svn-submodules ; then
        echo "Error: we don't think you are inside a slice-support repo."
        exit 1
    fi
    if git diff --exit-code ; then
        echo "Applying tag: $RELEASE"
        if ! git tag $RELEASE ; then
            echo "Error: failed to set 'git tag $RELEASE'"
            echo "Error: please investigate."
            exit 1
        fi
        echo "Pushing tag to remote"
        if ! git push --tags ; then
            echo "Error: failed to push new tag upstream with 'git push --tags'"
            echo "Error: please investigate."
            exit 1
        fi
        echo "Done!"
        git tag -l
    else
        echo "Error: There are uncommitted changes here."
        echo "Error: Either commit or remove local changes "
        echo "       before applying tags."
        exit 1
    fi
}

set -e

command=$1
shift || :

TAG=$( git rev-list --all | wc -l ) 

if [[ $command =~ "get" ]] ; then
    # Expect a tag to have been set previously.
    RELEASE=$( git describe --abbrev=0 --tags 2> /dev/null || : )
    if [ -z "$RELEASE" ] ; then
        # But, if there is not one, return 'master'
        RELEASE=master-$TAG.mlab
    fi
    echo $RELEASE
elif [[ $command =~ "set" ]] ; then
    VERSION=$1
    RELEASE=$VERSION-$TAG.mlab
    settag $RELEASE
else
    echo "Usage: $0 <get|set> [version]"
    echo "i.e. $0 set 1.0"
    exit 1
fi

