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

baseCommand: [sentieon_bwa-mem.sh]

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

outputs:
  - id: raw_bam
    type: File
    outputBinding:
      glob: raw.bam

doc: |
  run sentieon bwa mem on paired-fastq files
