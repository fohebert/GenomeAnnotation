#!/bin/bash
#SBATCH -D ./
#SBATCH -J aug2gff
#SBATCH -o aug2gff-%j.Log
#SBATCH -p rclevesq
#SBATCH -A rclevesq
#SBATCH -c 1
#SBATCH --mail-type=ALL
#SBATCH --mail-user=francois-olivier.gagnon-hebert.1@ulaval.ca
#SBATCH --mem=1G
#SBATCH --time=10-00:00:00

ZZ.scripts/utils/augustus2gff3.functionalAnnotation.py 07.augustus/ldj.lda-trained.augustusOut.2017-10-03 08.blastp.results/ldj.augustus.uniprot-sprot.2017-12-05.fmt6 /home/fogah/00.raw.data/uniprot_sprot.dat 08.blastp.results/ldj.aa.nr.tabResults.2017-12-05.txt 09.functional.annotation/ldj.genomeKEGG.out.all.hitsOnly.txt 09.functional.annotation/ldj.genome.2018-05-08.gff3 09.functional.annotation/ldj.genome.featureTable.2018-05-08.txt
