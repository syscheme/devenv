#!/bin/bash

# example command to launch: docker run --privileged -it -v /path-to-container-ctx/indexsvc:/data 10.50.3.199:5000/tianshan/indexsvc:v3.6.1.1

ETH0_IP=$(/sbin/ip address|grep 'scope global eth0'|awk '{print $2;}'|cut -d '/' -f 1)
HOST_IP=$(/sbin/ip route|awk '{ print $3 }'|head -1)
CTX_DIR="/data"

mkdir -p ${CTX_DIR}/{etc,db/runtime,logs/crashdump}

cd /opt/TianShan/etc/
for i in /opt/TianShan/etc_dk/* ; do
	FN=$(basename $i)
	if ! [ -e ./${FN} ]; then cp -f /opt/TianShan/etc_dk/${FN} . ; fi
	chmod +w ./${FN}
done

sed -i "s/name=\"HostNetID\".*value=\"[^\"]*\"/name=\"HostNetID\" value=\"${HOSTNAME}\"/g" ./TianShanDef.xml
sed -i "s/name=\"ServerNetIf\".*value=\"[^\"]*\"/name=\"ServerNetIf\" value=\"${ETH0_IP}\"/g" ./TianShanDef.xml
sed -i "s/name=\"ContainerHostIP\".*value=\"[^\"]*\"/name=\"ContainerHostIP\" value=\"${HOST_IP}\"/g" ./TianShanDef.xml
sed -i "s/name=\"TianShanDatabaseDir\".*value=\"[^\"]*\"/name=\"TianShanDatabaseDir\" value=\"\/opt\/TianShan\/data\"/g" ./TianShanDef.xml

cd /opt/TianShan/logs/crashdump

/opt/TianShan/bin/IndexSvc -s IndexSvc -i 0 -n ${HOSTNAME} -m


