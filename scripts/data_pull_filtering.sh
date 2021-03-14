# Let's start by pulling data from scicore
# We need an environment where pybis is installed, this can be done with conda
# All necessary sequencing runs need to be listed in file called 'list.txt'

python scicore.py

# we have the data, we concatenated the left and right reads that arose from the distribution of the library across the HiSeq 2500 flowcell
# let's run fastqc on the raw data

fastqc *.fastq.gz

# things look good on the quality side. we just need to get the adapters off and do some light trimming with trimmomatic

java -jar trimmomatic-0.35.jar PE WBD_Dissected_R1.fastq.gz WBD_Dissected_R2.fastq.gz output_forward_paired.fq.gz output_forward_unpaired.fq.gz \
output_reverse_paired.fq.gz output_reverse_unpaired.fq.gz ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36

# lets interleave paired reads and concatenate the orhaned reads

seqtk mergepe output_forward_paired.fq.gz output_reverse_paired.fq.gz > WBD_Dissected_R1.pe.fq.gz
cat output_forward_unpaired.fq.gz output_reverse_unpaired.fq.gz > WBD_Dissected_R1.se.fq.gz

# run fastqc again to make sure filtering worked as expected on adapters
fastqc WBD_Dissected_R1.pe.fq.gz WBD_Dissected_R1.se.fq.gz

# looks good! Repeat process on non-dissected reads

java -jar trimmomatic-0.35.jar PE WBD_NoDissected_R1.fastq.gz WBD_NoDissected_R2.fastq.gz output_forward_paired.fq.gz output_forward_unpaired.fq.gz \
output_reverse_paired.fq.gz output_reverse_unpaired.fq.gz ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36

seqtk mergepe output_forward_paired.fq.gz output_reverse_paired.fq.gz > WBD_NoDissected_R1.pe.fq.gz
cat output_forward_unpaired.fq.gz output_reverse_unpaired.fq.gz > WBD_NoDissected_R1.se.fq.gz

# run fastqc again to make sure filtering worked as expected on adapters
fastqc WBD_NoDissected_R1.pe.fq.gz WBD_NoDissected_R1.se.fq.gz

# Everything looks fine. We can no proceed with the assembly process!
