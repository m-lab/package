#!/bin/bash

source /etc/mlab/slice-functions

if pgrep -f server &> /dev/null ; then
    echo "Stopping server:"
    pkill -KILL -f server
fi
