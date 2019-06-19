#!/usr/bin/bash

LISTEN_PORT=$1

mkdir -p /opt/TianShan/
if [ -d /ZQProjs/out ]; then
	mkdir -p /ZQProjs/tmp/logs
	mkdir -p /ZQProjs/tmp/data
fi

if ! [ -d /opt/TianShan/bin ]; then
	ln -sf /ZQProjs/out/bin /opt/TianShan/bin
fi

if ! [ -d /opt/TianShan/modules ]; then
	ln -sf /ZQProjs/out/modules /opt/TianShan/modules
fi

if ! [ -d /opt/TianShan/etc ]; then
	ln -sf /ZQProjs/TianShan/etc /opt/TianShan/etc
fi

if ! [ -d /opt/TianShan/utils ]; then
	ln -sf /ZQProjs/TianShan/utils /opt/TianShan/utils
fi

if ! [ -d /opt/TianShan/logs ]; then
	ln -sf /ZQProjs/tmp/logs /opt/TianShan/logs
fi

if ! [ -e /etc/TianShan.xml ]; then
	ln -sf /ZQProjs/TianShan/TianShan.xml /etc/TianShan.xml
fi

if [ -z ${LISTEN_PORT} ]; then
	LISTEN_PORT=689
fi

PATH=/opt/TianShan/bin:/opt/TianShan/modules:${PATH}
cd /opt/TianShan/bin

/usr/bin/gdbserver --once --debug --multi 0:${LISTEN_PORT}

