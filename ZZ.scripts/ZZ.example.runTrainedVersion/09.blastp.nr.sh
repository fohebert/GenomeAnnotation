#!/bin/bash
#SBATCH -D ./
#SBATCH -J BLASTp
#SBATCH -o BLASTp-%j.Log
#SBATCH -p ibismini
#SBATCH -A ibismini
#SBATCH -c 10
#SBATCH --mail-type=ALL
#SBATCH --mail-user=francois-olivier.gagnon-hebert.1@ulaval.ca
#SBATCH --time=21-00:00:00
#SBATCH --mem=10G

# LOADING THE MODULE
module load ncbiblast/2.6.0

# GETTING THE NAMES OF THE CONTIGS THAT DID BLAST ON SWISSPROT
awk '{print $1}' 08.blastp.results/ldj.augustus.uniprot-sprot.2017-12-05.fmt6 | sort -n | uniq > 08.blastp.results/ldj.aa.BLASTp.hit.sp-unip.names.2017-12-05

# EXTRACTING SEQUENCES OF THE CONTIGS THAT DID NOT BLAST ON SWISSPROT
ZZ.scripts/utils/extract_fasta_except_names.py 07.augustus/ldj.lda-trained.augustusOut.2017-10-03.aa \
    08.blastp.results/ldj.aa.BLASTp.hit.sp-unip.names.2017-12-05 \
    08.blastp.results/ldj.aa.noHits.unip-sp.fasta

# BLASTp ON 'nr' WITH THE NO-BLAST ON SWISSPROT
for file in `ls -1 08.blastp.results/*.fasta`; do
    cat $file | \
        parallel -j 10 --block 1K --recstart '>' \
        --pipe blastp \
        -query - \
        -db /biodata/blastdb/nr \
        -num_alignments 1 \
        -evalue 1e-30 \
        -outfmt 0 \
        -num_threads 10 > 08.blastp.results/ldj.aa.nr.2017-12-05.fmt0;
done

# CONVERTING THE BLASTp OUTPUT INTO A TABULATED FORMAT FOR DOWNSTREAM ANALYSES
ZZ.scripts/utils/blast2id.fmt0.py 08.blastp.results/ldj.aa.nr.2017-12-05.fmt0 \
    08.blastp.results/ldj.aa.nr.tabResults.2017-12-05.txt
