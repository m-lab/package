#!/bin/bash

# NOTE:
# bootstrap.sh 
#     bootstrap checks environment for needed commands, and downloads missing
#     repositories for a slice support repository in $SOURCE_DIR.
#
#     Defaults:
#       SOURCE_DIR - if SOURCE_DIR is not set below it defaults to $PWD
# 
#     Env: 
#       SOURCE_DIR - set from environment. 
#                    i.e. SOURCE_DIR=/some/path/to/source ./package/bootstrap.sh 
#

SOURCE_DIR=${SOURCE_DIR:-$PWD}
cd $SOURCE_DIR

set -e

# NOTE: check for dependencies
for command in git svn rpmbuild m4 ; do
    if ! type -P $command &> /dev/null ; then
        echo "ERROR: could no locate '$command' in current PATH"
        echo "ERROR: either install $command, or update PATH"
        exit 1
    fi
done

# NOTE: some of this is redundant; sorry.
# Pull in any git submodules
if test -f .gitmodules ; then
    git submodule update --init --recursive 
fi

# svn does not have submodule functionality, so use list of tags
if test -f svn-submodules ; then
    cat svn-submodules | while read rev repo dir ; do 
        echo "Checking out revision:$rev from $repo"
        svn checkout -r $rev $repo $dir
    done
fi

# also check for a list of tar archives
if test -f tar-archives ; then
    cat tar-archives | while read filename url ; do 
        if ! test -f $filename ; then
            echo "Downloading: $url"
            wget -o $filename $url
        fi
        # NOTE: tar should detect compression automatically
        if test -f $filename ; then
            tar -C $SOURCE_DIR -xvf $filename
        fi
    done
fi
