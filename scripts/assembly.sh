# Let's get started with the assembly by mapping the reads to the host genome NOTE: we're leaving the orphaned reads out here as there aren't many and they're also less useful

bwa mem -t 55 -p dmagna2.4.fa WBD_NoDissected_R1.pe.fq.gz | samtools sort -O BAM -o WBD_NoDissected.align.bam -
bwa mem -t 55 -p dmagna2.4.fa WBD_Dissected_R1.pe.fq.gz | samtools sort -O BAM -o WBD_Dissected.align.bam -

# let's have a look at the mapping summary

samtools flagstat WBD_NoDissected.align.bam > WBD_NoDissected.mapping.stat
samtools flagstat WBD_Dissected.align.bam > WBD_Dissected.mapping.stat

# Even for the whole animal sequencing we're getting very low coverage of the host
# Still, let's go ahead and extract reads which do not map to the host genome
# first, we need to filter out mapped reads and then resort by name rather than coordinate

samtools view -b -f 4 WBD_NoDissected.align.bam | samtools sort -n -o WBD_NoDissected.name.bam -
samtools view -b -f 4 WBD_Dissected.align.bam | samtools sort -n -o WBD_Dissected.name.bam -

# Now, let's use bedtools to get the paired reads back out of the bam to do kmer analysis and assembly

bedtools bamtofastq -i WBD_NoDissected.name.bam -fq WBD_NoDissected_unmapped_R1.fq -fq2 BD_NoDissected_unmapped_R2.fq
bedtools bamtofastq -i WBD_Dissected.name.bam -fq WBD_Dissected_unmapped_R1.fq -fq2 BD_Dissected_unmapped_R2.fq

# let's also concatenate the left and right reads across the two libraries together and compress with pigz

cat WBD_NoDissected_unmapped_R1.fq WBD_Dissected_unmapped_R1.fq > WBD_unmapped_R1.fq
cat WBD_NoDissected_unmapped_R2.fq WBD_Dissected_unmapped_R2.fq > WBD_unmapped_R2.fq
pigz *.fq

# Now that we have our reads ready let's have a quick look a the kmer spectra to decide on how to select a kmer value for spades and velvet

ls -1 WBD_unmapped*.fq.gz > list_files
kmergenie list_files

# The optimal kmer appears to be 123 and an expected genome size in the neighborhood of 300kbp. Pretty big for a virus!

# let's start with spades for assembly; we could let spades let spades do default kmer behavior but that does not work well for this genome. 
# Here I provide a single example command for spades for what resulted in the most contiguous assembly. However, I tried k values up to 10 less
# than 123, iterating by 2. I couldn't go higher than 123 given the read length. k =  123 provided the best assembly.

spades.py -1 WBD_unmapped_R1.fq.gz -2 WBD_unmapped_R2.fq.gz -k 123 -m 125 -t 55 -o spades_K123

# The best assembly resulted in essentially two large contigs summing up to ~ 288kbp, with a bunch of very small contigs

# repeat assembly with velvet to see if we can get a single contig. As with spades, I tried the same range of kmer values

velveth velvet_123 123 -short -separate -fastq WBD_unmapped_R1.fq.gz WBD_unmapped_R2.fq.gz
velvetg velvet_123

# Again, k = 123 works best but we're still not getting a single contig. So we need to try to scaffold
# The spades and velvet assembly seem nearly the same. I'll go with the spades assembly but I don't think
# it will make any difference.

# To scaffold with BESST we need to start with mapping the reads to the assembly with bwa mem

bwa index spades_K123.fasta
bwa mem -t 55 spades_K123.fasta WBD_unmapped_R1.fq.gz WBD_unmapped_R2.fq.gz | samtools sort -O BAM -o spades_K123.sorted.bam -
samtools index spades_K123.sorted.bam

# Now, let's use this bam file for the scaffolding
runBESST -c spades_K123.fasta -f spades_K123.sorted.bam -o spades_K123.scaffold -orientation fr

# It worked! We now have a single large scaffold which merged the two largest contigs. However, we do have a gap of Ns. We will move to 
# polishing using Sanger seqeuncing. See manuscript for details.














