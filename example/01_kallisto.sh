#!/usr/bin/env bash
#
# Quantify anelloviruses against the hardmasked pangenome.
#
# Needs: kallisto. The kallisto that builds the index must be the same
# version as the one that runs quant.

set -e

REF=../ref/hardmasked_cdhit_rep_anelloviridae_061725_genomic.fa
IDX=../ref/hardmasked_cdhit_rep_anelloviridae_061725_genomic.idx

## ---- edit these ----------------------------------------------------------
FQ1=data/fastq/SRR32170409_1.fastq.gz
FQ2=data/fastq/SRR32170409_2.fastq.gz
OUT=results/SRR32170409
THREADS=8
## --------------------------------------------------------------------------

# build the index once (~5 sec)
[ -f $IDX ] || kallisto index -i $IDX $REF

kallisto quant -t $THREADS -i $IDX -o $OUT $FQ1 $FQ2

## single-end instead? -l and -s are required, kallisto can't infer them:
#kallisto quant -t $THREADS -i $IDX -o $OUT --single -l 300 -s 20 $FQ
