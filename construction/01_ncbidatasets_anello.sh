
# Trying ncbi commandline tool?
## installed via conda so lets try it sis
#conda activate /data1/lareauc/users/gutierj/env/entrez

#https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Info&id=687329&lvl=3&lin=f&keep=1&srchmode=1&unlock
use_tax=687329 ##Anelloviridae

## Download metadata for relevant anello
datasets summary virus genome taxon ${use_tax} --complete-only --host human --as-json-lines | dataformat tsv virus-genome > seqs/anelloviridae_summary.tsv

#datasets summary virus genome taxon ${use_tax} --complete-only --host human --as-json-lines | dataformat tsv virus-annotation > try2_anelloviridae_summary.tsv

## convert this stuff into tsv??? 
 #dataformat tsv virus-annotation --inputfile annotation_report.jsonl  > anello_annotation_report.tsv

##  using vanilla taxonomy? 
#datasets download taxonomy taxon ${use_tax} --children ## only 900 taxons??? TOO MUCH MISSING 

## Now download Fasta and proteins
datasets download virus genome taxon ${use_tax} --complete-only --host human --include genome,cds,protein,annotation --filename seqs/anelloviridae.zip 
