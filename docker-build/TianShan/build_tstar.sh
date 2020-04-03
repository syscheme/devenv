#!/bin/bash
XMLFILES="TianShan TianShanDef $1"
BINFILES=$2
MODULEFILES=$3

echo > binlist.txt;
for i in ${BINFILES} ; do
    FILE="/opt/TianShan/bin/${i}*"
    echo "$FILE" >>  binlist.txt
    ldd $FILE | grep '=> /opt/TianShan' |  awk '{print $3 "*"; }' >>  binlist.txt

    if [ -d /opt/TianShan/bin/.debug ]; then
        FILE="/opt/TianShan/bin/.debug/${i}*"
        echo "$FILE" >>  binlist.txt
        ldd /opt/TianShan/bin/${i}* | grep '=> /opt/TianShan/' |  awk -F '/' '{print $5 ; }' | awk '{print "/opt/TianShan/bin/.debug/" $1 "*"; }' >> binlist.txt
    fi
done

for i in ${MODULEFILES} ; do 
    FILE="/opt/TianShan/modules/lib${i}.so*"
    echo "$FILE" >>  binlist.txt
    ldd $FILE | grep '=> /opt/TianShan' |  awk '{print $3 "*"; }' >>  binlist.txt
done

FILELIST=$(sed -e 's/\/\.\//\//g' binlist.txt | sed 's/\/\.\//\//g' | sed 's/\/modules\/\.\.\/bin\//\/bin\//g' | uniq)

mkdir -p /opt/TianShan/etc_dk
cp -f ./TianShanDef.xml /opt/TianShan/etc_dk/
for i in ${XMLFILES} ; do
    if [ -e "./${i}.xml" ] ; then cp -f ./${i}.xml /opt/TianShan/etc_dk/ ; fi
    if ! [ -e "/opt/TianShan/etc_dk/${i}.xml" ] ; then cp /opt/TianShan/etc/${i}_sample.xml /opt/TianShan/etc_dk/${i}.xml ; fi
    FILELIST+=" /opt/TianShan/etc_dk/${i}.xml"
done

rm -rf ts.tar.bz2
tar cfvj ts.tar.bz2 ${FILELIST}

# not sure why docker-build complain the above tar file, just extract and repack
rm -rf aaa; mkdir -p aaa ; cd aaa
tar xfvj ../ts.tar.bz2
tar cfvj ../ts.tar.bz2 .
cd ..; rm -rf aaa
 
export BUILDNUM=$(basename $(realpath /opt/TianShan/bin/libZQCommon.so) | sed 's/^.*\.so[\.]*//g')
