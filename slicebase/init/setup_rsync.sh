#!/bin/bash

SLICENAME=$1

grep $SLICENAME rsyncd.legacy | \
while read SLICE PORT MODULE ; do
    cat <<EOF
# TEMPLATE
# for pid file, do not use /var/run/rsync.pid if
# you are going to run rsync out of the init.d script.
pid file=/var/run/rsyncd.pid
port=$PORT
EOF
    # use a special DIRNAME for npad
    DIRNAME=$SLICENAME
    if [[ $SLICENAME =~ "iupui_npad" ]] ; then
        DIRNAME="$SLICENAME/$MODULE"
    fi

    # NOTE: use the 'legacy' module name
    # TODO: remove this line after data pipeline is updated.
    m4 -DSLICENAME=$SLICENAME -DPORT=$PORT -DMODULENAME=$MODULE -DDIRNAME=$DIRNAME rsyncd.conf.m4 
    # NOTE: a new module name that keeps symmetry with slicename everywhere.
    m4 -DSLICENAME=$SLICENAME -DPORT=$PORT -DMODULENAME=$SLICENAME -DDIRNAME=$DIRNAME rsyncd.conf.m4 

done
