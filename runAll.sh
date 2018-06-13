#!/bin/bash

# --------------------------------------- #
# --------------------------------------- #
#     FULL GENOME ANNOTATION PIPELINE     #
# INSPIRED FROM THE WORK OF E. NORMANDEAU #
#           v.1.0 - June 2018             #
# --------------------------------------- #
# --------------------------------------- #

#####################
## LOADING MODULES ##
#####################
module load RepeatModeler/1.0.8 RepeatMasker/4.0.6
module load exonerate/2.4.0
module load samtools/1.8

##########################
## PROGRAMS TO BE USED  ##
##########################
GENEMARK='/project/rclevesq/partage/sw/genemark-ES/gmes_petap.pl'
SCIPIO='/project/rclevesq/partage/sw/scipio-1.4'
EVM='/project/rclevesq/partage/sw/EVidenceModeler-1.1.1'
PASA='/project/rclevesq/partage/sw/pasa/2.1.0/'
AUGUSTUS='/project/rclevesq/partage/sw/augustus-3.2.2/'

###############################
## (1) REPEAT MODELER/MASKER ##
###############################

# Building a database for RepeatModeler (FASTA format)
BuildDatabase -name 02.repeat.modeler.masker/lda-db -engine ncbi 01.raw.data/lda.fasta

# Creating an ab initio database to be used with RepeatModeler
RepeatModeler -database 02.repeat.modeler.masker/lda-db -engine ncbi -pa 32 -dir 02.repeat.modeler.masker

# Move result file from RepeatModeler into appropriate directory
## *** MANUAL OPERATION TO BE PERFORMED *** ##
mv RM_XXX.XXX/* 02.repeat.modeler.masker
rm -rf RM_XXX.XXX

# Combine specie-specific repeat database with public repeat database (Repbase)
## MANUAL OPERATION TO PERFORM
cat 02.repeat.modeler.masker/consensi.fa.classified 00.archive/data-giri.txt >02.repeat.modeler.masker/db.repeats.complete.fa

# Use Repeat Masker to (hard)-mask the genome based on the resulting concatenated database.
RepeatMasker -e ncbi -s -pa 20 -lib 02.repeat.modeler.masker/repeats.complete.fa \
    -dir 02.repeat.modeler.masker \
    00.raw.data/lda.fasta
# NB: the sequences in the output file called 'lda.fasta.masked' might need to be renamed because they
# will have long names (extensive description of each sequence). The rest of the pipleine will go smoother
# with short sequence names in the genome FASTA file.

##############################################
## (2) GENEMARK - AB INITIO GENE PREDICTION ##
##############################################

# In this step, we use Genemark to predict gene sequences
# in the masked genome FASTA file.

# NB: make sure that Genemark is installed in a known location on the computer
# because it requires the 'gm_key' file and that file has to be copied that way:
# cp GENEMARK_DIR/gm_key ~/.gm_key

# Using genemark to predict genes ab initio
cd 03.genemark
$GENEMARK --sequence ../02.repeat.modeler.masker/lda.fasta.masked --ES --v --cores 25

# Converting the genemark output from GTF to GFF3
cd ..
ZZ.scripts/utils/genemark_gtf2gff3 03.genemark/genemark.gtf > 03.genemark/lda.maskedGenome.genemarkOut.gff3

###########################################################
## (3) SciPio - SWISSPROT PROTEIN ALIGNMENT ONTO GENOME  ##
###########################################################

# Using SciPio to align swissprot onto genome
$SCIPIO/scipio.1.4.1.pl 02.repeat.modeler.masker/lda.fasta.masked 01.raw.data/swissprot_reformattedNames.fasta > 04.scipio/scipio.out

# SciPio first produces a BLAT .PSL file that it then uses to create the output file
# So here, we simply move the .PSL file generated with BLAT by SciPio in the Scipio output directory
mv Scipio*_blat.psl 04.scipio

# Converting the YAML output file into SciPio-specific GFF3 format
cat 04.scipio/scipio.out | $SCIPIO/yaml2gff.1.4.pl > 04.scipio/scipio.out.scipioGFF3

# Converting the SciPio-specific GFF3 format into standard GFF3 format
ZZ.scripts/convert_scipio_gff_to_gff3.py -i 04.scipio/scipio.out.scipioGFF3 -o lda.scipioUniprot-SP.out.gff3

##############################################################
## (4) EXONERATE - SWISSPROT PROTEIN ALIGNMENT ONTO GENOME  ##
##############################################################

# Running EXONERATE with split swissprot FASTA files
# Using 'parallel' to run the job faster
parallel -j 64 'exonerate --model protein2genome \
    --score 500 \
    --geneseed 250 \
    --seedrepeat 4 \
    --fsmmemory 1024 \
    --refine region \
    --showalignment no \
    --percent 50 \
    --bestn 5 \
    --showvulgar no \
    --showtargetgff yes \
    --ryo "HIT %S %pi %ps %V\n" \
    -q {} \
    -t 02.repeat.modeler.masker/lda.fasta.masked > 05.exonerate/{/.}.exonerate' ::: 01.raw.data/metazoa_split/*fasta*

# Exonerate generated several output files, we need to place them into
# a separate directory for ease of viewing and for a cleaner directory
mkdir 05.exonerate/raw.exonerate.output
mv 05.exonerate/*.exonerate 05.exonerate/raw.exonerate.output

# Concatenating all output files into 1 single out file
cat 05.exonerate/raw.exonerate.output/*.exonerate > 05.exonerate/metazoa.onLda.exonerateAll

# Converting the concatenated output file into GFF3 format
# We use here the conversion script from EVidence Modeler's utility script
$EVM/EvmUtils/exonerate_gff_to_alignment_gff3.pl 05.exonerate/metazoa.onLda.exonerateAll >05.exonerate/metazoa.onLda.exonerate.gff3

# The GFF3 file produced up there might be useful to select genes that
# can then be used to train AUGUSTUS with a new species. However, the
# raw concatenated output from EXONERATE can be converted into a hints
# file that serves as input for AUGUSTUS. That's what we do here, i.e.
# conversion of raw EXONERATE output file into hints file for AUGUSTUS.
$AUGUSTUS/scripts/exonerate2hints.pl --in='05.exonerate/metazoa.onLda.exonerateAll' \
    --out='09.augustus/metazoa.onLDA.PacBio.exonerate.hintsfile.gff'

########################################################
## (5) PASA - GENE STRUCTURE ANNOTATION AND ANALYSIS  ##
########################################################

# Launching MYSQL (required by PASA)
mysqld &

# Launching PASA
cd 06.pasa
$PASA/Launch_PASA_pipeline.pl -c pasa.alignAssembly_config.txt -R -C \
    -g 02.repeat.modeler.masker/lda.fasta.masked \
    -t 01.raw.data/lda.transcriptome.fasta \
    --ALIGNERS blat \
    --CPU 40

# Going back to general working directory
cd ..

# Converting valid PASA alignments into hints file for AUGUSTUS
ZZ.scripts/gff2hints.pl --in='06.pasa/pasa_lda.pasa_assemblies.gff3' \
    --out='06.pasa/protoHintsFiles.transcriptAlignments.gff'

# Changing the name of the features in the GFF3 file for the exact
# strings required by AUGUSTUS in the hints file.
sed 's/\tep\t/\texonpart\th/g' 06.pasa/protoHintsFiles.transcriptAlignments.gff | \
    sed 's/\tip\t/\tintronpart\t/g' > 09.augustus/transcript.alignments.hints.gff

###########################
## (6) EVIDENCE MODELER  ##
###########################

# Using EVM to produce a combined GFF3 file using evidence 
# from all sources of information produced in steps 1 to 4.

## Merging results from the swissprot alignments (SciPio + EXONERATE)
cat 04.scipio/lda.scipioUniprot-SP.out.gff3 05.exonerate/metazoa.onLda.exonerate.gff3 >07.EVidenceModeler/protein.alignments.gff3

# Creating EVM partitions
$EVM/partition_EVM_intputs.pl --genome 02.repeat.modeler.masker/lda.fasta.masked \
        --gene_predictions 03.genemark/lda.maskedGenome.genemarkOut.gff3 \
        --protein_alignments 07.EVidenceModeler/protein.alignments.gff3 \
        --transcript_alignments 06.pasa/pasa_lda.pasa_assemblies.gff3 \
        --segmentSize 100000 \
        --overlapSize 10000 \
        --partition_listing partitions_list.out

# Copying inptut files in the EVM directory so that everything is contained in this
# directory (otherwise, I think EVM bugs)
cp 03.genemark/lda.maskedGenome.genemarkOut.gff3 07.EVidenceModeler
cp 06.pasa/pasa_lda.pasa_assemblies.gff3 07.EVidenceModeler

# Moving to EVM working directory
cd 07.EVidenceModeler

# Generating EVM command set
$EVM/write_EVM_commands.pl --genome ../02.repeat.modeler.masker/lda.fasta.masked \
    --weights evidence_weight.tsv \
    --gene_predictions lda.maskedGenome.genemarkOut.gff3 \
    --protein_alignments protein.alignments.gff3 \
    --transcript_alignments pasa_lda.pasa_assemblies.gff3 \
    --output_file_name evm.out \
    --partitions partitions_list.out > commands.list

# Running the commands (linear mode, not parallel)
$EVM/execute_EVM_commands.pl commands.list | tee run.log

# Combining results of all partitions
$EVM/recombine_EVM_partial_outputs.pl --partitions partitions_list.out --output_file_name evm.out

# Converting the outputs to GFF3 standard format
$EVM/convert_EVM_outputs_to_GFF3.pl --partitions partitions_list.out \
    --output_file_name evm.out \
    --genome 02.repeat.modeler.masker/lda.fasta.masked

# Combining all of the GFF3 files into one single output file (GFF3 format)
find . -regex ".*evm.out.gff3" -exec cat {} \; >EVM.all.gff3

# Cleaning and going back to general working directory
mkdir partitions
mv tig* partitions
cd ..

###################
## (7) AUGUSTUS  ##
###################

## 7.1. TRAINING AUGUSTUS ##
# ------------------------ #

# PREPARING THE INPUT FILES FOR TRAINING
# --------------------------------------
## Getting all of the sources of evidence for each gene feature
ZZ.scripts/utils/getting.sourcesOFevidence.py 07.EVidenceModeler/partitions >07.EVidenceModeler/lda.pacbio.highConfidence.genes.tsv

## Extracting only the high confidence genes from the overall GFF3 from EVM
ZZ.scripts/utils/parsingOut.highConfidenceGenes.fromGFF.py 07.EVidenceModeler/EVM.all.gff3 07.EVidenceModeler/lda.pacbio.highConfidence.genes.tsv 08.augustusTraining/lda.highConfidence.genes.strict3sources.GFF3

## Converting high confidence GFF3 file into GENBANK format
$AUGUSTUS/scripts/gff2gbSmallDNA.pl 08.augustusTraining/lda.highConfidence.genes.strict3sources.GFF3 01.raw.data/lda.unmasked.fasta 700 08.augustusTraining/lda.highConfidence.genes.strict3sources.gb

## Randomly split the annotated sequences into a training and a test set. 100 sequences being randomly chosen.
$AUGUSTUS/scripts/randomSplit.pl 08.augustusTraining/lda.highConfidence.genes.strict3sources.raw.gb 100

# CREATING FILES FOR A NEW TRAINING
# ---------------------------------
cd 08.augustusTraining
$AUGUSTUS/scripts/new_species.pl --species=lda --AUGUSTUS_CONFIG_PATH='/project/rclevesq/partage/sw/augustus-3.2.2/config'

# TRAINING AUGUSTUS FOR THE SPECIES 'LDA' using the training set produced above.
# ------------------------------------------------------------------------------
## First off, training:
$AUGUSTUS/bin/etraining --species=lda lda.highConfidence.genes.strict3sources.raw.gb 2> train.err

## Secondly, listing all of the genes for which the program returned an error
cat train.err | perls -pe 's/.*in sequence (\S+): .*/$1/' > badgenes.strict3sources.raw.lst

## Thirdly, discarding those problematic genes from the dataset
$AUGUSTUS/scripts/filterGenes.pl badgenes.strict3sources.raw.lst lda.highConfidence.genes.strict3sources.raw.gb >lda.highConfidence.genes.strict3sources.filtered.gb

## Fourthly, train AUGUSTUS again, this time using the filtered set.
$AUGUSTUS/bin/etraining --species=lda lda.highConfidence.genes.strict3sources.filtered.gb

# FIRST GENE PREDICTION USING A FILTERED TEST SET
# -----------------------------------------------
## Split the filtered set of genes and obtain 100 random sequences to perform the accuracy test
$AUGUSTUS/scripts/randomSplit.pl lda.highConfidence.genes.strict3sources.filtered.gb 100

## Performing the actual ab initio prediction with the test set
$AUGUSTUS/bin/augustus --species=lda lda.highConfidence.genes.strict3sources.filtered.gb.test | tee firstTest.out

# LOOKING AT THE RESULT TO SEE THE ACCURACY
grep -A 22 Evaluation firstTest.out

# OPTIMIZATION OF PREDICTION ACCURACY (ADJUSTMENTS OF META PARAMETERS)
## Copying the metaparameter file in the AUGUSTUS training directory and telling the
## program which meta-parameters need to be optimized. NB: this has to be done manually
## by editing the file using any text editor.
cp /home/fogah/prg/augustus-3.2.3/config/species/generic/generic_metapars.cfg 08.augustusTraining

## Running the optimization
$AUGUSTUS/scripts/optimize_augustus.pl --species=lda --AUGUSTUS_CONFIG_PATH='/project/rclevesq/partage/sw/augustus-3.2.2/config' 08.augustusTraining/lda.highConfidence.genes.strict3sources.FILTERED.gb

## Getting out of the directory, back to the main working directory
cd ..

## 7.2. RUNNING THE TRAINED VERSION OF AUGUSTUS ##
# ---------------------------------------------- #

# Concatenating multiple hints files into 1 single hints file
cat 05.exonerate/metazoa.onLDA.PacBio.exonerate.hintsfile.gff 06.pasa/lda.transcript.alignments.hints.gff | sed ‘s /pri=4;src=E/pri=5;src=E/g’ | sed ‘s/pri=4/pri=2/g’ > 09.augustus/lda.augustus.hintsFile.gff

# Running the trained version of AUGUSTUS with hints file
$AUGUSTUS/bin/augustus 01.raw.data/lda.fasta.masked \
    --AUGUSTUS_CONFIG_PATH='/project/rclevesq/partage/sw/augustus-3.2.2/config' \
    # The extrinsic config file depends on the specific nature of the dataset and needs to
    # be optimized for the dataset that is being dealt with. It tells AUGUSTUS how to trust
    # the various types of hints being given in the hintsfile. In this particular case with
    # gypsy moths, Exons/Introns features derived from RNAseq data are judged the highest
    # confidence level, while EXONERATE (metazoan protein alignment) has less confidence.
    --extrinsicCfgFile='09.augustus/extrinsic.lda.cfg' \
    --species=lda \
    --gff3=on \
    --cds=on \
    --codingseq=on \
    --alternatives-from-evidence=false \
    --alternatives-from-sampling=false \
    --hintsfile='09.augustus/lda.augustus.hints.all.gff' > 09.augustus/lda.augustusOUT.withHints.gff

# Extracting coding and protein sequences from the genome annotation file generated by AUGUSTUS
/project/rclevesq/partage/sw/augustus-3.2.2/scripts/getAnnoFasta.pl 09.augustus/lda.augustusOUT.withHints.gff

### END OF SCRIPT ###

# NB: For the next steps, refer to the other scripts in ZZ.scripts, according to their respective ID number
