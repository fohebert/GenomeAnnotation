#!/bin/bash
#SBATCH -D .
#SBATCH -J arrow-ldj
#SBATCH -o arrow-ldj-%j.log
#SBATCH -A rclevesq
#SBATCH -p rclevesq
#SBATCH -c 40
#SBATCH --mem=100G
#SBATCH --time=6-00:00:00

# ENVIRONMENTAL VARIABLES
## Using SMRT-links to run ARROW
SMRT='/home/fogah/prg/smrtlink/smrtcmds/bin'

# LOADING MODULES
## Required to sort the resulting BAM file (from BLASR)
module load samtools/1.8

# INCREASING OPENABLE FILE LIMIT
ulimit -n 655350

# RUNNING BLASR TO ALIGN THE READS ONTO THE LDA GENOME v.0.3
$SMRT/pbalign --nproc 40 \
    --algorithmOptions="--bestn 10 --minMatch 12 --maxMatch 30 --minSubreadLength 100 --minAlnLength 100 --minPctSimilarity 80 --minPctAccuracy 80 --hitPolicy randombest --randomSeed 1" \
    ./01.raw.data/bam_reads/*.bam ldj.genome.v0.3.fasta ldj.v0.3.blasr.sorted.bam 

# RUNNING SAMTOOLS TO PREPARE THE FILE FOR ARROW
# samtools sort -@ 10 -o lda.v0.3.blasr.sorted.bam -O bam lda.v0.3.blasr.bam
# samtools faidx lda.genome.v0.3.fasta
# pbindex lda.v0.3.blasr.sorted.bam

# RUNNING ARROW
$SMRT/arrow ldj.v0.3.blasr.sorted.bam -j 40 --referenceFilename ldj.genome.v0.3.fasta \
    -o ldj.arrow.fasta \
    -o ldj.arrow.fastq \
    -o ldj.arrow.gff
