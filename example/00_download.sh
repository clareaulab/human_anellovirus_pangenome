#!/usr/bin/env bash
#
# Download the example run from SRA.
#
# Needs: sratoolkit (prefetch, fasterq-dump) and pigz or gzip.
# Budget ~35 GB of free disk: fasterq-dump writes ~30 GB uncompressed before
# pigz takes it down to ~4.6 GB.

set -e

SRA=SRR32170409

prefetch --max-size u -O data/sra $SRA

# NCBI serves .sralite by default (simplified quality scores, which kallisto
# ignores anyway), hence the .sra* glob. --split-3 writes _1/_2 for paired runs.
fasterq-dump --split-3 --threads 8 -t data/tmp -O data/fastq \
	data/sra/$SRA/$SRA.sra*

pigz -p 8 data/fastq/${SRA}_1.fastq data/fastq/${SRA}_2.fastq   # or: gzip

ls -la data/fastq/
