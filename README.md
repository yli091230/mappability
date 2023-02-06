# Compute the cross mappability for rat genome
1. Reference genome versions and other details can be found in [RatGTExPortal](https://ratgtex.org/about/).
2. Cross-mappability calculated based on [this](https://github.com/battle-lab/crossmap)i
	1. Run gem_index.sh to index genome, take about 1 hour to index whole rat genome.
		* Using 12G memory.
		* The BigWig output contains a column with dna, need to remove this column for downstream process.
	2. Download bowtie 1.2.2 and index genemo using command `bowtiew-build <ref_genome> <prefix>`.
