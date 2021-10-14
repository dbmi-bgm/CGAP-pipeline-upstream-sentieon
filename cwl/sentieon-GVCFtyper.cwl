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

baseCommand: [sentieon, driver]

inputs:
  - id: input_gvcfs
    type:
      -
        items: File
        type: array
        inputBinding:
          prefix: -v
    inputBinding:
      position: 3
    secondaryFiles:
      - .tbi
    doc: input gvcf files

  - id: reference
    type: File
    inputBinding:
      position: 1
      prefix: -r
    secondaryFiles:
      - ^.dict
      - .fai
    doc: expect the path to the fa file

  - id: algo
    type: string
    default: "GVCFtyper"
    inputBinding:
      position: 2
      prefix: --algo
    doc: algorithm used

  - id: outputfile
    default: 'out.vcf.gz'
    type: string
    inputBinding:
      position: 4
    doc: output file name

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.outputfile)
    secondaryFiles:
      - .tbi

doc: |
  run sentieon GVCFtyper to jointly call multiple gvcf files
