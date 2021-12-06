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

baseCommand: [sentieon_dedup-recal.sh]

inputs:
  - id: input_bam
    type: File
    inputBinding:
      position: 1
    doc: input bam file, must be sorted and must have read groups

  - id: reference_fa
    type: File
    inputBinding:
      position: 2
      valueFrom: $(self.path.match(/(.*)\.[^.]+$/)[1])
    secondaryFiles:
      - ^.dict
      - .fai
    doc: expect the path to the fa file

  - id: known-sites-snp
    type: File
    inputBinding:
      position: 3
    secondaryFiles:
      - .tbi
    doc: expect the path to the dbsnp vcf gz file

  - id: known-sites-indels
    type: File
    inputBinding:
      position: 4
    secondaryFiles:
      - .idx
    doc: expect the path to the indel vcf file

  - id: optical_dup_pix_dist
    default: 2500
    type: int
    inputBinding:
      position: 5
    doc: max offset between two duplicate clusters in order to consider them optical duplicates

outputs:
  - id: recalibrated_bam
    type: File
    outputBinding:
      glob: recalibrated.bam
    secondaryFiles:
        - .bai

doc: |
  run sentieon steps to remove duplicates and apply base recalibration to input bam file
