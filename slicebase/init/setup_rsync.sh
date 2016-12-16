#!/bin/bash

SLICENAME=$1

# A list of Google Cloud netblocks. Generated from DNS-based SPF records.  To
# regenerate this list from DNS, you can run the command:
#   nslookup -q=TXT _cloud-netblocks.googleusercontent.com  8.8.8.8 \
#    | grep text \
#    | sed -e 's/.*=spf1 //' -e 's/?all.*//' -e 's/include://g' -e 's/ /\n/g'  \
#    | while read; do nslookup -q=TXT $REPLY 8.8.8.8; done \
#    | grep 'text = ' \
#    | sed -e 's/.*spf1 //' -e 's/ ?all.*//' -e 's/ /\n/g' \
#    | grep ^ip4 \
#    | sed -e 's/ip4://' \
#    | xargs \
#    | sed -e 's/ /, /g'
GOOGLE_CLOUD_BLOCKS="8.34.208.0/20, 8.35.192.0/21, 8.35.200.0/23, 108.59.80.0/20, 108.170.192.0/20, 108.170.208.0/21, 108.170.216.0/22, 108.170.220.0/23, 108.170.222.0/24, 162.216.148.0/22, 162.222.176.0/21, 173.255.112.0/20, 192.158.28.0/22, 199.192.112.0/22, 199.223.232.0/22, 199.223.236.0/23, 23.236.48.0/20, 23.251.128.0/19, 107.167.160.0/19, 107.178.192.0/18, 146.148.2.0/23, 146.148.4.0/22, 146.148.8.0/21, 146.148.16.0/20, 146.148.32.0/19, 146.148.64.0/18, 130.211.4.0/22, 130.211.8.0/21, 130.211.16.0/20, 130.211.32.0/19, 130.211.64.0/18, 130.211.128.0/17, 104.154.0.0/15, 104.196.0.0/14, 208.68.108.0/23, 35.184.0.0/14, 35.188.0.0/16"

grep $SLICENAME rsyncd.legacy | \
while read SLICE PORT MODULE ; do
    cat <<EOF
# TEMPLATE
# for pid file, do not use /var/run/rsync.pid if
# you are going to run rsync out of the init.d script.
pid file=/var/run/rsyncd.pid
port=$PORT
hosts allow = 108.170.192.0/18, 108.177.0.0/20, 142.250.0.0/15, 172.217.0.0/16, 172.253.0.0/16, 173.194.0.0/16, 192.178.0.0/15, 199.87.241.32/28, 207.223.160.0/20, 209.85.128.0/17, 216.239.32.0/19, 216.58.192.0/19, 64.233.160.0/19, 66.102.0.0/20, 66.249.64.0/19, 70.32.128.0/19, 70.90.219.48/29, 70.90.219.72/29, 72.14.192.0/18, 74.125.0.0/16, 23.228.128.64/26, ${GOOGLE_CLOUD_BLOCKS}
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
