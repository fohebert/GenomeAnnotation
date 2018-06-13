#!/bin/bash
#SBATCH -D ./
#SBATCH -J aug2gff
#SBATCH -o aug2gff-%j.Log
#SBATCH -p rclevesq
#SBATCH -A rclevesq
#SBATCH -c 1
#SBATCH --mail-type=ALL
#SBATCH --mail-user=francois-olivier.gagnon-hebert.1@ulaval.ca
#SBATCH --mem=5G
#SBATCH --time=10-00:00:00

ZZ.scripts/utils/augustus2gff3.functionalAnnotation.py 09.augustus/lda.augustus.withHints.gff 10.functionalAnnotation/lda.augustus.uniprot-sprot.fmt6 /home/fogah/00.raw.data/uniprot_sprot.dat 10.functionalAnnotation/lda.augustus.nr.tabResults.txt 10.functionalAnnotation/lda.genomeKEGG.out.all.hitsOnly.txt lda.genome.2018-05-08.gff3 10.functionalAnnotation/lda.genome.featureTable.2018-05-08.txt
