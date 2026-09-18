# Example: anellovirus quantification

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


Note: kallisto's EM shares read counts across compatible segments of 4 genomes leading to non-integer read counts

## Three Caveats

- **TPM is composition within the anellome, not viral load.** The index holds
  only anellovirus, so TPM sums to 1e6 even with three reads. Use `est_counts`
  vs total reads; `02_summarize.R` prints it.
- **Ignore `p_pseudoaligned` in `run_info.json`.** Kallisto rounds it to one
  decimal, so this real 0.00736% detection reads `0.0`. Same for the "0.0%
  mapped" progress meter.
- **Genus Level Aggregation.** Often it is easier to interpret results by summarizing to the genus level to know which genera are present in your sample. Often many viral strains have a few stray reads in low complexity regions that are often recombined across viral strains, it is sometimes easier to mask strains with low read counts or assign their reads to the top strains. 
- **Index and quant must use the same kallisto version.** Built here with 0.52.0.

Runtime: index 5 s, quant ~3.5 min on 8 threads. `data/` and `results/` are
gitignored.
