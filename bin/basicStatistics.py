#!/usr/bin/python
#-*- coding:utf-8 -*-
#
#

import re,os,sys

if len(sys.argv) < 3:
	print "usage: basicStatistics.py <parent_file> <fasta|fastq> <outFile>"
	sys.exit(-1)

file=sys.argv[1]
format=sys.argv[2]
outfile=sys.argv[3]

file_size=float(os.path.getsize(file))/1024/1024
#print ("%.3fM\n")%file_size
fh=open(file)
lines=fh.readlines()
if format == "fastq" :
    read=[line[:-1] for line in lines[1::4]]
    reads_num=len(read)
    seq="".join(read).upper()
    base_num=len(seq)
    gc_num=seq.count("C")+seq.count("G")
    gc_num_p=float(gc_num)/base_num*100
elif format == "fasta" :
    read=[line[:-1] for line in lines[1::2]]
    reads_num=len(read)
    seq="".join(read).upper()
    base_num=len(seq)
    gc_num=seq.count("C")+seq.count("G")
    gc_num_p=float(gc_num)/base_num*100
else:
    print "usage: basicStatistics.py <parent_file> <fasta|fastq>"
    sys.exit(-1)

#print ("%s\t%s\n%s\n%s\t%.3f\n")%(read,reads_num,seq,base_num,gc_num_p)

out=open(outfile,'w')
out.write("SampleFile: "+file+"\n")
out.write("Sum Data: %.3fM\n"%file_size)
out.write("Read Num: %i\n"%reads_num)
out.write("Read Len: %i\n"%(base_num/reads_num))
out.write("GC: %.3f\n"%gc_num_p)

fh.close()
out.close()
    


