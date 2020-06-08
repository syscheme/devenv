#!/bin/bash
# example command to launch: docker run --privileged -it -v /path-to-container-ctx/indexsvc:/data 10.50.3.199:5000/tianshan/indexsvc:v3.6.1.1

SVCBIN=$1
SVCNAME=$1

STAMP=$(date +%m%dT%H%M%S)

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

export ASAN_OPTIONS="disable_coredump=0:unmap_shadow_on_exit=1:abort_on_error=1:symbolize=1"
export ASAN_SYMBOLIZER_PATH=/usr/bin/llvm-symbolizer

CMD="/opt/TianShan/bin/${SVCBIN} -s ${SVCNAME} -i 0 -n ${HOSTNAME} -m"
echo "$STAMP: $CMD" | tee -a /opt/TianShan/logs/${SVCNAME}_stdout.log
${CMD}  2>&1 |tee -a /opt/TianShan/logs/${SVCNAME}_stdout.log

