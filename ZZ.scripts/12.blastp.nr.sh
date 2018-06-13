#!/bin/bash
#SBATCH -D ./
#SBATCH -J BLASTp-fmt0
#SBATCH -o BLASTp-fmt0-%j.Log
#SBATCH -c 10
#SBATCH --mail-type=ALL
#SBATCH --mail-user=francois-olivier.gagnon-hebert.1@ulaval.ca
#SBATCH --time=15-00:00:00
#SBATCH --mem=100G

# LOADING THE MODULE
module load ncbiblast/2.6.0

# EXTRACTING THE PROTEINS THAT DID NOT BLAST ON UNIPROT-SWISSPROT
## Getting the names of the contigs that successfully blasted on uniprot-swissprot
awk '{print $1}' 10.functionalAnnotation/lda.augustus.uniprot-sprot.fmt6 | sort -n | uniq >10.functionalAnnotation/lda.augustus.BLASTp.hit.sp-unip.names

## Extracting the no-hit contigs
ZZ.scripts/utils/extract_fasta_except_names.py 09.augustus/lda.augustus.aa 10.functionalAnnotation/lda.augustus.BLASTp.hit.sp-unip.names 10.functionalAnnotation/lda.augustus.noHits.unip-sp.fasta

# RUNNING BLASTp WITH PARALLEL ON THE NO-HIT CONTIGS
for file in `ls -1 10.functionalAnnotation/*.fasta`; do
    cat $file | \
        parallel -j 10 --block 1K --recstart '>' \
        --pipe blastp \
        -query - \
        -db /biodata/blastdb/nr \
        -num_alignments 1 \
        -evalue 1e-30 \
        -outfmt 0 \
        -num_threads 10 > 10.functionalAnnotation/lda.augustus.nr.fmt0;
done

# CONVERTING THE BLASTp OUTPUT INTO A TABULATED FORMAT FOR DOWNSTREAM ANALYSES
ZZ.scripts/blast2id.fmt0.py 10.functionalAnnotation/lda.augustus.nr.fmt0 10.functionalAnnotation/lda.augustus.nr.tabResults.txt
