FROM 4dndcic/ubuntu16.04-miniconda-python36:v1
MAINTAINER Michele Berselli (berselli.michele@gmail.com), Phil Grayson (phil.d.grayson@gmail.com)

# general updates & installing necessary Linux components
RUN apt-get update -y && apt-get install -y \
    bzip2 \
    gcc \
    g++ \
    git \
    less \
    libncurses-dev \
    make \
    time \
    zip \
    unzip \
    vim \
    wget \
    zlib1g-dev \
    liblz4-tool \
    libbz2-dev \
    liblzma-dev \
    locales \
    parallel \
    autoconf \
    autogen \
    autotools-dev \
    automake \
    pkg-config \
    tabix \
    yasm \
    libdbi-perl \
    libmodule-build-perl \
    libarchive-zip-perl \
    libmysqlclient-dev \
    libpng-dev \
    libexpat1-dev

WORKDIR /usr/local/bin

# conda & python libraries
RUN conda install -c bioconda -y python=3.6.8 && \
    conda clean -a -y -f

# sentieon
RUN wget https://s3.amazonaws.com/sentieon-release/software/sentieon-genomics-202112.01.tar.gz && \
    tar -xzvf sentieon-genomics-202112.01.tar.gz && \
    ln -s sentieon-genomics-202112.01 sentieon

# samtools
RUN wget https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2 && \
    tar -xjf samtools-1.9.tar.bz2 && \
    rm -rf samtools-1.9.tar.bz2 && \
    cd samtools-1.9 && \
    ./configure && \
    make && \
    cd .. && \
    ln -s samtools-1.9 samtools

# bwa mem
COPY sentieon_bwa-mem.sh .
RUN chmod +x sentieon_bwa-mem.sh

# dedup and recal
COPY sentieon_dedup-recal.sh .
RUN chmod +x sentieon_dedup-recal.sh

# env paths
ENV PATH=/usr/local/bin/sentieon/bin/:$PATH
ENV PATH=/usr/local/bin/samtools/:$PATH

# supporting UTF-8
RUN locale-gen "en_US.UTF-8" && update-locale LC_ALL="en_US.UTF-8"
ENV LC_ALL=en_US.UTF-8

CMD ["bash"]
