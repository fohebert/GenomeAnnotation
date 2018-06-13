#!/bin/bash
#SBATCH -J busco-ldj
#SBATCH -D ./
#SBATCH -o busco-ldj-%j.Log
#SBATCH -p rclevesq
#SBATCH -A rclevesq
#SBATCH -c 15
#SBATCH --mail-type=ALL
#SBATCH --mail-user=francois-olivier.gagnon-hebert.1@ulaval.ca
#SBATCH --time=10-00:00:00
#SBATCH --mem=80G

# LOADING SOME MODULES
module load bamtools/2.4.0 augustus/3.2.3

# DECLARING ENVIRONMENTAL VARIABLES REQUIRED BY AUGUSTUS
export PATH="/home/fogah/prg/augustus-3.2.3/bin/:$PATH"
export PATH="/home/fogah/prg/augustus-3.2.3/scripts/:$PATH"
export AUGUSTUS_CONFIG_PATH="/home/fogah/prg/augustus-3.2.3/config"
BUSCO='/home/fogah/prg/busco.v.3.0.1/scripts'

# RUNNING BUSCO ON THE GENOME
$BUSCO/run_BUSCO.py -m genome \
    -i 09.functional.annotation/final.genome.files/ldj.genome.v0.3.fasta \
    -o ldj.v0.3 \
    -l /home/fogah/prg/busco.v.3.0.1/arthropoda_odb9 \
    -f -c 15 \
    -sp lda
