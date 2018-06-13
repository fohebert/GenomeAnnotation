#!/bin/bash
#SBATCH -D .
#SBATCH -J AUG-Rep
#SBATCH -o aug-Rep-%j.Log
#SBATCH -c 1
#SBATCH --mail-type=ALL
#SBATCH --mail-user=francois-olivier.gagnon-hebert.1@ulaval.ca
#SBATCH --mem=8G
#SBATCH --time=21-00:00:00

# RUNNING AUGUSTUS
/home/fogah/prg/augustus-3.2.3/bin/augustus 04.repeat.modeler.masker/RM.run.failed.august2017/ldj.contigs.simpleIDs.fasta.masked \
    --AUGUSTUS_CONFIG_PATH='/home/fogah/prg/augustus-3.2.3/config' \
    --extrinsicCfgFile='07.augustus/extrinsic.lda.cfg' \
    --progress=true \
    --species=lda \
    --gff3=on \
    --alternatives-from-evidence=false \
    --alternatives-from-sampling=false \
    --hintsfile='07.augustus/ldj.augustus.hintsFile.gff' > 07.augustus/2017.10.03/ldj.maskedGenome.augustusOut

# EXTRACTING CODING AND PROTEIN SEQUENCES FROM THE GENOME ANNOTATION FILE
/home/fogah/prg/augustus-3.2.3/scripts/getAnnoFasta.pl 07.augustus/ldj.lda-trained.augustusOut
