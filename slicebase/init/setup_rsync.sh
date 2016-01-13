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
hosts allow = 108.170.192.0/18, 108.177.0.0/20, 142.250.0.0/15, 172.217.0.0/16, 172.253.0.0/16, 173.194.0.0/16, 192.178.0.0/15, 199.87.241.32/28, 207.223.160.0/20, 209.85.128.0/17, 216.239.32.0/19, 216.58.192.0/19, 64.233.160.0/19, 66.102.0.0/20, 66.249.64.0/19, 70.32.128.0/19, 70.90.219.48/29, 70.90.219.72/29, 72.14.192.0/18, 74.125.0.0/16, 23.228.128.64/26 45.56.98.222
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
