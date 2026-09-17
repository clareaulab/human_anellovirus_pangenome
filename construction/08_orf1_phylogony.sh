BATCH --job-name=iqtree
#SBATCH --partition=lareauc_cpu,cpu
#SBATCH --time=48:00:00
#SBATCH --cpus-per-task=26
#SBATCH --mem-per-cpu=4G
#SBATCH -e iqtree_slurm-%A_%a.err ## make sure ukb_logs dir exists
#SBATCH -o iqtree_slurm-%A_%a.out

## remeber to source this before sbatch 
#conda activate /data1/lareauc/users/gutierj/env/mafft1

mkdir anello_phylo
cd anello_phylo

cp ../orf1_cdhit_rep_anelloviridae_061725_orfs.faa . 

echo running MAFFT max threads
fftns --thread -1 orf1_cdhit_rep_anelloviridae_061725_orfs.faa > orf1_cdhit_rep_anelloviridae_061725_orfs.msafaa

echo running TRIMAL
trimal -in orf1_cdhit_rep_anelloviridae_061725_orfs.msafaa -out trimmed_orf1_cdhit_rep_anelloviridae_061725_orfs.msafaa

echo running IQTREE phylogony
iqtree2 -s trimmed_orf1_cdhit_rep_anelloviridae_061725_orfs.msafaa -st AA -m BLOSUM62+F+G4 -bb 1000 -alrt 1000 -nt AUTO


