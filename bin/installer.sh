#!/bin/bash
#
#	installer.sh
#
#	This script will install 16sPIP and its dependencies. It has been tested with Ubuntu 14.04 LTS.
#
#	quick guide:
#
#	./installer.sh
### Authors : Jiaojiao Miao <jjmiao1314@163.com>
#

#Change below folders as desired in order to change installation location.
16sPIP_PATH="/usr/16sPIP"
16sPIP_BIN="$16sPIP_PATH/bin"
##
sudo sh -c 'echo "export 16sPIP_DIR=/usr/16sPIP/bin" >> ~/.bashrc'
sudo sh -c 'echo "PATH=\$PATH:/usr/16sPIP/bin" >> ~/.bashrc'

if [ ! -d $16sPIP_PATH ]
then
	mkdir $16sPIP_PATH
fi

if [ ! -d $16sPIP_BIN ]
then
	mkdir $16sPIP_BIN
fi

cwd=$(pwd)

### install 16sPIP scripts
cd $16sPIP_BIN
sudo git clone https://github.com/jjmiao1314/16sPIP.git
cd 16sPIP
chmod 755 *
chmod 755 */*
cp * $16sPIP_BIN
cd $16sPIP_BIN
rm -rf 16sPIP
cd $cwd
echo "PATH=\$PATH:$16sPIP_PATH" >> ~/.bashrc
echo "PATH=\$PATH:$16sPIP_BIN" >> ~/.bashrc

### install & update Ubuntu packages
sudo -E apt-get update -y
sudo -E apt-get install -y make gcc g++ g++-4.6 libidn11 build-essential enscript ghostscript perl python-dev python-pip python-numpy python-biopython
sudo -E apt-get upgrade -y

### install bwa 
sudo apt-get install bwa

### install picard-tools
sudo apt-get install picard-tools

### install seq_crumbs
wget -c http://bioinf.comav.upv.es/downloads/seq_crumbs-0.1.9.tar.gz
tar -zvxf seq_crumbs-0.1.9.tar.gz
cd seq_crumbs-0.1.9
python setup.py install
mv seq_crumbs-0.1.9/bin/* $16sPIP_BIN

### install blastn
wget -c wget ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/2.6.0/ncbi-blast-2.6.0+-x64-linux.tar.gz
tar -zvxf ncbi-blast-2.6.0+-x64-linux.tar.gz
mv  ncbi-blast-2.6.0+/bin/* $16sPIP_BIN

### install pear



