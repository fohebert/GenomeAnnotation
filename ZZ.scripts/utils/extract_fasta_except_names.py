#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Prend un fichier txt avec des noms de séquences non-voulues et les cherche dans un fichier FASTA qui en
# contient une multitude. Extrait tous les contigs ou les séquences qui ne correspondent pas aux noms
# qui ne sont pas désirés.

"""\nTakes a text file with names of unwanted sequences and\
extracts all the sequences from the fasta file except\
the unwanted ones.
    
    Usage : <fasta file> <sequence names> <output file>\n"""

import sys
import re
from Bio import SeqIO

try:
    fasta_file = open(sys.argv[1], 'rU')  # Input fasta file
    unwanted_names = sys.argv[2] # Input of unwanted names
    result_file = sys.argv[3] # Output fasta file
except:
    print __doc__
    sys.exit(0)

unwanted = set()
with open(unwanted_names, "rU") as in_f:
    for line in in_f:
        line = line.strip()
        if line != "":
            unwanted.add(line)

print "Number of 'unwanted' sequences: ", len(unwanted)

sequences = [(seq.id, seq.seq.tostring()) for seq in SeqIO.parse(fasta_file, "fasta")]

count = 0
with open(result_file, "w") as out_f:
    for seq in sequences:
        if seq[0] not in unwanted:
            if count == 0:
                out_f.write(">" + seq[0] + "\n" + seq[1])
            if count > 0:
                out_f.write("\n" + ">" + seq[0] + "\n" + seq[1])
        count += 1

print "\n\033[1mJob done\033[0m\n"