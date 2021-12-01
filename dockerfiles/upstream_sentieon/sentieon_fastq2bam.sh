#!/bin/sh
# *******************************************
# Script to generate an analysis ready bam
# for a single sample with paired fastq files
# *******************************************

## Command line arguments
# fastq
fastq_1=$1
fastq_2=$2

# sample information
sample=$7
platform=$8

# reference data files
reference_fa=$3
reference_bwt=$4
dbsnp=$5
known_Mills_indels=$6

# other
optical_dup_pix_dist=$9

## Other settings
nt=$(nproc) #number of threads to use in computation, set to number of cores in the server

## SymLink to reference files
fasta="reference.fasta"

# fasta
ln -s ${reference_fa}.fa reference.fasta
ln -s ${reference_fa}.fa.fai reference.fasta.fai
ln -s ${reference_fa}.dict reference.dict

# bwt
ln -s ${reference_bwt}.bwt reference.fasta.bwt
ln -s ${reference_bwt}.ann reference.fasta.ann
ln -s ${reference_bwt}.amb reference.fasta.amb
ln -s ${reference_bwt}.pac reference.fasta.pac
ln -s ${reference_bwt}.sa reference.fasta.sa
ln -s ${reference_bwt}.alt reference.fasta.alt

# ****************************************
# Read group
# ****************************************
group="READ_GROUP"

# ******************************************
# 1. Mapping reads with BWA-MEM, sorting.
# The results of this call are dependent on
# the number of threads used.
# To have number of threads independent results,
# add chunk size option -K 10000000
# ******************************************
( sentieon bwa mem -M -R "@RG\tID:$group\tSM:$sample\tPL:$platform" -t $nt -K 10000000 $fasta $fastq_1 $fastq_2 || exit 1 ) | sentieon util sort -r $fasta -o sorted.bam -t $nt --sam2bam -i -

# ******************************************
# 2. Remove Duplicate Reads. It is possible
# to mark instead of remove duplicates
# by ommiting the --rmdup option in Dedup
# ******************************************
sentieon driver -t $nt -i sorted.bam --algo LocusCollector --fun score_info score.txt || exit 1
sentieon driver -t $nt -i sorted.bam --algo Dedup --optical_dup_pix_dist $optical_dup_pix_dist --score_info score.txt --metrics dedup_metrics.txt deduped.bam || exit 1

# ******************************************
# 3. Base recalibration.
# ******************************************
sentieon driver -r $fasta -t $nt -i deduped.bam --algo QualCal -k $dbsnp -k $known_Mills_indels recal_data.table || exit 1
sentieon driver -r $fasta -t $nt -i deduped.bam -q recal_data.table --algo ReadWriter recalibrated.bam || exit 1

# ******************************************
# 4. Check recalibrated bam integrity.
# ******************************************
py_script="
import sys, os

def check_EOF(filename):
    EOF_hex = b'\x1f\x8b\x08\x04\x00\x00\x00\x00\x00\xff\x06\x00\x42\x43\x02\x00\x1b\x00\x03\x00\x00\x00\x00\x00\x00\x00\x00\x00'
    size = os.path.getsize(filename)
    fb = open(filename, 'rb')
    fb.seek(size - 28)
    EOF = fb.read(28)
    fb.close()
    if EOF != EOF_hex:
        sys.stderr.write('EOF is missing\n')
        sys.exit(1)
    else:
        sys.stderr.write('EOF is present\n')

check_EOF('recalibrated.bam')
"

python -c "$py_script" || exit 1
