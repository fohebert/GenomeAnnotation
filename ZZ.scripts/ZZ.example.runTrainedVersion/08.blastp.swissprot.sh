#!/bin/bash
#SBATCH -D ./
#SBATCH -J BLASTp-SP
#SBATCH -o BLASTp-SP-%j.Log
#SBATCH -p ibismini
#SBATCH -A ibismini
#SBATCH -c 10
#SBATCH --mail-type=ALL
#SBATCH --mail-user=francois-olivier.gagnon-hebert.1@ulaval.ca
#SBATCH --time=21-00:00:00
#SBATCH --mem=100G

# LOADING THE MODULE
module load ncbiblast/2.6.0

# RUNNING BLASTp WITH PARALLEL
for file in `ls -1 07.augustus/*.aa`; do
    cat $file | \
        parallel -j 10 --block 1K --recstart '>' \
        --pipe blastp \
        -query - \
        -db /biodata/blastdb/uniprot_sprot \
        -num_alignments 1 \
        -evalue 1e-30 \
        -outfmt 6 \
        -num_threads 10 > 08.blastp.results/ldj.augustus.uniprot-sprot.2017-12-05.fmt6;
done
