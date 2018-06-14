# Genome Annotation Pipeline
Annotation pipeline developed for large insect genomes (e.g. Lymantria dispar spp.)

## Disclaimer

:point_right: **Do not use this pipeline 'as is'** | **Optimization required** :point_left:

This pipeline was developped and optimized to work on a specific cluster using the [Slurm Workload Manager](https://slurm.schedmd.com/). Codes and scripts included in this pipeline are thus "platform-specific" and must be adjusted according to your needs, dataset, available computer resources, and workload manager.

It is meant as a **reference** to help guide people who would like to have an example of how to perform the task of assembling and annotating a large and highly repeated genome (e.g. insects, plants), and what program to use in what order and which software parameters to focus on.

## Overview

This pipeline takes adavantage of multiple open source softwares, programs and utility scripts to predict gene features, annotate them with gene product names, GO terms and KEGG KO numbers. It returns a complete genome annotation in GFF3 format and also produces a 'Gene Feature Table' with the complete annotation info per gene, including genomic contig in which the gene is found, and all the little pieces of information about their respective structure (3'UTR, 5'UTR, exons/introns, start/stop codon, cds) and annotation (gene product, transcript ID, GO terms, KO numbers).

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

The global script called `runAll.sh` in the main working directory details every step of the pipeline, with embeded explanations as to which input(s) to use, what are the usefull outputs, which file to place where in the general pipeline directory structure and how to run the programs. **IT IS NOT MEANT TO BE RAN AS IS**: it needs to be adjusted to your input files and dataset with the corresponding file names. By changing file names, specific locations of the installed programs/softwares and computer resources (which really depend on the size of the initial raw sequencing data and expected genome size), it is possible to make it run as a whole, but I do not recommend it. Most of the steps in this pipeline will probably need further adjustments and "fine-tuning", depending on the type of data being processed. This is not an automated annotation pipeline fixed for a certain type of organism. It can be used on basically any organism because every step is independant and can be adjusted as needed. It is thus very useful in being versataile, but it requires a little bit of coding and adjustments.

I recommend dividing each step of the pipeline (well identified and numbered in the `runAll.sh` script) into an independent script that can be ran on its own with appropriate Grid management script/information (number of CPUs, memory, log files, what queue to use, etc.). This allows a better control over each step and parameters can be adjusted to fit your needs, output and input files can be inspected, moved to different directories, checked and modified as needed. 

There is also an example in the directory called '[ZZ.example.runTrainedVersion](https://github.com/fohebert/GenomeAnnotation/tree/master/ZZ.scripts/ZZ.example.runTrainedVersion)'. This example shows **how to use the pipeline if AUGUSTUS has been trained with a custom genome** before. Let's say you've generated one independent script for each step in the `runAll.sh` main script and you've trained AUGUSTUS and predicted genes in a given genome. Now, you want to annotate another, closely related, genome that just got sequenced. For instance, AUGUSTUS has been trained with a frog genome and you want to annotate a new frog genome of the same taxonomic family using the frog-trained version of AUGUSTUS. Well, just run the scripts according to their respective number: each script run a step of the pipeline. Just modify the file names directly in the scripts, if needed change some parameters, and then submit the script to the cluster or run it locally on a (powerful) machine.
