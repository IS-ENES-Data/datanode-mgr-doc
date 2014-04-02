#!/bin/bash
scripthome=/root/scripts
ncdumplocation=/middleware/uvcdat/1.4.0/bin
outputfile=/tmp/ncchecks/exclvars
tmpfileone=/tmp/ncchecks/tmpexclvars1
tmpfiletwo=/tmp/ncchecks/tmpexclvars2
notfounds=/tmp/ncchecks/notfound
suspects=/tmp/ncchecks/suspects
excllist=$scripthome/excl_cordex

if [ $# -ne 1 ]; then
	echo "bailing out";
	exit -1;
fi
ncfile=$1;
mkdir -p /tmp/ncchecks;

if [ ! -e $tmpfileone ]; then
	touch $tmpfileone;
fi
if [ ! -e $outputfile ]; then
	touch $outputfile;
fi
if [ ! -e /tmp/ncchecks/sessionfilecount ]; then
	echo "1" >/tmp/ncchecks/sessionfilecount;
fi
fcount=`cat /tmp/ncchecks/sessionfilecount`;
echo "$fcount";
fcount=`expr $fcount + 1`;
echo $fcount >/tmp/ncchecks/sessionfilecount

varname=`basename $ncfile|cut -d '_' -f1`; 
#assumes that your file is named as <var>_something.nc
$ncdumplocation/ncdump -h $ncfile|sed -n "/variables/,/global attributes/p"\
|grep -v ':'|awk 'NF'|cut -d ' ' -f2|cut -d '(' -f1 > $tmpfileone;
grep $varname $tmpfileone >/dev/null;
if [ $? -ne 0 ]; then
	echo "Could not find var $varname in file $ncfile";
	echo "Could not find var $varname in file $ncfile" >>$notfounds;
fi
cat $tmpfileone|grep -v "$varname" >$tmpfiletwo
if [ -s $tmpfiletwo ]; then
	while read ln; do 
		grep $ln $outputfile >/dev/null;
		if [ $? -ne 0 ]; then
			echo $ln >>$outputfile;
		fi
		grep $ln $excllist >/dev/null;
		if [ $? -ne 0 ]; then
			echo "line in question: $ln"
			echo "Found variable $ln in file $ncfile";
			echo "Found variable $ln in file $ncfile" >>$suspects;
		fi
		
	done <$tmpfiletwo;
fi
