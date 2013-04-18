#!/bin/bash

source /etc/mlab/slice-functions

export PATH=$PATH:$SLICEHOME/bin:$SLICEHOME/sbin
export LD_LIBRARY_PATH=$SLICEHOME/lib:$LD_LIBRARY_PATH

if ! pgrep -f server &> /dev/null ; then
    echo "Starting server:"
    $SLICEHOME/bin/server > /dev/null 2>&1 &
fi   
