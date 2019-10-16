#!/bin/bash
mkdir -p /data/db /data/logs

ETH0_IP=$(/sbin/ip address|grep 'scope global eth0'|awk '{print $2;}'|cut -d '/' -f 1)
HOST_IP=$(/sbin/ip route|awk '{ print $3 }'|head -1)
cd /opt/TianShan/etc/
sed -i "s/name=\"HostNetID\".*value=\"[^\"]*\"/name=\"HostNetID\" value=\"${HOSTNAME}\"/g" ./TianShanDef.xml
sed -i "s/name=\"ServerNetIf\".*value=\"[^\"]*\"/name=\"ServerNetIf\" value=\"${ETH0_IP}\"/g" ./TianShanDef.xml
sed -i "s/name=\"ContainerHostIP\".*value=\"[^\"]*\"/name=\"ContainerHostIP\" value=\"${HOST_IP}\"/g" ./TianShanDef.xml

mkdir -p /opt/TianShan/logs/crashdump
cd /opt/TianShan/logs/crashdump

/opt/TianShan/bin/IndexSvc -s IndexSvc -i 0 -n ${HOSTNAME} -m


