# Human Anellovirus Pangenome

A curated, non-redundant reference of **2,023 human anellovirus genomes** for
detecting and quantifying anelloviruses in sequencing data.

Anelloviruses are near-universal in humans, enormously diverse, and awkward to
quantify: genomes are similar enough that reads multimap freely, yet divergent
enough that a single reference misses most of the population. This reference
collapses the redundancy, masks the low-complexity repeats that drive spurious
hits, and pairs with kallisto pseudoalignment so multimapping is handled by EM
instead of custom BAM scripts.

## Layout

```
ref/             the reference, index and annotation  -- start here
example/         runnable pipeline you can point at your own FASTQs
construction/    numbered scripts that build the reference from scratch
simple_anello_metadata_V2.csv    per-genome annotation (3,545 rows)
```

---

## The reference

Everything you need is in [`ref/`](ref/):

| File | Purpose |
|---|---|
| `hardmasked_cdhit_rep_anelloviridae_061725_genomic.fa` | **The reference.** 2,023 contigs, ready for any aligner. |
| `anello_t2g.txt` | Transcript-to-gene map (one contig = one transcript). |
| `anello_sizes.txt` | Contig sizes. |
| `anello_for_kallisto.gtf` | Annotation, for kallisto's `--genomebam` mode. |
| `kallisto_idx.sh` | Builds the kallisto index. |

| | |
|---|---|
| Contigs | 2,023 |
| Total | 5,927,006 bp |
| Length | 1,141 – 3,996 bp (median 2,895) |
| Hardmasked | 284,762 bp (4.8%) |
| Source freeze | NCBI Virus, June 2025 |

Per-genome annotation lives in
[`simple_anello_metadata_V2.csv`](simple_anello_metadata_V2.csv) — taxonomy,
isolate source, clustering assignments, and ORF1 phylogeny for all 3,545 input
genomes.

### Genus resolution

NCBI leaves roughly **30% of these genomes unclassified** at genus level. An
ORF1 protein phylogeny resolves nearly all of them:

| Genus | NCBI label | ORF1 phylogeny |
|---|---:|---:|
| Betatorquevirus | 1,360 | 1,558 |
| Alphatorquevirus | 27 | 267 |
| Gammatorquevirus | 23 | 141 |
| Hetorquevirus | 2 | 17 |
| Samektorquevirus | 3 | 11 |
| Gyrovirus | 6 | 6 |
| Memtorquevirus | 1 | 6 |
| **Unclassified** | **601** | **17** |

584 genomes gain a genus call. Use the `orf1_genus` column; `phylo_cluster`
(40 clusters) gives finer lineage structure. Five representatives have no ORF1
call and are blank in both columns.

---

## Using it on your data

[`example/`](example/) is a working pipeline, not just a demo. Point `FQ1` and
`FQ2` at your own FASTQs and it runs unchanged:

```bash
cd example
./01_kallisto.sh                     # edit FQ1/FQ2/OUT at the top
Rscript 02_summarize.R results/mysample
```

`01_kallisto.sh` builds the index and quantifies; `02_summarize.R` joins the
output to the metadata so you get genus and species calls instead of bare
accessions.

To see it work end to end first, `00_download.sh` fetches a public human
RNA-seq run (SRR32170409) and the same two steps find a low-level Torque teno
virus infection — 2,659 reads, 0.0074% of the library. Full walkthrough and the
caveats that matter in [`example/README.md`](example/README.md).

### Quantification directly

The hardmasked FASTA works with any detection strategy, but pseudoalignment is
the right tool here: it resolves reads across near-identical contigs by EM,
with no custom multimapping code.

**The kallisto that builds the index must be the exact version that runs
quant.**

```bash
module load kallisto/0.48.0
idx="/path/to/ref/hardmasked_cdhit_rep_anelloviridae_061725_genomic.idx"

# paired-end (preferred: fragment length is inferred from the data)
kallisto quant -t 2 -i $idx -o $out $R1 $R2

# single-end: -l and -s are REQUIRED, kallisto cannot infer them.
# 300 bp / 20 bp sd is a stand-in; use a bioanalyzer trace or your prep spec,
# because these values move the TPMs.
kallisto quant -t 2 -i $idx -o $out --single -l 300 -s 20 $FQ
```

---

## How it was built

Scripts are in [`construction/`](construction/), numbered in order.

1. **Collect** — NCBI Datasets, taxon 687329 (Anelloviridae), host human,
   complete genomes only → **3,545 genomes**. `01`, `02`
2. **Mask repeats** — RepeatMasker against human. `03`
3. **Cluster** — vclust ANI, CD-HIT algorithm at 95% ANI / 85% coverage →
   **2,023 representatives**. Also assigns putative species (tANI ≥ 95%) and
   genera (tANI ≥ 70%). `04`
4. **Call ORF1** — EMBOSS `getorf`, circular, ≥1,000 bp. `05`, `06`
5. **Hardmask** — `dustmasker` at windows 30 and 64, merged, masked to `N`.
   This is what stops low-complexity repeats from driving false hits. `07`
6. **ORF1 phylogeny** — MAFFT → trimAl → IQ-TREE (BLOSUM62+F+G4, 1000
   bootstraps), then patristic clustering into 40 groups to infer genus. `08`, `09`

The phylogeny step involves manual review of the tree, so it is recorded here
as provenance rather than as a turnkey rerun — regenerating it would shift the
underlying tree structure and the cluster assignments that depend on it.
