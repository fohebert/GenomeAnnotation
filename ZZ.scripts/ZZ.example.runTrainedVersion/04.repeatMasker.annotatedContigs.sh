#!/bin/bash
#SBATCH -D ./
#SBATCH -J LDJ-RM
#SBATCH -o LDJ-RM-%j.Log
#SBATCH -p rclevesq
#SBATCH -A rclevesq
#SBATCH -c 30
#SBATCH --mail-type=ALL
#SBATCH --mail-user=francois-olivier.gagnon-hebert.1@ulaval.ca
#SBATCH --time=21-00:00:00
#SBATCH --mem=20g

# LOADING THE PROGRAM
module load RepeatMasker/4.0.6 RepeatModeler/1.0.8

# RUNNING THE PROGAM
RepeatMasker -e ncbi -s -pa 30 -lib 04.repeat.modeler.masker/db.repeats.complete.fa \
    -dir 04.repeat.modeler.masker \
    09.functional.annotation/final.genome.files/ldj.annotatedContigs.fasta
