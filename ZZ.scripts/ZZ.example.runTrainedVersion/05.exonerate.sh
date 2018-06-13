#!/bin/bash
#SBATCH -D ./
#SBATCH -J exonerate
#SBATCH -o exo-%j.Log
#SBATCH -p rclevesq
#SBATCH -A rclevesq
#SBATCH -c 64
#SBATCH --mail-type=ALL
#SBATCH --mail-user=francois-olivier.gagnon-hebert.1@ulaval.ca
#SBATCH --time=21-00:00:00
#SBATCH --mem=850G

# LOADING TH EXONERATE MODULE
module load exonerate/2.4.0

# ENVIRONMENT VARIABLES
AUGUSTUS='/project/rclevesq/partage/sw/augustus-3.2.2/'

# RUNNING THE PROGRAM USING PARALLEL
parallel -j 64 'exonerate --model protein2genome \
    --score 500 \
    --geneseed 250 \
    --seedrepeat 4 \
    --fsmmemory 1024 \
    --refine region \
    --showalignment no \
    --percent 50 \
    --bestn 5 \
    --showsugar no \
    --showvulgar no \
    --showtargetgff yes \
    --ryo "HIT %S %pi %ps %V/n" \
    -q {} \
    -t 05.exonerate/ldj.contigs.simpleIDs.fasta.masked > 05.exonerate/raw.exonerate.split.results/{/.}.exonerate' ::: 01.raw.data/metazoa_split/*fasta

# CONCATENATING EXONERATE OUTPUT FILES INTO 1 SINGLE FILE
cat 05.exonerate/raw.exonerate.split.results/*exonerate* >metazoa.onLDJ.exonerateALL

# CONVERTING CONCATENATED RESULTS INTO AUGUSTUS HINTS FILE
$AUGUSTUS/scripts/exonerate2hints.pl --in='05.exonerate/metazoa.onLDJ.exonerateALL' \
    --out= '05.exonerate/metazoa.onLDJ.exonerate.hintsFile.gff'
