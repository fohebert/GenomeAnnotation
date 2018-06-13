#!/bin/bash
#SBATCH -J pasa
#SBATCH -D ./
#SBATCH -o pasa-%j.Log
#SBATCH -p rclevesq
#SBATCH -A rclevesq
#SBATCH -c 40
#SBATCH --mail-type=ALL
#SBATCH --mail-user=francois-olivier.gagnon-hebert.1@ulaval.ca
#SBATCH --time=21-00:00:00
#SBATCH --mem=500G

# ENVIRONMENT VARIABLE
PASA='/project/rclevesq/partage/sw/pasa/2.1.0/'

# LAUNCHING MYSQL (required by PASA)
/home/prg/mysql/start.sh

# OPTIONAL: verify if MySQL can be opened successfully. Just open and quit.
#/home/prg/mysql/open.sh 

# RUNNING PASA
$PASA/scripts/Launch_PASA_pipeline.pl -c 06.pasa/pasa.alignAssembly_config.txt -R -C \
    -g 04.repeat.modeler.masker/RM.run.failed.august2017/ldj.contigs.simpleIDs.fasta.masked \
    -t 01.raw.data/lda.transcriptome.fasta \
    --ALIGNER blat \
    --CPU 40

# MOVING OUTPUT FILES INTO APPROPRIATE DIRECTORY
mv alignment.validations.output 06.pasa/
mv 11.ooc 06.pasa/
mv blat* 06.pasa/
mv pasa_* 06.pasa/

# PRODUCING HINTS FILE FOR AUGUSTUS
ZZ.scripts/utils/gff2hints.pl --in='06.pasa/pasa_ldj.pasa_assemblies.gff3' \
    --out='06.pasa/protoHintsFile.transcriptAlignments.gff'

## Slight modifications to the hints file in order to get the proper
## format for AUGUSTUS
 sed 's/\tep\t/\texonpart\t/g' 06.pasa/protoHintsFile.transcriptAlignments.gff | \
     sed 's/\tip\t/\tintronpart\t/g' > 07.augustus/ldj.transcript.alignments.hints.gff
