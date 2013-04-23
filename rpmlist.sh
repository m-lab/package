#!/bin/bash

# NOTE: this script formats a list of files under /home/$slicename for the
# %install and %files section of an RPM spec file.
#
# The script is invoked by generic-slice.spec.m4 when generating a slice's spec
# file from a build directory under /home/<slicename>.
# 
# It does the right thing for files with special characters, spaces, and
# symbolic links. 
# 
# TODO: improvements are:
#   - parameter of input directory. currently assumed /home/<slicename>
#   - recognize non-root user/group names, possibly set to "<slicename>,slices"

function format () {
    slice=$1
    ftype=$2
    file=$3
    if [ -z "$file" ] ; then 
        return 0
    fi
    if [[ $ftype =~ "install" ]] ; then
        if test -L $file ; then
            echo "ln -s $( readlink -f $file ) %{buildroot}/'home/$slice/$file'"
        elif test -d $file ; then
            #echo "mkdir -p $file"
            echo -n ""
        elif test -f $file ; then
            format="install -D -m %a '%n'	%%{buildroot}/'home/$slice/%n'"
            stat -c"$format" $file | sed -e 's|\./||g' 
        else
            echo "unknown file type: $file" >&2
        fi
    elif [[ $ftype =~ "files" ]] ; then
        if test -L $file ; then
            echo "%attr(-,$slice,slices) /home/$slice/$file"
        elif test -d $file ; then
            # NOTE: don't take explicit ownership of any directories
            echo "%attr(-,$slice,slices) /home/$slice/$file"
        elif test -f $file ; then
            format="%%attr(%a,$slice,slices) /home/$slice/%n"
            stat -c"$format" $file | sed -e 's|\./||g' 
        else
            echo "unknown file type: $file" >&2
        fi
    else
        echo "unknown file type: '$ftype'" >&2
    fi
}

function filelist () {
    ftype=$1
    slice=$2
    SLICEHOME=/home/$slice
    set -e

    PATH=$PATH:$PWD
    if ! test -d $SLICEHOME ; then
        echo "ERROR: no such directory $SLICEHOME"
        exit 1
    fi

    cd $SLICEHOME

    find ./ -path ".*swp" -prune -o \
            -path '*/.svn*' -prune -o \
            -type f -a -print | sed -e 's| \./||g' | \
            while read file ; do
                 format $slice $ftype $file
            done 
    # NOTE: guarantee that dirs come before links 
    find ./ -path ".*swp" -prune -o \
            -path '*/.svn*' -prune -o \
            -type d -a -print | sed -e 's|\./||g' | \
            while read file ; do
                format $slice $ftype $file
            done
    # NOTE: guarantee that links come AFTER the actual files above
    # NOTE: if a link is ordered before the actual file, the rpm build fails.
    find ./ -path ".*swp" -prune -o \
            -path '*/.svn*' -prune -o \
            -type l -a -print | sed -e 's|\./||g' | \
            while read file ; do
                format $slice $ftype $file
            done
}

command=$1
slicename=$2

if [ -z $command ] || [ -z $slicename ]  ; then
    echo "$0 <install|files> <slicename>"
    exit 1
fi

if   [[ $command =~ "install" ]] || [[ $command =~ "files" ]] ; then
    filelist $command $slicename 
else 
    echo "Error: unknown command: $@"
    echo "$0 <install|files> <slicename>"
    exit 1
fi

