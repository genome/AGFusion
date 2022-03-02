FROM ubuntu:bionic
# AGFusion original source code is available at https://github.com/murphycj/AGFusion
# This docker image was originally derived from rachelbj/agfusion:1.1


# INSTALL DEPENDENCIES

ENV DEBIAN_FRONTEND=noninteractive
ENV PYENSEMBL_CACHE_DIR=/opt

RUN apt-get update -y
RUN apt-get install -y build-essential python3 python3-pip python3-matplotlib python3-pandas python3-future python3-biopython curl less vim libnss-sss git
RUN pip3 install pyensembl

# Additional libraries needed for AGFusion build command
RUN apt-get install -y default-libmysqlclient-dev
RUN pip3 install mysqlclient


# INSTALL AGFUSION & DATABASE FILES

ENV ensembl_version=95

# Download latest AGFusion from source and install with pip
WORKDIR /usr/local/bin
RUN git clone https://github.com/genome/AGFusion.git
WORKDIR /usr/local/bin/AGFusion
RUN pip3 install .

# Install AGFusion databases
RUN mkdir -p /opt/agfusiondb/
WORKDIR /opt/agfusiondb
# At the time of writing, this downloads Pfam release 35
RUN curl http://ftp.ebi.ac.uk/pub/databases/Pfam/current_release/database_files/pfamA.txt.gz > pfamA.txt.gz
RUN gunzip pfamA.txt.gz
RUN agfusion build --dir . --species homo_sapiens --release ${ensembl_version} --pfam pfamA.txt
RUN agfusion build --dir . --species mus_musculus --release ${ensembl_version} --pfam pfamA.txt
RUN rm pfamA.txt

# Install pyensembl databases
RUN pyensembl install --species homo_sapiens --release ${ensembl_version}
RUN pyensembl install --species mus_musculus --release ${ensembl_version}

