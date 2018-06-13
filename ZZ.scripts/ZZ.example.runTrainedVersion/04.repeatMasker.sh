#!/bin/bash
#SBATCH -J repeatMa
#SBATCH -D ./
#SBATCH -o repeatMa-%j.Log
#SBATCH -p rclevesq
#SBATCH -A rclevesq
#SABTCH -c 40
#SBATCH --mail-type=ALL
#SBATCH --mail-user=francois-olivier.gagnon-hebert.1@ulaval.ca
#SBATCH --time=21-00:00:00
#SBATCH --mem=100G

# LOADING THE MODULES
module load RepeatMasker/4.0.6 RepeatModeler/1.0.8

# COMBINING REPEAT DATABASES
## Concatenating the classic 'repbase' + LDJ-specific repeat database
# cat 04.repeat.modeler.masker/consensi.fa 00.archive/data-giri.txt >04.repeat.modeler.masker/db.repeats.complete.fa

# RUNNING REPEATMASKER ON THE GENOME USING THE COMBINED DATABASE
## Hard mask
RepeatMasker -e ncbi -s -pa 40 -lib 04.repeat.modeler.masker/db.repeats.complete.fa -dir 04.repeat.modeler.masker 02.canu/ldj.contigs.simpleIDs.fasta
