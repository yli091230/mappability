# Compute the cross mappability for rat genome
1. Reference genome versions and other details can be found in [RatGTExPortal](https://ratgtex.org/about/).
	1. Libraries were sequenced using 150-bp paired-end sequencing. 
2. Cross-mappability calculated based on [original for human](https://github.com/battle-lab/crossmap), [modified for rat](https://github.com/yli091230/crossmap)
## Preparation of files
	1. Run gem_index.sh to index genome, take about 1 hour to index whole rat genome.
	* Need to make a copy of reference genome that splitted by chromosome for downstream analysis.
	* Using 12G memory.
	* The BigWig output contains a column with dna, need to remove this column for downstream process.
	* The paper tested different lengths of k-mer but didn't provide any details about how to choose k-mer. Based on the descrition, they use the read length as the length for exon. So we are going to use the same setting here.
	2. Potential issues:
	* The paper build index using Bowtie which may not aware of the splicing event.
	3. Download bowtie 1.2.2 and index genemo using command `bowtiew-build <ref_genome> <prefix>`.
	* Bowtie does not work in Expanse, not sure why. Build index in snorlax.
## Compute Cross-mappability 
1. Modules need to be load :
* R: r/4.0.2-openblas, cpu/0.15.4  gcc/9.2.0
* Modifications to the cross_mappability repository:
	1. For all Rscript, need the change the argpharser - to --
	2. Need to install library, using env.R files. Add library path to all scripts.
	3. In the compute_mappability.R and gtf_to_bed.R, need to  change the code to get the utr in rat gtf which specified as 'three_prime_utr', 'five_prime_utr'.
	4. In the compute_mappability.R, the rat ref genome contains more contigs, some contigs only exist in exon, need to change the code avoid error message.
* Export bowtie path

2. Run set_variables.sh in an interactive node 
