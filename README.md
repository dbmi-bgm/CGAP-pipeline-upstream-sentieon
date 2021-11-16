<img src="https://github.com/dbmi-bgm/cgap-pipeline/blob/master/docs/images/cgap_logo.png" width="200" align="right">

# CGAP Upstream Pipeline (and Joint Calling) - Sentieon

This repository contains components for the CGAP upstream pipeline and the joint calling pipeline using Setieon:

  * CWL workflows
  * CGAP Portal Workflows and MetaWorkflows objects
  * ECR (Docker) source files, which allow for creation of public Docker images (using `docker build`) or private dynamically-generated ECR images (using [*cgap pipeline utils*](https://github.com/dbmi-bgm/cgap-pipeline-utils/) `deploy_pipeline`)

The upstream pipeline can process paired `FASTQ` files up to analysis ready `bam` files.
The joint calling pipeline can jointly call multiple `g.vcf` files and produces a `vcf` file as output.
For more details check the [*documentation*](https://cgap-pipeline-master.readthedocs.io/en/latest/Pipelines/Upstream/upstream_sentieon/index-upstream_sentieon.html "upstream pipeline Sentieon").

### Version Updates

#### v1
* Initial release for joint calling pipeline
* Changes in repo structure to allow for compatibility with new pipeline organization
