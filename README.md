# Genome Annotation Pipeline
Annotation pipeline developed for large insect genomes (e.g. Lymantria dispar spp.)

## Disclaimer

:point_right: **Do not use this pipeline 'as is'** | **Optimization required** :point_left:

This pipeline was developped and optimized to work on a specific cluster using the [Slurm Workload Manager](https://slurm.schedmd.com/). Codes and scripts included in this pipeline are thus "platform-specific" and must be adjusted according to your needs, dataset, available computer resources, and workload manager.

It is meant as a **reference** to help guide people who would like to have an example of how to do perform the task of assembling and annotating a large and highly repeated genome (e.g. insects, plants), and what program to use in what order and which software parameters to focus on.

## Overview

This pipeline takes adavantage of multiple open source softwares, programs and utility scripts to predict gene features, annotate them with gene product names, GO terms and KEGG KO numbers. It returns a complete genome annotation in the GFF3 format and also produces a 'Gene Feature Table' with the complete annotation info per gene, including genomic contig in which the gene is found, and all the little pieces of information about their respective structure and annotation.

## Prerequisites

- `Python 2.7` | `BioPython`
- `blastplus` (available on NCBI's [webpage](https://blast.ncbi.nlm.nih.gov/Blast.cgi?CMD=Web&PAGE_TYPE=BlastDocs&DOC_TYPE=Download))
- `UniprotKB-SwissProt` and `nr` blast databases
- `gnu parallel`
- `RepeatMasker` and `RepeatModeler` (available [here](http://repeatmasker.org/))
- `exonerate` (available [here](https://www.ebi.ac.uk/about/vertebrate-genomics/software/exonerate))
- `samtools` (available [here](http://www.htslib.org/))
- `genemark` (available [here](http://exon.gatech.edu/GeneMark/))
- `scipio` (available [here](https://webscipio.org/webscipio/download_scipio))
- `EVidenceModeler` (available [here](http://evidencemodeler.github.io/))
- `PASA` (available [here](https://github.com/PASApipeline/PASApipeline/wiki))
- `augustus` (available [here](http://bioinf.uni-greifswald.de/augustus/))

## Description

The overall script `runAll.sh`
