# Example Workflow: Anellovirus Quantification

```bash
cd example
./00_download.sh                             # SRR32170409 from SRA (~35 GB free disk)
./01_kallisto.sh                             # index + kallisto quant
Rscript 02_summarize.R results/SRR32170409   # genus/species calls
```

For your own sample, edit `FQ1`/`FQ2`/`OUT` at the top of `01_kallisto.sh`.

## Result

SRR32170409 is human RNA-seq of a Lung Transplant Donor at one timepoint, 36.1M pairs. Verified output, also in
`expected_output/`:

```
anello reads: 2659   contigs detected: 4

  target_id            genus           Species counts    tpm
 MH649122.1 Alphatorquevirus Anelloviridae sp. 2308.9 850801
 MZ286128.1 Alphatorquevirus Anelloviridae sp.  234.8  94884
 MW455390.1 Alphatorquevirus Anelloviridae sp.   96.2  45304
 KP343840.1 Alphatorquevirus Torque teno virus   16.1   7727

library reads: 36109130  (0.00736% anellovirus)
```

Detectable anellovirus transcription in this sample with thousands of reads. 
Assume random sampling of a 3.8kb viral genome / 2x150bp read count ~ 13 reads yield 1x coverage.
This sample contains 2659 viral reads giving us an estimated 204x genome coverage. 


Notes:
* We rarely use TPM values as these are not accurate without jointly measuring the host genome/transcriptome.
* Kallisto's EM algorithm shares read counts across compatible genome segments leading to both non-integer read counts and multiple viral strains appearing in the results.
* Often it is easier to interpret results by summarizing to the genus level to know which genera are present in your sample. Often many viral strains have a few stray reads in low complexity regions that are often recombined across viral strains, it is sometimes easier to mask strains with low read counts or assign their reads to the top strains. 


## Runtime
index 5 s, quant ~3.5 min on 8 threads. 
