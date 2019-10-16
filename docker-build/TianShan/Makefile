common: 
	tar cfvj common.tar.bz2 \
		opt/TianShan/bin/SystemShell* \
		opt/TianShan/bin/libFreeze.so* \
		opt/TianShan/bin/libGlacier2.so* \
		opt/TianShan/bin/libIce.so* \
		opt/TianShan/bin/libIceBox.so* \
		opt/TianShan/bin/libIceGrid.so* \
		opt/TianShan/bin/libIceStorm.so* \
		opt/TianShan/bin/libIceStormService.so* \
		opt/TianShan/bin/libIceUtil.so* \
		opt/TianShan/bin/libJndiClient* \
		opt/TianShan/bin/libMsgSender* \
		opt/TianShan/bin/libSnmpAgent* \
		opt/TianShan/bin/libSnmpManPkg* \
		opt/TianShan/bin/libSnmpPlug* \
		opt/TianShan/bin/libSysLogger* \ 
		opt/TianShan/bin/libTSClient* \
		opt/TianShan/bin/libTianShanIce* \
		opt/TianShan/bin/libasync.so* \
		opt/TianShan/bin/libcurl.so* \
		opt/TianShan/bin/libdb_cxx-4.5.so \
		opt/TianShan/bin/libsnmp++.so* \
		opt/TianShan/bin/libuuid.so* \
		opt/TianShan/bin/libnl.so* \
		opt/TianShan/bin/libpcap.so* \
		opt/TianShan/bin/libZQCommon* \
		opt/TianShan/bin/libZQSnmp*

docker: common
	docker build -t syscheme/tianshan-common -f TianShan-common.dkr .

tsinstall:
	yum localinstall -y ./TianShan-*.rpm
	rm -rf etc; mv /opt/TianShan/etc .
	rm -rf /opt/TianShan/{logs,data,etc}
	tar cfvj ts.tar.bz2 /opt/TianShan

docker-idx: tsinstall
	docker build -t syscheme/tianshan-idxsvc -f TianShan-indexsvc.dkr .

