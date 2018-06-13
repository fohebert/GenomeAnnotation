#!/bin/bash
#SBATCH -D ./
#SBATCH -J CANU
#SBATCH -o CANU-%j.Log
#SBATCH -p rclevesq
#SBATCH -A rclevesq
#SBATCH -c 60
#SBATCH --mail-type=ALL
#SBATCH --mail-user=francois-olivier.gagnon-hebert.1@ulaval.ca
#SBATCH --time=21-00:00:00
#SBATCH --mem=800G

# GLOBAL VARIABLES
READS='/project/rclevesq/partage/luca/pacbio'
CANU='/home/fogah/prg/canu/Linux-amd64/bin'

# RUNNING THE PROGRAM
${CANU}/canu -p ldj \
    -d 02.canu/auto.2017-05-26 \
    genomeSize=1.5g \
    -pacbio-raw ${READS}/*.fastq.gz \
    usegrid=0 \
    -maxMemory=800 \
    -maxThreads=60
