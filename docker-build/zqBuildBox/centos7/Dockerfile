FROM centos:latest
MAINTAINER hui.shao@xor-media.tv

RUN yum update -y && yum install -y ant bison cpp dos2unix flex gcc gcc-c++ gdb git glibc glibc-devel glib-networking make rpm-build libasan bzip2-devel zlib-devel \
    boost-devel boost-regex expat fuse-devel graphite2 iptable-devel java-1.7.0-openjdk-devel libicu openssl openssl-devel net-snmp-devel net-snmp-libs && \
    rm -rf /var/cache/yum

RUN yum install -y libnl libnl3 unixODBC unixODBC-devel mysql-connector-odbc libdb-devel libdb-cxx-devel python-devel libiptc libmnl && \
    rm -rf /var/cache/yum

# ADD /*.rpm /tmp/
# RUN yum install -y /tmp/*.rpm && rm -rf /tmp/*.rpm

RUN mkdir -p /opt /ZQProjs
VOLUME /ZQProjs
VOLUME /opt

ADD usr.tar.bz2 /
ADD sdk.tar.bz2 /opt/

COPY build.sh /usr/local/bin/
RUN  for i in build buildComp rebuildComp; do ln -sf /usr/local/bin/build.sh /usr/local/bin/$i; done

# CMD /usr/bin/bash
CMD /usr/bin/build



