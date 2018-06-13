#!/usr/bin/env python
"""
v.1.0              User's commands             v.1.0

\033[1mDESCRIPTION\033[0m
    This utility script converts an AUGUSTUS-specific
    GFF file (standard output from AUGUSTUS) into a
    fully annotated GFF3 file. It needs the raw output
    from AUGUSTUS (GFF format), a BLAST output file
    (format 6) on swissprot, a BLAST output file (format 0)
    on the 'nr' database, BlastKOALA results (KEGG), 
    and the '.dat' file from uniprot-swissprot (downloadable 
    from uniprot website) and returns a standard GFF3 file 
    with information on gene products and GO terms.

\033[1mUSAGE\033[0m
    %program < AUGUSTUS.out >
            < BLAST.swissprot.fmt0 >
            < uniprot.da >
            < BLAST.nr.tab-delimited >
            < in.kegg >
            < out.gff3 >
            < out.feature.table >

\033[1mCREDITS\033[0m
    Doc PANTS 2017 \m/
"""

import sys

try:
    augustus_out = sys.argv[1]
    blast_in = sys.argv[2]
    uniprot_dat = sys.argv[3]
    blast_nr = sys.argv[4]
    in_kegg = sys.argv[5]
    out_file = sys.argv[6]
    out_table = sys.argv[7]
except:
    print __doc__
    sys.exit(1)

###################################################################
# 1. PARSING OUT THE FUNCTIONAL INFO FROM UNIPROT-SPROT DATA FILE #
###################################################################

# The program parses out the gene product and GO terms for each
# accession number contained in uniprot-swissprot (.dat file).
# This info is kept in a dictionary for now and will be used later
# to produce the final output file.

# Dictionary in which the "meta-info" will be kept:
info_unipsp = {}
# Dictionary in which the info on BLAST results will be kept
blast_res = {}
# Object in which the program stores the gene ID (accession #)
accession = ""

currently_dealing_with_accession = False
accession = ""
# Parsing the uniprot-swissprot .DAT file and placing the info in the dictionary
with open(uniprot_dat, "rU") as uni_in:
    for line in uni_in:
        line = line.strip()
        
        # If the line is a *NEW* accession number
        if line.startswith("AC   ") and currently_dealing_with_accession == False:
            
            # Emptying accession object to fill it in with new info
            accession = ""

            # turn on this variable to tell the program that a new accession
            # or swissprot entry has been found.
            currently_dealing_with_accession = True

            # Some accessions have multiple IDs that correspond to the
            # same protein. If this is the case for the current uniprot
            # entry, the program deals with those multiple ACCESSION
            # numbers accordingly.
            if len(line.split("AC   ")[-1].split(";")) <= 2: # Only 1 ACCESSION number

                # Accession number
                accession += line.split("AC   ")[-1].split(";")[0] + ";"

            elif len(line.split("AC   ")[-1].split(";")) > 2: # Multiple accession numbers

                # Accession numberS
                accession += ";".join(line.split("AC   ")[-1].split("; "))
                
        # If the line contains other accession numbers for the same protein that we
        # have already entered in the dictionnary.
        elif line.startswith("AC   ") and currently_dealing_with_accession == True:
            
            # One accession only
            if len(line.split("AC   ")[-1].split(";")) <= 2:

                # Accession number
                accession += line.split("AC   ")[-1].split(";")[0] + ";"
            
            # Multiple accession numbers   
            elif len(line.split("AC   ")[-1].split(";")) > 2: 

                # Accession numberS
                accession += ";".join(line.split("AC   ")[-1].split("; "))

        # If the current line is about the gene product
        elif line.startswith("DE   RecName:"):
            
            # This means that accession numbers have all been integrated,
            # so it's time to enter the info in the dict()
            info_unipsp[accession] = {}
            info_unipsp[accession]["GO"] = []
            info_unipsp[accession]["gene_product"] = ""

            # Reset on the accession variable
            currently_dealing_with_accession = False

            # The program adds this gene product to the accession ID
            # in the dictionary
            info_unipsp[accession]["gene_product"] = line.split("Full=")[-1].split(";")[0]
        
        # If the current line is about GO terms
        elif line.startswith("DR   GO;"):
            
            # The program adds the GO term to the existing GO term list
            # in the right accession ID, in the dictionary
            go_num = line.split()[2].split(";")[0] # GO ID
            go_description = line.split("; ")[2] # GO term description
            info_unipsp[accession]["GO"].append(go_num + ", " + go_description)

#####################################################
# 2. PARSING INFO ON 'UNIP-SWISSPROT' BLAST RESULTS #
#####################################################

# Associating each gene that had a successful hit on swissprot-uniprot to the
# accession ID of the hit.
with open(blast_in, "rU") as b_i:
    for line in b_i:
        line = line.strip()

        # Keeping only the appropriate info, i.e. gene number + hit accession ID
        gene_num = line.split()[0].split(".")[0]
        hit_id = line.split()[1]
        
        # Filling in the dictionary with the info found in the file
        blast_res[gene_num] = hit_id

########################################
# 3.PARSING INFO ON 'NR' BLAST RESULTS #
########################################

# Dictionary in which all of the pieces of info on "nr" are going to be stored
b_res_nr = {}

with open(blast_nr, "rU") as b_nr:
    for line in b_nr:
        line = line.strip()

        # For every line in this input file, the program takes the first column
        # and stores it in an object (i.e. name of the contig) and the info in
        # the other column is stored in another object (i.e. gene product = g_p)
        contig = line.split("\t")[0]
        g_p = line.split("\t")[-1]

        # Storing the info contained in both objects in a dictionary
        b_res_nr[contig] = g_p

print "Number of genes annotated with 'nr': ", len(b_res_nr)

##########################################
# 4.PARSING THE AUGUSTUS GFF OUTPUT FILE #
##########################################

# The program parses out the pertinent lines in the AUGUSTUS GFF file
# and writes them down in the output file with the info contained in the
# dictionaries that were filled in up there in steps 1-2.

# String object keeping the name of the current gene when parsing the input file
gene = ""

# Object that keeps track of where the program is in each predicted gene
current_pos = 0

# Boolean variable specifying if we have a negative/positive strand gene
# True = positive (+) | False = negative (-)
strand = True

with open(augustus_out, "rU") as a_o:
    with open(out_file, "w") as o_f:
        
        # Preparing file header
        o_f.write("##gff-version 3\n# This output was initially generated with AUGUSTUS (version 3.2.3).")
        o_f.write("\n# Modified from its original AUGUSTUS version by F. Olivier Hebert to standard format\n#\n")
        
        for line in a_o:
            line = line.strip()

            # If the program finds a new gene in the input file
            if line.startswith("# start gene"):
                gene = line.split("gene ")[-1]

            # If the program finds a line where the gene feature is defined
            # there won't be any "#" character at the beginning of the line.
            if line.startswith("#") == False:
                
                # If this is the first line of the gene feature description
                if line.split()[2] == "gene":

                    # If this gene has an entry in the blast results dictionary
                    # then the info on the gene product + GO terms will be added
                    # to the final output file.
                    if gene in blast_res:
                        
                        # Fetching the uniprot-swissprot ID to which it successfully blasted
                        unipsp_id = blast_res[gene]

                        # Verifying that the ID is present in the meta-dictionary
                        for ID in info_unipsp:
                            
                            if ID.find(unipsp_id) != -1:
                        
                                # Writing down the info in the final output file
                                o_f.write(line + ";Sprot-uniprot homology= " + info_unipsp[ID]["gene_product"] + ";" + "'".join(info_unipsp[ID]["GO"]))
                    
                    # If the gene did not return any result on 'swissprot', but did return
                    # something on 'nr' (this also includes genes with no results on 'nr')
                    elif gene not in blast_res and gene in b_res_nr:
                        
                        # If the gene did not return any result on 'nr'
                        if b_res_nr[gene] == "Uncharacterized predicted gene":
                            
                            # Simply write in the output file that this gene is uncharacterized
                            o_f.write(line + ";Uncharacterized predicted gene")
                        
                        # If the gene did return some hit on 'nr'
                        elif b_res_nr[gene] != "Uncharacterized predicted gene":
                            
                            # Fetching up the exact name of the protein to which it matched
                            # and writing the info in the output file
                            o_f.write(line + ";Sequence homology, NCBI's 'non-redundant'= " + b_res_nr[gene])
                    
                # If the current line is the description of the transcript sequence, then the program
                # takes the start and end position of that feature as the reference positions for the
                # intron-exon counts and boundaries.
                elif line.split()[2] == "transcript":
                    
                    # First, the line is written in the output file
                    o_f.write("\n" + line)

                    # Also keep in memory the current position, i.e. the start of the gene
                    current_pos = int(line.split()[3])

                    # Then, if the gene is on the negative strand, boolean 
                    # variable is adjusted accordingly
                    if line.split()[6] == "-":
                        strand = False
                    
                    # If the gene is on the positive strand, boolean 
                    # variable is adjusted accordingly
                    elif line.split()[6] == "+":
                        strand = True

                # If the line is the stop_codon
                elif line.split()[2] == "stop_codon":
                    
                    # Positive strand
                    if strand == True:
                        
                        # Defining the exon boundaries (last exon)
                        ex_start = current_pos
                        ex_stop = int(line.split()[4])

                        # Writing down the next line in the output file, which
                        # should be an exon. This is where we add exon lines!
                        o_f.write("\n" + line.split()[0]) # Contig number
                        o_f.write("\t" + line.split()[1]) # Source of feature
                        o_f.write("\t" + "exon") # Adding exon feature
                        o_f.write("\t" + str(ex_start) + "\t" + str(ex_stop)) # Exon positions
                        o_f.write("\t" + "." + "\t" + "\t".join(line.split()[6:])) # Rest of the info

                        # Writing down in the output file the line with the intron
                        # that just hepled us define the exon
                        o_f.write("\n" + line)
                    
                    # Negative strand
                    elif strand == False:
                        
                        # Writing the line ine the output file
                        o_f.write("\n" + line)

                elif line.split()[2] == "intron":

                    # If the first position of the gene is also the first position of
                    # the first intron, no need to output an exon sequence, so the 
                    # line is written as is in the output file.
                    if current_pos == int(line.split()[3]):
                        
                        # Writing the line as is in the output file
                        o_f.write("\n" + line)

                    # Any other situation is treated that way:
                    else:
                        
                        # Defining the exon boundaries
                        ex_start = current_pos
                        ex_stop = int(line.split()[3]) - 1
                        
                        # Writing down the next line in the output file, which
                        # should be an exon. This is where we add exon lines!
                        o_f.write("\n" + line.split()[0]) # Contig number
                        o_f.write("\t" + line.split()[1]) # Source of feature
                        o_f.write("\t" + "exon") # Adding exon feature
                        o_f.write("\t" + str(ex_start) + "\t" + str(ex_stop)) # Exon positions
                        o_f.write("\t" + "." + "\t" + "\t".join(line.split()[6:])) # Rest of the info

                        # Writing down in the output file the line with the intron
                        # that just hepled us define the exon
                        o_f.write("\n" + line)

                    # Updating the current position for the next feature
                    current_pos = int(line.split()[4]) + 1
                
                # Current line is the start_codon
                elif line.split()[2] == "start_codon":

                    # Positive strand
                    if strand == True:
                        
                        # Writing the line ine the output file
                        o_f.write("\n" + line)
                    
                    # Negative strand
                    elif strand == False:
                        
                        # Defining the exon boundaries (last exon)
                        ex_start = current_pos
                        ex_stop = int(line.split()[4])

                        # Writing down the next line in the output file, which
                        # should be an exon. This is where we add exon lines!
                        o_f.write("\n" + line.split()[0]) # Contig number
                        o_f.write("\t" + line.split()[1]) # Source of feature
                        o_f.write("\t" + "exon") # Adding exon feature
                        o_f.write("\t" + str(ex_start) + "\t" + str(ex_stop)) # Exon positions
                        o_f.write("\t" + "." + "\t" + "\t".join(line.split()[6:])) # Rest of the info

                        # Writing down in the output file the line with the intron
                        # that just hepled us define the exon
                        o_f.write("\n" + line)
                
            # When the gene feature description is done for a particular feature, the program
            # will output in the output file line returns in order to be ready to output the
            # next gene feature.
            elif line.startswith("# end gene"):
                
                # String character indicating that a new gene is going to be described next
                o_f.write("\n" + "#" + "\n")

                # Setting everything back to initial configurations
                current_pos = 0 # Gene positions
                gene = "" # Gene number

######################################
# 5.PARSING OUT THE KEGG INFORMATION #
######################################

# Dict() in which the Ko numbers (IDs) and their corresponding gene will be stored
k_anno = {}

with open(in_kegg, "rU") as i_k:
    for line in i_k:
        line = line.strip()

        g = line.split("\t")[0].split(".")[0] # Gene ID
        k = line.split("\t")[1] # Corresponding Ko number
        k_anno[g] = k # Adding the info in the dict()

##################################
# 6.GENERATING THE FEATURE TABLE #
##################################

# Here, the program parses the output file generate in step 3 above
# and produces a simple TAB-delimited text file that summarizes the
# pieces of info that we have for each feature predicted by AUGUSTUS.

# Parsing the output file (GFF3) generated above
with open(out_file, "rU") as o_f:
    with open(out_table, "w") as o_t:
        
        # Preparing the file header
        header = ["# Feature", "ID", "genomic_contig", "source", "start", "end", "strand", "product", "GO", "Ko"]
        o_t.write("\t".join(header))
        
        for line in o_f:
            line = line.strip()
            
            # Making sure the program only considers lines for which
            # there is valuable information.
            if line.startswith("#") == False:
                
                # If the line the program is currently dealing with
                # corresponds to the general info line on the gene
                # (which contains info on gene product & GO terms),
                # the program outputs the info in the feature table.
                if line.split("\t")[2] == "gene":
                    
                    # Info that we want to output:
                    gID = line.split("ID=")[-1].split(";")[0] # Gene ID
                    tig = line.split("\t")[0] # Contig number
                    s = line.split("\t")[1] # Source of prediction
                    start = line.split("\t")[3] # Start position
                    end = line.split("\t")[4] # End position
                    strd = line.split("\t")[6] # Strand (+ or -)
                    prod = line.split("\t")[-1].split(";")[1] # Gene product
                    gt = "" # Object for GO terms
                    ko = "" # Object for Ko number
                    
                    # Verifying if there is any entry in KEGG Ko number
                    # for that gene.
                    if gID in k_anno:
                        ko += k_anno[gID] # If yes, info added to object
                    else:
                        ko += "NA" # If no, the program outputs "NA"

                    # If the gene product is derived from homology to 'nr'
                    # It means it doesn't have any GO terms
                    if line.find("non-redundant") != -1:
                        
                        gt = "NA" # No GO terms
                        
                        # Writing the info in the feature table output
                        o_t.write("\n" + "gene" + "\t" + gID + "\t" \
                            + tig + "\t" + s + "\t" + start + "\t" + end + "\t" \
                            + strd + "\t" + prod + "\t" + gt + "\t" + ko)

                    # If the gene product is derived from homology to 'swissprot'
                    # the program will keep the GO terms in the corresponding
                    # object
                    elif line.find("Sprot-uniprot") != -1:
                        
                        gt = line.split("\t")[-1].split(";")[-1] # GO terms
                        
                        # Writing the info in the feature table output
                        o_t.write("\n" + "gene" + "\t" + gID + "\t" \
                            + tig + "\t" + s + "\t" + start + "\t" + end + "\t" \
                            + strd + "\t" + prod + "\t" + gt + "\t" + ko)

                    elif line.find("Uncharacterized predicted gene"):
                        
                        gt = "NA" # No GO terms
                        
                        # Writing the info in the final table feature file
                        o_t.write("\n" + "gene" + "\t" + gID + "\t" \
                            + tig + "\t" + s + "\t" + start + "\t" + end + "\t" \
                            + strd + "\t" + "Uncharacterized predicted gene" + "\t" \
                            + gt + "\t" + ko)
                        
print "\n\033[1mTASK COMPLETED\033[0m\n"
