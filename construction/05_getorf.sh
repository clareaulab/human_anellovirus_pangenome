#conda activate /data1/lareauc/users/gutierj/env/emboss

## I FIGURED OUT HOW TO STREAM STDERR TO LESS!
#getorf -h 2>&1 | less 


## Get size > 1kb of bases 
getorf -sequence anelloviridae_061725_genomic.fa  -minsize 1000 -circular Y -find 1  -outseq anelloviridae_061725_orfs.faa
