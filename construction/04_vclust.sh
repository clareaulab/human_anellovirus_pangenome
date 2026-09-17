#pip install vclust ## installed in base conda env its whatever

## Following https://github.com/refresh-bio/vclust
# Create a pre-alignment filter for genome pairs with a minimum of 20 common k-mers

mkdir vclust 
cd vclust 
# and a minimum sequence identity of 70% (relative to the shortest sequence).
vclust prefilter -i ../masked_anelloviridae_061725_genomic.fa -o fltr.txt --min-ident 0.7

# Calculate ANI measures for genome pairs specified in the filter.
vclust align -i ../masked_anelloviridae_061725_genomic.fa -o ani.tsv --filter fltr.txt

# Assign viruses into putative species (tANI ≥ 95%).
vclust cluster -i ani.tsv -o species.tsv --ids ani.ids.tsv --algorithm complete \
	--metric tani --tani 0.95

# Assign viruses into putative genera (tANI ≥ 70%).
vclust cluster -i ani.tsv -o genus.tsv --ids ani.ids.tsv --algorithm complete \
	--metric tani --tani 0.70


# Cluster contigs using the CD-HIT algorithm and show representative genome.
vclust cluster -i ani.tsv -o clusters.tsv --ids ani.ids.tsv --algorithm cd-hit \
	--metric ani --ani 0.95 --qcov 0.85 --out-repr

# Cluster the genomes using the Leiden algorithm. The cluster edges are weighted by
# the gani metric (ANI x coverage), with a Leiden resolution parameter set to 0.9.
vclust cluster -i ani.tsv -o liden_clusters.tsv --ids ani.ids.tsv --algorithm leiden \
		--metric gani --gani 0.35 --leiden-resolution 0.9

## Export cdhit_clusters
cp clusters.tsv ../cdhit_clusters.tsv



