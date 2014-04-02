#!/usr/bin/python

import os,sys
mydict=dict()
try:
	checksumfile=sys.argv[1]
	inpfile=sys.argv[2]
	outfile=sys.argv[3]
	fp=open(checksumfile,'r')
	fp2=open(inpfile,'r')
	fp3=open(outfile,'w')
	cklines=fp.readlines()
	fp.close()
	for line in cklines:
		lna=line.split(' ')
		cksum=lna[0]
		ffn=lna[len(lna)-1]
		ffna=ffn.split('/')
		fn=ffna[len(ffna)-1].split('\n')[0]
		mydict[fn]=cksum
		
	inplines=fp2.readlines()
	fp2.close()
	for line in inplines:
		ffn=line.split(' ')[2]
		ffna=ffn.split('/')
		fn=ffna[len(ffna)-1]
		cksum=mydict[fn]
		mystr=line.split('\n')[0]
		mystr=mystr+' | checksum='+cksum+' | checksum_type=sha256\n'
		fp3.write(mystr)
except:
	print "Error accessing file or with finding precomputed checksum"
	exit()
fp3.close()

