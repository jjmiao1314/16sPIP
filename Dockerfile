FROM ubuntu:14.04
MAINTAINER Docker miaojiaojiao <jjmiao1314@163.com>

RUN mkdir /bioapp
RUN mkdir /var/data
WORKDIR /var/data
RUN mkdir /var/data/report
RUN mkdir /var/data/report/Tables

RUN apt-get update &&\
    apt-get install -y make g++ && \
    apt-get install libidn11
COPY ./ncbi-blast-2.6.0+-x64-linux.tar.gz /bioapp/
RUN cd /bioapp &&\
    tar -zvxf ncbi-blast-2.6.0+-x64-linux.tar.gz
COPY ./bin/ /bioapp/ 
RUN apt-get install -y build-essential && \
    apt-get install -y enscript ghostscript
RUN apt-get install -y perl && \
    apt-get install -y python-dev && \
    apt-get install -y python-pip && \
    apt-get install -y python-numpy && \
    python2.7 -m pip install biopython
RUN apt-get install -y picard-tools
COPY ./seq_crumbs-0.1.9.tar.gz /bioapp/
RUN cd /bioapp/ &&\
    tar -zvxf seq_crumbs-0.1.9.tar.gz && \
    cd seq_crumbs-0.1.9 && \
    python setup.py install && \
    rm ../seq_crumbs-0.1.9.tar.gz
RUN cd /bioapp/bwa-0.7.12 && \
    make all
RUN cd /bioapp && \
    /bioapp/ncbi-blast-2.6.0+/bin/makeblastdb -in /bioapp/16S-complete.fa -dbtype nucl -parse_seqids -out 16S-complete &&\
    rm /bioapp/16S-complete.fa /bioapp/ncbi-blast-2.6.0+-x64-linux.tar.gz
   
RUN apt-get clean
