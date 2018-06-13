#!/usr/bin/env python
"""
\033[1mDESCRIPTION\033[0m
    This program takes a GFF3 file produced through EVM
    and parses out only the gene features for which enough
    evidence, from enough different sources (at least 3),
    was gathered. It needs, as input files, the main GFF3
    file generated with EVidence Modeler (EVM) and the 
    evidence file obtained with the script called:
    < 07.high.confidence.genes.selection.py >

    The program will return a parsed GFF file to be transformed
    into a genbank file that will be used to train AUGUSTUS with.

\033[1mUSAGE\033[0m
    %program <in.GFF3> <in.evidenceFile> <out.prasedGFF3>

\033[1mCREDITS\033[0m
    Dr. Pants 2017 \m/
"""

import sys

try:
    in_gff = sys.argv[1]
    in_evidence = sys.argv[2]
    out_gff = sys.argv[3]
except:
    print __doc__
    sys.exit(0)

# Using the evidence file to gather the names of the contigs 
# in which gene features have been found and their respective 
# positions in the contig. This info will be used as a reference
# when parsing the overall GFF3 file. All of the pieces of info
# are kept in a corresponding dictionnary.

good_ev = {} # Will contain the good evidence gene features
with open(in_evidence, "rU") as ev_i:
    for line in ev_i:
        line = line.strip()

        # If the last column in the file (5th col, i.e. number 4 for Python)
        # contains at least 3 different programs that identified the feature
        # it is kept in the dict().
        if len(line.split("\t")[4].split(",")) >= 3:
            
            # If the pieces of evidence come from GeneMark, PASA, and Exonerate
            # or Scipio, then we can keep it and have good confidence.
            count = 0
            for ev in line.split("\t")[4].split(","):
                if ev == 'GeneMark.hmm':
                    count += 1
                elif ev == 'assembler-pasadb_luca':
                    count += 1
                elif ev == 'Scipio':
                    count += 1
                elif ev == 'exonerate':
                    count += 1
                elif ev == 'BLAT':
                    count += 1

            if count >= 3:

                # Placing contig name and start/end positions in objects
                contig = line.split("\t")[0]
                pos = (line.split("\t")[1], line.split("\t")[2])
            
                # Adding those objects to the dictionnary where we keep the 
                # coordinates of the contigs we want to keep.
                # If the contig is already entered in the dictionary, the program
                # adds the position in the already existing list. If the contig
                # is NOT already in the dictionnary, the program creates a new entry
                # in this dictionary and creates a list for that new key. This list,
                # will contain all of the start/stop positions of the wanted features.
                if contig in good_ev:
                    good_ev[contig].append(pos)
                elif contig not in good_ev:
                    good_ev[contig] = [pos]

# Parsing the GFF3 file and keeping only the features for which we have
# sufficient information, i.e. at least 3 different programs identified it.

# name of the current contig that we are dealing with
current_tig = ""
# Positions for the current contig in which there is a gene feature
current_pos = ()
# Boolean variable indicating if the current feature is among the wanted ones
wanted = False

with open(in_gff, "rU") as i_gff:
    with open(out_gff, "w") as o_gff:
        for line in i_gff:
            line = line.strip()
            
            # If the program gets to a line where a feature starts,
            # it will look at the positions to see if it's a wanted feature.
            if line.split("\t") != [""] and line.split("\t")[2] == "gene" and wanted == False:
                
                # Looking at the contig name and the positions of the gene feature
                current_tig = line.split("\t")[0]
                current_pos = (line.split("\t")[3], line.split("\t")[4])
                
                # If the current contig is part of the good evidence lot, the program
                # keeps it and will write it to output file. It also has to match the
                # same positions
                if current_tig in good_ev:
                    
                    for pos in good_ev[current_tig]:
                        if current_pos == pos:
                            wanted = True
                            o_gff.write("\n" + "\n" + line)
                
                elif current_tig not in good_ev:
                    wanted = False
            
            # If the line contains anything esle than "gene" at the
            # third column, then it means a feature is being parsed.
            # So we need to determine if the line has to be written
            # in output file or not. This is determined with the 
            # 'wanted' object: if it's turned on to True, then the
            # line is written, if not, discarded.
            elif line.split("\t") != [""] and line.split("\t")[2] != "gene" and wanted == True:
                o_gff.write("\n" + line)

            # If the current line is an empty line, it means the program reached the end of a given
            # feature, and hence turns off the 'wanted' variable.
            elif line.split("\t") == [""]:
                wanted = False

print "\n\033[1mTASK COMPLETED\033[0m\n"
