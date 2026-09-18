#!/usr/bin/env Rscript
#
# Annotate kallisto output with the anellovirus metadata.
#
#   Rscript 02_summarize.R results/demo

outdir <- commandArgs(TRUE)[1]
if (is.na(outdir)) outdir <- "results/demo"

ab <- read.delim(file.path(outdir, "abundance.tsv"))
md <- read.csv("../simple_anello_metadata_V2.csv", check.names = FALSE)
md <- md[!duplicated(md$Accession), ]

# Best genus call: ORF1 phylogeny, falling back to the ANI-inferred one.
# The raw NCBI Genus column is often literally "Unclassified".
md$genus <- ifelse(md$orf1_genus %in% c("", "Unclassified"),
                   md$infer_genus, md$orf1_genus)

df <- merge(ab, md[, c("Accession", "genus", "Species", "phylo_cluster")],
            by.x = "target_id", by.y = "Accession", all.x = TRUE)

det <- df[df$est_counts >= 10, ]
det <- det[order(-det$tpm),
           c("target_id", "genus", "Species", "est_counts", "tpm", "phylo_cluster")]

write.table(det, file.path(outdir, "anello_detected.tsv"),
            sep = "\t", row.names = FALSE, quote = FALSE)

cat(sprintf("\nanello reads: %.0f   contigs detected: %d\n\n",
            sum(df$est_counts), nrow(det)))

show <- det[, c("target_id", "genus", "Species")]
show$counts <- round(det$est_counts, 1)
show$tpm <- round(det$tpm)
print(head(show, 20), row.names = FALSE)

cat("\nby genus:\n")
gs <- aggregate(cbind(est_counts, tpm) ~ genus, det, sum)
gs[, -1] <- round(gs[, -1])
print(gs, row.names = FALSE)

# kallisto rounds p_pseudoaligned in run_info.json to one decimal, so a real
# low-level infection displays as 0.0. Compute the fraction properly.
info <- file.path(outdir, "run_info.json")
if (file.exists(info)) {
  n <- as.numeric(sub('.*"n_processed":\\s*([0-9]+).*', "\\1",
                      paste(readLines(info), collapse = "")))
  cat(sprintf("\nlibrary reads: %.0f  (%.3g%% anellovirus)\n",
              n, 100 * sum(df$est_counts) / n))
}

cat("\nTPM is composition within the anellome, not viral load.\n\n")
