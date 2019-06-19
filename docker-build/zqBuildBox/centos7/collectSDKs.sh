#!/usr/bin/bash
CWD=`pwd`
for i in 3rdPartyKits SeaChangeKits ; do
        cd /opt/sdk/$i
        tar cfvj /tmp/$i.tar.bz2 -X ${CWD}/sdk-excl.txt `ls -l |grep '\->'|grep -v 'boost\|net-snmp\|unixODBC' |sed -e 's/.* \([^ ]*\) \-> \([^ ]*\)$/ \1  \2/g'`
done;

