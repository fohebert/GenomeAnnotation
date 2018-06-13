#!/bin/bash
#SBATCH -D ./
#SBATCH -J BLASTp-fmt6
#SBATCH -o BLASTp-fmt6-%j.Log
#SBATCH -c 10
#SBATCH --mail-type=ALL
#SBATCH --mail-user=francois-olivier.gagnon-hebert.1@ulaval.ca
#SBATCH --time=15-00:00:00
#SBATCH --mem=1G

# LOADING THE MODULE
module load ncbiblast/2.6.0

# RUNNING BLASTp WITH PARALLEL
for file in `ls -1 09.augustus/*.aa`; do
    cat $file | \
        parallel -j 10 --block 1K --recstart '>' \
        --pipe blastp \
        -query - \
        -db /biodata/blastdb/uniprot_sprot \
        -num_alignments 1 \
        -evalue 1e-30 \
        -outfmt 6 \
        -num_threads 10 > 10.functionalAnnotation/lda.augustus.uniprot-sprot.fmt6;
done
