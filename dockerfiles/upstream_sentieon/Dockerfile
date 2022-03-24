#######################################################################
#     Basic image
#######################################################################
FROM cgap/cgap-ubuntu2004-py-38:0.0.1
MAINTAINER Phil Grayson (phil.d.grayson@gmail.com), Michele Berselli (berselli.michele@gmail.com)

#######################################################################
#     General updates & installing necessary Linux components
#       - libncurses-dev, libbz2-dev, liblzma-dev used by samtools
#######################################################################
RUN apt-get update -y && apt-get install -y \
    locales \
    tabix \
    libncurses-dev \
    libbz2-dev \
    liblzma-dev

#######################################################################
#     Setting working env
#######################################################################
WORKDIR /usr/local/bin

#######################################################################
#     Software
#######################################################################
## sentieon
RUN wget https://s3.amazonaws.com/sentieon-release/software/sentieon-genomics-202112.01.tar.gz && \
    tar -xzvf sentieon-genomics-202112.01.tar.gz && \
    ln -s sentieon-genomics-202112.01 sentieon

## samtools
RUN wget https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2 && \
    tar -xjf samtools-1.9.tar.bz2 && \
    rm -rf samtools-1.9.tar.bz2 && \
    cd samtools-1.9 && \
    ./configure && \
    make && \
    cd .. && \
    ln -s samtools-1.9 samtools

#######################################################################
#     Scripts
#######################################################################
## sentieon_bwa-mem
COPY sentieon_bwa-mem.sh .
RUN chmod +x sentieon_bwa-mem.sh

## sentieon_dedup-recal
COPY sentieon_dedup-recal.sh .
RUN chmod +x sentieon_dedup-recal.sh

#######################################################################
#     Setting env variables
#######################################################################
ENV PATH=/usr/local/bin/sentieon/bin/:$PATH
ENV PATH=/usr/local/bin/samtools/:$PATH

## Supporting UTF-8
RUN locale-gen "en_US.UTF-8" && update-locale LC_ALL="en_US.UTF-8"
ENV LC_ALL=en_US.UTF-8

CMD ["bash"]
