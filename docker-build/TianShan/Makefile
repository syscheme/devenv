BUILDNUM :=$(shell basename $(shell realpath /opt/TianShan/bin/libZQCommon.so) | sed 's/^.*\.so[\.]*//g')
BRANCHNUM:=$(shell echo ${BUILDNUM} | cut -d '.' -f 1,2)

common: 
	tar cfmvj common.tar.bz2 \
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
		opt/TianShan/bin/libdb_cxx-4.8.so \
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
	cp -f /opt/TianShan/etc/TianShan_sample.xml /opt/TianShan/etc/TianShan.xml
	cp -f /opt/TianShan/etc/TianShanDef_sample.xml /opt/TianShan/etc/TianShanDef.xml

docker-idx: tsinstall
	./build_tstar.sh "IndexSvc" "IndexSvc"
	# export BUILDNUM=$(shell basename $(shell realpath /opt/TianShan/bin/libZQCommon.so) | sed 's/^.*\.so[\.]*//g')
	@echo version v$(BRANCHNUM), build $(BUILDNUM)
	docker build -t syscheme/tianshan-idxsvc -f TianShan-indexsvc.dkr .
	docker tag syscheme/tianshan-idxsvc:latest repo.xor:5000/tianshan/indexsvc:v$(BUILDNUM)
	docker tag repo.xor:5000/tianshan/indexsvc:v$(BUILDNUM) repo.xor:5000/tianshan/indexsvc:v$(BRANCHNUM)
	docker push repo.xor:5000/tianshan/indexsvc:v$(BUILDNUM)
	docker push repo.xor:5000/tianshan/indexsvc:v$(BRANCHNUM)

