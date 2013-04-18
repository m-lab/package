#!/bin/bash

# NOTE:
# sliceversion.sh
#       sliceversion.sh prints verbose version information for all repositories
#       used by a slice-support repository including itself in $SOURCE_DIR.
# 
#     Defaults:
#       SOURCE_DIR - if SOURCE_DIR is not set below it defaults to $PWD
# 
#     Env: 
#       SOURCE_DIR - set from environment. 
#                    i.e. SOURCE_DIR=/some/path/to/source ./package/sliceversion.sh
# 
# TODO: make this better; handle svn, create urls, make it more easily parsable.

SOURCE_DIR=${SOURCE_DIR:-$PWD}
cd $SOURCE_DIR

set -e
echo "git remote show origin ; git log -n 1" 
git remote show origin 
git log -n 1 
echo "git submodule foreach 'git remote show origin ; git log -n 1 '" 
git submodule foreach 'git remote show origin ; git log -n 1 '
if test -f svn-submodules ; then
    echo "SVN-submodules:"
    cat svn-submodules
fi

