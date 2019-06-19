#!/usr/bin/bash

CMD=${0##*/}
TARGET=$(readlink $0)
if [ -z ${TARGET} ]; then
	TARGET=$0
fi

SUPPORTED_CMDS="build buildComp"

mountSDK()
{
	if ! [ -d /opt/sdk/3 ]; then
		/usr/local/bin/archivemount -o readonly -o nosave /sdk.tar.bz2 /opt/sdk
	fi
}

fixupSourceTree()
{
	cd
	chmod +x /ZQProjs/build/autobuild_git
	if ! [ -d /ZQProjs/release ]; then mkdir -p /ZQProjs/release; fi
		for kit in net-snmp boost openssl odbc; do
			if [ ! -d /usr/include/${kit} ] ; then continue; fi; 
			sed -i "s/\(_${kit}_dir\)[ \t]*:=.*/\1  := \/usr/g" /ZQProjs/build/defines.mk; 
	done

	sed -i 's/\-lsnmp/\-lnetsnmp/g' /ZQProjs/TianShan/Shell/ZQSNMPManPkg/makefile
	sed -i 's/snmplink[ ]*:=/snmplink:= $(addprefix -l,netsnmp netsnmpagent netsnmphelpers crypto ZQSnmp) $(shell net-snmp-config --agent-libs)/g' /ZQProjs/build/defines.mk

	mkdir -p /ZQProjs/BUILDROOT
	ln -sf /ZQProjs/BUILDROOT ~/BUILDROOT
}

mountSDK
fixupSourceTree

case ${CMD} in
	build)
		/ZQProjs/build/autobuild_git -s $* -b /ZQProjs/ -u build -p nightly123 -o /ZQProjs/release
		exit 0
		;;

	buildComp)
		cd /ZQProjs/build/
		make $1
		exit 0
		;;

	rebuildComp)
		cd /ZQProjs/build/
		make veryclean $1; make $1
		exit 0
		;;

esac # ${CMD}

