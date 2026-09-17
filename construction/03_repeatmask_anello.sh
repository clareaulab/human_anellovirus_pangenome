#conda activate /data1/lareauc/users/gutierj/env/repeatmasker

## Added dram #7 to /data1/lareauc/users/gutierj/env/repeatmasker/share/RepeatMasker/Libraries/famdb
## Confirm using /data1/lareauc/users/gutierj/env/repeatmasker/share/RepeatMasker/famdb.py info to see it added 
#RepeatMasker anelloviridae_061725_genomic.fa -species 9606 -s -no_is -a -dir masked_human_anelloviridae -pa 2

cp masked_human_anelloviridae/anelloviridae_061725_genomic.fa.masked masked_anelloviridae_061725_genomic.fa


## now doing this for only representative genomes. I could do this by slicing the masked fa but I want seperate calculations... 
#RepeatMasker cdhit_rep_anelloviridae_061725_genomic.fa -species 9606 -s -no_is -a -dir rep_masked_human_anelloviridae -pa 2

