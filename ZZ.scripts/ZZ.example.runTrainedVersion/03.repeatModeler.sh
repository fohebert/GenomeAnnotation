#!/bin/bash
#SBATCH -D .
#SBATCH -J repeatMM
#SBATCH -o repeatMM-%j.Log
#SBATCH -p rclevesq
#SBATCH -A rclevesq
#SBATCH -c 10
#SBATCH --mail-type=ALL
#SBATCH --mail-user=francois-olivier.gagnon-hebert.1@ulaval.ca
#SBATCH --time=48:00:00
#SBATCH --mem=5G

# LOADING SOME MODULES
module load RepeatMasker/4.0.6 RepeatModeler/1.0.8 

##############################
# RUNNING REPEAT MODELER #
##############################

# Building a database for RepeatModeler (FASTA format)
BuildDatabase -name 04.repeat.modeler.masker/ldj-db -engine ncbi 02.canu/ldj.contigs.simpleIDs.fasta

# Creating an ab initio database to be used with RepeatModeler
RepeatModeler -database 04.repeat.modeler.masker/ldj-db -engine ncbi 

# Moving the result files in the appropriate directory
for dir in `ls -1 RM_*`; do mv ${dir}/* 04.repeat.modeler.masker; done
for dir in `ls -1 RM_*`; do rm rf ${dir}; done # Deleting the RM output directory
