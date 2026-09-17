# conda activate /data1/lareauc/users/gutierj/env/rbio
library(data.table)
library(dplyr) 
library(Biostrings) 




anello_meta <- fread("seqs/anelloviridae_summary.tsv")


## Note: This was downloaded manually from NCBI virus as the command line doesnt contain taxonomic info.
full_taxonomy <- fread("seqs/anelloviridae_human_complete_sequences_annotation.csv")

simple_taxon <- full_taxonomy %>% dplyr::select(Accession, Species,Genus, Family, Isolate)

anello_meta <- left_join(anello_meta, simple_taxon)

## Extract only the simplified relevant info
simple_anello_meta <- anello_meta %>% dplyr::select(Accession, Species,Genus, Family, Isolate,`Virus Taxonomic ID`, `Virus Name`,Length, `Isolate Lineage source` )

## Mask "" as Unclassified
simple_anello_meta <- simple_anello_meta%>% mutate(Genus = if_else(Genus == "", "Unclassified",Genus))

## Append vclust output 

aba_clust <- fread("vclust/liden_clusters.tsv")  %>% dplyr::rename(leiden = cluster)## leiden --metric ani --ani 0.95 --qcov 0.85
aba_genus <- fread("vclust/genus.tsv") %>% dplyr::rename(genus = cluster) ## genus (tANI ≥ 70%).
aba_species <- fread("vclust/species.tsv")  %>% dplyr::rename(species = cluster)##  (tANI ≥ 95%).

aba_full_c <- list(aba_clust, aba_genus,aba_species ) %>% Reduce("left_join",.)

aba_full_c <- aba_full_c %>% dplyr::rename(seqid = object)

simple_anello_meta <- left_join(simple_anello_meta, aba_full_c %>% dplyr::rename(Accession = seqid))

## Attempt to infer genus from NT clustering naively 
#simple_anello_meta %>% distinct(Genus) %>% pull() %>% dput()
gen_ord <- c("Unclassified", "Memtorquevirus", "Samektorquevirus", "Alphatorquevirus", 
	     "Betatorquevirus", "Hetorquevirus", "Gammatorquevirus", "Gyrovirus") 
infer_df <- simple_anello_meta %>% mutate(Genus = factor(Genus,levels = gen_ord))
 infer_df <- infer_df%>% group_by(leiden) %>% count(Genus) %>% mutate(num_genus = max(as.numeric(Genus)), infer_genus = gen_ord[num_genus])
 
 simple_infer <- infer_df %>% dplyr::select(leiden, infer_genus) %>% distinct()
  simple_anello_meta <- left_join(simple_anello_meta, simple_infer)


## CDHIT CLUSTERING REPRESENTATIVES 
 new_ids <- fread("cdhit_clusters.tsv") %>% dplyr::rename(Accession=object, cdhit_representative = cluster)

 simple_anello_meta <- left_join(simple_anello_meta, new_ids)
 
 rep_ids <- simple_anello_meta$cdhit_representative %>% unique()


# ORF1 Analysis 
orf1_fa <- Biostrings::readAAStringSet("anelloviridae_061725_orfs.faa")
first_s <- names(orf1_fa) %>% strsplit(" ") %>% lapply(function(x) x[[1]]) %>% unlist() %>% gsub("_1","",.)

orf_ids <- first_s %>% paste0(.,"_1")

orf1_df <- data.frame(Accession = first_s,orf_id=orf_ids, aa_length = orf1_fa %>% lapply(length) %>% unlist() )

simple_anello_meta <- left_join(simple_anello_meta,orf1_df)

simple_anello_meta <- simple_anello_meta %>% mutate(aa_length = if_else(is.na(aa_length),0,aa_length))

## Export cleaned metadata

fwrite(simple_anello_meta, "metadata/simple_anello_metadata.csv")


## Export representative 

raw_fa <- readDNAStringSet("anelloviridae_061725_genomic.fa")
old_names <- names(raw_fa)
names(raw_fa) <- old_names%>% strsplit(" ") %>% lapply(function(x)x[[1]]) %>% unlist()
names(old_names) <- names(raw_fa)

rep_ids <- simple_anello_meta$cdhit_representative %>% unique()
rep_fa <- raw_fa[rep_ids]
names(rep_fa) <- old_names[rep_ids]

writeXStringSet(rep_fa, "cdhit_rep_anelloviridae_061725_genomic.fa")


use_orfs <- simple_anello_meta %>% filter(Accession == cdhit_representative) %>% pull(orf_id)
idx <- names(orf1_fa) %>% strsplit(" ") %>% lapply(function(w) w[[1]]) %>% unlist()
rep_orf1_fa <- orf1_fa[idx %in% use_orfs]

## Only 2018 samples so 5 dont have ORF1's 

writeXStringSet(rep_orf1_fa, "orf1_cdhit_rep_anelloviridae_061725_orfs.faa")

