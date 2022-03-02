FROM ubuntu:bionic

ENV DEBIAN_FRONTEND=noninteractive
ENV PYENSEMBL_CACHE_DIR=/opt

RUN apt-get update -y
RUN apt-get install -y build-essential python3 python3-pip python3-matplotlib python3-pandas python3-future python3-biopython curl less vim libnss-sss
RUN pip3 install pyensembl

ENV agfusion_version=1.2
ENV ensembl_version=87

WORKDIR /usr/local/bin
RUN curl -SL https://github.com/murphycj/AGFusion/releases/download/${agfusion_version}/agfusion-${agfusion_version}.tar.gz | tar -zxvC /usr/local/bin/
WORKDIR /usr/local/bin/agfusion-1.2
RUN pip3 install .

WORKDIR /usr/local/bin
RUN mkdir -p /opt/agfusiondb/
RUN agfusion download -s homo_sapiens -r 75 -d /opt/agfusiondb/
RUN agfusion download -s homo_sapiens -r ${ensembl_version} -d /opt/agfusiondb/
RUN agfusion download -s mus_musculus -r ${ensembl_version} -d /opt/agfusiondb/

RUN pyensembl install --species homo_sapiens --release 75
RUN pyensembl install --species homo_sapiens --release ${ensembl_version}
RUN pyensembl install --species mus_musculus --release ${ensembl_version}

