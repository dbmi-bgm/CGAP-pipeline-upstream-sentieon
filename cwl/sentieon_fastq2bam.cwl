#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

  - class: EnvVarRequirement
    envDef:
      -
        envName: SENTIEON_LICENSE
        envValue: LICENSEID

hints:
  - class: DockerRequirement
    dockerPull: ACCOUNT/upstream_sentieon:VERSION

baseCommand: [sentieon_fastq2bam.sh]

inputs:
  - id: fastq_R1
    type: File
    inputBinding:
      position: 1
    doc: reads file

  - id: fastq_R2
    type: File
    inputBinding:
      position: 2
    doc: mate-reads file

  - id: reference_fa
    type: File
    inputBinding:
      position: 3
      valueFrom: $(self.path.match(/(.*)\.[^.]+$/)[1])
    secondaryFiles:
      - ^.dict
      - .fai
    doc: expect the path to the fa file

  - id: reference_bwt
    type: File
    inputBinding:
      position: 4
      valueFrom: $(self.path.match(/(.*)\.[^.]+$/)[1])
    secondaryFiles:
      - ^.ann
      - ^.amb
      - ^.pac
      - ^.sa
      - ^.alt
    doc: expect the path to the bwt file

  - id: known-sites-snp
    type: File
    inputBinding:
      position: 5
    secondaryFiles:
      - .tbi
    doc: expect the path to the dbsnp vcf gz file

  - id: known-sites-indels
    type: File
    inputBinding:
      position: 6
    secondaryFiles:
      - .idx
    doc: expect the path to the indel vcf file

  - id: sample
    default: "SAMPLE"
    type: string
    inputBinding:
      position: 7
    doc:

  - id: platform
    default: "PLATFORM"
    type: string
    inputBinding:
      position: 8
    doc:

  - id: optical_dup_pix_dist
    default: 2500
    type: int
    inputBinding:
      position: 9
    doc: max offset between two duplicate clusters in order to consider them optical duplicates

outputs:
  - id: output
    type: File
    outputBinding:
      glob: recalibrated.bam
    secondaryFiles:
        - .bai

doc: |
  run sentieon pipeline from paired-fastq files to bam
