#!/bin/bash

#add tools to path
export PATH=/expanse/protected/gymreklab-dbgap/mount/yal084/Cynthia_project/mappability/tools/GEM-binaries-Linux-x86_64-core_i3-20130406-045632/bin:$PATH
export PATH=/expanse/protected/gymreklab-dbgap/mount/yal084/Cynthia_project/mappability/tools/ucsc_binary:$PATH
genome_fasta=/expanse/protected/gymreklab-dbgap/mount/yal084/Cynthia_project/mappability/rat_ref/Rattus_norvegicus.Rnor_6.0.dna.toplevel.fa

#GRCh37_v19/ref_all_chr/chr22.fa


k=75
n_mismatch=2
n_threads=2
output_dir=/expanse/protected/gymreklab-dbgap/mount/yal084/Cynthia_project/mappability/rat_ref/rat_ref_indexed
#GRCh37_v19/ref_all_chr_indexed
gem_index_pref=gem_indexed_${k}mer
gem_mappability_pref=mappability_${k}mer_2mismatch

#set -e
#echo "start index"
#time gem-indexer -T ${n_threads} -c dna -i ${genome_fasta} -o "${output_dir}/${gem_index_pref}"
#echo "finish index and comput mappability"
#time gem-mappability -m ${n_mismatch} -T ${n_threads} -I ${output_dir}/${gem_index_pref}.gem -l ${k} -o ${output_dir}/${gem_mappability_pref}
#echo "Done mappability,convert gem to wig"
#gem-2-wig -I ${output_dir}/${gem_index_pref}.gem -i ${output_dir}/${gem_mappability_pref}.mappability -o ${output_dir}/${gem_mappability_pref}
echo "Covert wig to BigWig"
wigToBigWig ${output_dir}/${gem_mappability_pref}_cleaned.wig ${output_dir}/${gem_mappability_pref}_cleaned.sizes ${output_dir}/${gem_mappability_pref}.bigwig
echo "covert bigWig to BedGrap"
bigWigToBedGraph ${output_dir}/${gem_mappability_pref}.bigwig ${output_dir}/${gem_mappability_pref}.bed
echo "All done"
