sdk: # 3rdPartyKits.tar.bz2 SeaChangeKits.tar.bz2
	mkdir -p sdk/3rdPartyKits
	mkdir -p sdk/SeaChangeKits
#	tar xfvj 3rdPartyKits.tar.bz2 -C sdk/3rdPartyKits
#	tar xfvj SeaChangeKits.tar.bz2 -C sdk/SeaChangeKits
#	tar xfvj iptc.tar.bz2

extrarpm:
#	yum install --downloadonly --downloaddir=. gsoap gsoap-devel

builddocker: sdk extrarpm
	docker build -t syscheme/zqbbox_centos .

dbgdocker: Dockerfile.dbg dbgs.sh # builddocker
	docker build -t syscheme/zqdbg_centos -f Dockerfile.dbg .

docker: builddocker dbgdocker

push: docker
	while [ 1 ]; do docker push syscheme/zqbbox_centos; [ -z $? ] && break; done
