#!/bin/sh

# *******************************************
# Script to generate an analysis ready bam
# for a single sample from a raw bam file.
# The raw bam file need to be processed
# to add read groups.
# *******************************************

## Command line arguments
# input bam
raw_bam=$1

# reference data files
reference_fa=$2
dbsnp=$3
known_Mills_indels=$4

# other
optical_dup_pix_dist=$5

## Other settings
nt=$(nproc) #number of threads to use in computation, set to number of cores in the server

## SymLink to reference files
fasta="reference.fasta"

# fasta
ln -s ${reference_fa}.fa reference.fasta
ln -s ${reference_fa}.fa.fai reference.fasta.fai
ln -s ${reference_fa}.dict reference.dict

# ******************************************
# 1. Sort bam.
# ******************************************
sentieon util sort -t $nt -i $raw_bam -o sorted.bam || exit 1

# ******************************************
# 2. Mark/Remove Duplicate Reads. By
# ommiting the --rmdup option in Dedup
# we are only marking to match upstream GATK.
# ******************************************
sentieon driver -t $nt -i sorted.bam --algo LocusCollector --fun score_info score.txt || exit 1
sentieon driver -t $nt -i sorted.bam --algo Dedup --optical_dup_pix_dist $optical_dup_pix_dist --score_info score.txt --metrics dedup_metrics.txt deduped.bam || exit 1

# *****************************************************************************
# 3. Base recalibration - see:
# https://support.sentieon.com/appnotes/arguments/#bqsr-calculate-recalibration
# not generating RECAL_DATA.TABLE.POST for plotting, just need recal_data.table
# *****************************************************************************
sentieon driver -r $fasta -t $nt -i deduped.bam --algo QualCal -k $dbsnp -k $known_Mills_indels recal_data.table || exit 1
sentieon driver -r $fasta -t $nt -i deduped.bam --read_filter QualCalFilter,table=recal_data.table,indel=false --algo ReadWriter recalibrated.bam || exit 1

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
