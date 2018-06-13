#!/bin/bash
#SBATCH -J opt-aug
#SBATCH -D .
#SBATCH --mem=1G
#SBATCH -p rclevesq
#SBATCH -c 10
#SBATCH -o opt-aug-%j.Log
#SBATCh --time=36:00:00

/home/fogah/prg/augustus-3.2.3/scripts/optimize_augustus.pl --species=lda --metapars='/home/fogah/prg/augustus-3.2.3/config/species/generic/generic_metapars.cfg' --AUGUSTUS_CONFIG_PATH='/home/fogah/prg/augustus-3.2.3/config/' 08.augustusTraining/lda.highConfidence.genes.strict3sources.FILTERED.gb

