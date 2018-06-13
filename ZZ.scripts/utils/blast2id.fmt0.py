#!/usr/bin/env python
"""
v.1.0            User's Commands            v.1.0

\033[1mDESCRIPTION\033[0m
    Takes an output file from the BLAST+ program
    (in format 0) and returns a tab-delimited
    text file with one query per line, with a tab
    and then it's corresponding blast hit. This
    program is usefull only to produce a 2-column
    text file that is easy to parse by another
    program. Or let's say someone only wants to 
    have a quick BLAST-oriented annotation of
    certain sequences (e.g. transcriptome, PCR
    products, ESTs, or even genomic sequences from
    a recent genome assembly).

\033[1mUSAGE\033[0m
    %program <in.blastResults.fmt0> <output>

\033[1mCREDITS\033[0m
    Doc Pants 2017 \m/
"""

import sys
import re

try:
    in_blast = sys.argv[1]
    out_file = sys.argv[2]
except:
    print __doc__
    sys.exit(1)

# Dictionary in which the annotation information will be stored
annotation = {}

# Boolean variable telling if a hit has been found
start = False

# Objects in which we will store the name of the query sequence ('q')
# and hit sequence ('h')
q = ""
h = ""

# Parsing the input file and creating the output file at the
# same time
with open(in_blast, "rU") as i_f:
    with open(out_file, "w") as o_f:
        for line in i_f:
            line = line.strip()

            # If the current line is the one with the query name
            if line.startswith("Query="):

                # Storing the name of query sequence in an object
                q += line.split("Query= ")[-1].split(".")[0]

            # If the program reaches the hit sequence for the current
            # query
            elif line.startswith(">"):
                
                # The program adds the hit sequence name to the
                # corresponding object
                h += line.split(">")[-1]

                # The description of the hit sequence has started
                start = True

            # If the program reaches the end of the hit sequence description
            # (i.e. Length of that sequence)
            elif line.startswith("Length") and start:
                
                # Writing in the output file the results
                o_f.write(q + "\t" + h + "\n")

                # Then everything is set back to 0 and the program is ready 
                # to start a new query.
                start = False
                q = ""
                h = ""

            # If the name of the hit sequence for the current query is too
            # long, it will be continued on the next line (the line after
            # the '>' character). The program wants those extra strings!!
            elif re.findall("[aA-zZ]*[0-9]*", line) and start:
                
                # Adding the extra strings to the hit seuqence name description
                h += " " + line

            # If the gene did not get any result on 'nr'
            elif line.find("No hits found") != -1:
                
                # Writing in output file that this gene doesn't have any match
                # on the 'nr' database.
                o_f.write(q + "\t" + "Uncharacterized predicted gene" + "\n")

                # Resetting the query/hit objects
                q = ""
                h = ""

print "\n\033[1mTASK COMPLETED\033[0m\n"
