#!/usr/bin/env python
import sys, os

ds = os.listdir(sys.argv[1])

for d in ds:
    fPath = sys.argv[1] + '/' + d + '/evm.out'
    size = os.path.getsize(fPath)
    if size > 0:
        blocks = open(fPath).read().strip().split('#')[1:]
        for block in blocks:
            coords = []
            evidence = []
            for line in block.strip().split('\n')[1:]:
                if line.strip() != '' and line[0] != '!':
                    meta = line.strip().split('\t')
                    coords.append(int(meta[0]))
                    coords.append(int(meta[1]))
                    coords.sort()
                    evidence.extend([tuple(x[1:-1].split(';')) for x in meta[-1].split(',')])

            evidence = set(evidence)
            sources = set([x[1] for x in evidence])

            print d + '\t' + str(coords[0]) + '\t' + str(coords[-1]) + '\t' + ','.join([x[0] for x in evidence]) + '\t' + ','.join(sources)
