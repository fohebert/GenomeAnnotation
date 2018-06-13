# Genome Annotation Pipeline
Annotation pipeline developed for large insect genomes (e.g. Lymantria dispar spp.)

## Overview

This pipeline takes adavantage of multiple open source softwares, programs and utility scripts to predict gene features, annotated them with gene product names, GO terms and KEGG KO numbers. It returns a complete genome annotation in the GFF3 format and also produces a 'Gene Feature Table' with the complete annotation info per gene, including genomic contig in which the gene is found, and all the little pieces of information about their respective structure and annotation.

## Prerequisites

- `Python 2.7`
- `blastplus` (available on NCBI's [webpage](https://blast.ncbi.nlm.nih.gov/Blast.cgi?CMD=Web&PAGE_TYPE=BlastDocs&DOC_TYPE=Download))
- `UniprotKB-SwissProt` and `nr` blast databases
- `gnu parallel`
- `RepeatMasker` and `RepeatModeler` (available [here](http://repeatmasker.org/))
- `exonerate` (available [here](https://www.ebi.ac.uk/about/vertebrate-genomics/software/exonerate))
- `samtools` (available [here](http://www.htslib.org/))
- `genemark` (available [here](http://exon.gatech.edu/GeneMark/))
- `scipio` (available [here](https://webscipio.org/webscipio/download_scipio))
- `EVidenceModeler` (available [here](http://evidencemodeler.github.io/))
