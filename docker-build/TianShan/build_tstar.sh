#!/bin/bash
BINFILES=$1
MODULEFILES=$2

echo > binlist.txt;
for i in ${BINFILES} ; do
    FILE="/opt/TianShan/bin/${i}*"
    echo "$FILE" >>  binlist.txt
    ldd $FILE | grep '=> /opt/TianShan' |  awk '{print $3 "*"; }' >>  binlist.txt
done

for i in ${MODULEFILES} ; do 
    FILE="/opt/TianShan/modules/lib${i}.so*"
    echo "$FILE" >>  binlist.txt
    ldd $FILE | grep '=> /opt/TianShan' |  awk '{print $3 "*"; }' >>  binlist.txt
done

FILELIST=$(sed -e 's/\/\.\//\//g' binlist.txt | sed 's/\/\.\//\//g' | sed 's/\/modules\/\.\.\/bin\//\/bin\//g' | uniq)
FILELIST+=" /opt/TianShan/etc/TianShan.xml /opt/TianShan/etc/TianShanDef.xml"

rm -rf ts.tar.bz2
tar cfvj ts.tar.bz2 ${FILELIST}
