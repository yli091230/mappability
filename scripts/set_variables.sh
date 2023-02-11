#!/bin/bash

export PATH=/expanse/protected/gymreklab-dbgap/mount/yal084/Cynthia_project/mappability/tools/bowtie-1.2.2-linux-x86_64:$PATH


######################set path#####################
# gene annotation file name with full path
gene_annot_fn=/expanse/protected/gymreklab-dbgap/mount/yal084/Cynthia_project/mappability/rat_ref/Rattus_norvegicus.Rnor_6.0.99.gtf
# directory of genome splitted by chromosome 
genome_dir=/expanse/protected/gymreklab-dbgap/mount/yal084/Cynthia_project/mappability/rat_ref/rn60_by_chromosome
# bowtie index prefix name with full path
bowtie_index_prefix=/expanse/protected/gymreklab-dbgap/mount/yal084/Cynthia_project/mappability/rat_ref/rat_ref_bowtie_index/Rn6
# k for exon and utr, change if you use different k
exon_k=75
utr_k=36
# bedgraph files containing k-mer mappabilities with appropriate k
exon_kmer_mappability_fn=/expanse/protected/gymreklab-dbgap/mount/yal084/Cynthia_project/mappability/rat_ref/rat_ref_indexed/mappability_75mer_2mismatch.bed
utr_kmer_mappability_fn=/expanse/protected/gymreklab-dbgap/mount/yal084/Cynthia_project/mappability/rat_ref/rat_ref_indexed/mappability_36mer_2mismatch.bed
# maximum number of mismatches for an alignment
mismatch=2

# put the directory of this program here
prog_dir=/expanse/protected/gymreklab-dbgap/mount/yal084/Cynthia_project/crossmap
# put your computation directory here
comp_dir=/expanse/protected/gymreklab-dbgap/mount/yal084/Cynthia_project/mappability/rat_cross_mappability_75exon_36intron_2mismatch

# maximum number of chromosomes to load in memory at a time
max_chr=7
# maximum number of genes to align before cleaning alignments
max_gene_alignment=200
# length of the sub-directory names. First dir_len letters from gene
dir_name_len=12
# verbose output? 1 for verbose, 0 for non-verbose
verbose=1

# script and log directories
script_dir="$comp_dir/script"
log_dir="$comp_dir/log"
if [ ! -d $script_dir ]; then mkdir -p $script_dir; fi
if [ ! -d $log_dir ]; then mkdir -p $log_dir; fi
#

# slurm utility
use_slurm=0  # use slurm (1: use, 0: don't use)

slurm_partition="ind-shared"
source $prog_dir/slurm_util.sh
run_script()
{
  # if slurm is not used
  # this function expects only one argument:
  # the script file.

  # if slurm is used,
  # this function expects 6 arguments:
  # 1) script file, 2) partition, 3) no. of nodes,
  # 4) no. of tasks, 5) time to run, 6) memory

  if [ $# -lt 1 ]; then
    echo "no script to run";
    return 1;
  fi
  script_fn=$1

  if [ $use_slurm -eq 1 ]; then
    submit_slurm_job $@
  else
    sh $script_fn
  fi

  return 0
}

################ Processing the annotation data###########
# Setting up the path
annot_dir="$comp_dir/annot"
features="exon,five_prime_utr,three_prime_utr"
exon_utr_annot_fn="$annot_dir/annot.exon_utr.txt"
script_fn="${script_dir}/gtf_to_txt.sh"
log_fn="${log_dir}/gtf_to_txt.log"

#if [ ! -d $annot_dir ]; then mkdir -p $annot_dir; fi
#
#echo "Rscript \"$prog_dir/gtf_to_txt.R\" --gtf \"$gene_annot_fn\" \
#                     -f \"$features\" \
#                     -o \"$exon_utr_annot_fn\" \
#                     2>&1 | tee \"$log_fn\"" > "$script_fn"
#run_script "$script_fn" $slurm_partition 1 1 "0:10:0" "8GB"
## Time: 3 min

###################Generate gene-mappability from k-mer mappability
mappability_dir="$comp_dir/gene_mappability"
mappability_fn="$mappability_dir/gene_mappability.txt"
script_fn="${script_dir}/compute_mappability.sh"
log_fn="${log_dir}/compute_mappability.log"

if [ ! -d $mappability_dir ] ; then mkdir -p $mappability_dir ; fi

## create script and run it
#echo "Rscript \"$prog_dir/compute_mappability.R\" \
#			      --annot \"$exon_utr_annot_fn\" \
#                              --k_exon $exon_k \
#                              --k_utr $utr_k \
#                              --kmap_exon \"$exon_kmer_mappability_fn\" \
#                              --kmap_utr \"$utr_kmer_mappability_fn\" \
#                              --verbose $verbose \
#                              -o \"$mappability_fn\" \
#                              2>&1 | tee \"$log_fn\"" > "$script_fn"
#run_script "$script_fn" $slurm_partition 1 1 "0:40:0" "20GB"
## Memory: 20GB, Time: 40 min

######################## Generate ambiguous k-mers
ambiguous_kmer_dir="$comp_dir/ambiguous_kmers"
mappability_th1=0
mappability_th2=1
script_fn="${script_dir}/generate_ambiguous_kmers.sh"
log_fn="${log_dir}/generate_ambiguous_kmers.log"

if [ ! -d $ambiguous_kmer_dir ] ; then mkdir -p $ambiguous_kmer_dir ; fi

## create script and run it
#echo "Rscript \"$prog_dir/generate_ambiguous_kmers.R\"  --mappability \"$mappability_fn\" \
#                                    --genome \"$genome_dir\" \
#                                    --annot \"$exon_utr_annot_fn\" \
#                                    --k_exon $exon_k \
#                                    --k_utr $utr_k \
#                                    --kmap_exon \"$exon_kmer_mappability_fn\" \
#                                    --kmap_utr \"$utr_kmer_mappability_fn\" \
#                                    --th1 $mappability_th1 \
#                                    --th2 $mappability_th2 \
#                                    --dir_name_len $dir_name_len \
#                                    --verbose $verbose \
#                                    -o \"$ambiguous_kmer_dir\" \
#                                    2>&1 | tee \"$log_fn\"" > "$script_fn"
#run_script "$script_fn" $slurm_partition 1 1 "1:0:0" "20GB"
## Time: 40 min
#
#
## create k-mer fasta file, need ambiguous k-mers in fasta file to align them to the genome using bowtie
#echo "start change name"
#for fn in "$ambiguous_kmer_dir"/*/*.kmer.txt
#do
#  fasta_fn=$(echo $fn | sed 's/.txt$/.fa/g')
#  awk -v i=-1 '{i += 1 ; print ">"i ; print}' < $fn > $fasta_fn
#done
## Time: 10 min

############################## Compute cross-mappability 
# specification
alignment_dir="$comp_dir/ambiguous_kmers_alignment"
cross_mappability_dir="$comp_dir/cross_mappability"
n_gene_per_crossmap_batch=2000

if [ ! -d "$alignment_dir" ] ; then mkdir -p "$alignment_dir" ; fi
if [ ! -d "$cross_mappability_dir" ] ; then mkdir -p "$cross_mappability_dir" ; fi

##############initialize resources to compute cross-mappability (-initonly TRUE)
script_fn="${script_dir}/compute_cross_mappability_1_init.sh"
log_fn="${log_dir}/compute_cross_mappability_1_init.log"
#echo "Rscript \"$prog_dir/compute_cross_mappability.R\" --annot \"$exon_utr_annot_fn\" \
#                                    --mappability \"$mappability_fn\" \
#                                    --kmer \"$ambiguous_kmer_dir\" \
#                                    --align \"$alignment_dir\" \
#                                    --index \"$bowtie_index_prefix\" \
#                                    --n1 1 \
#                                    --n2 $n_gene_per_crossmap_batch \
#                                    --mismatch $mismatch \
#                                    --max_chr $max_chr \
#                                    --max_gene $max_gene_alignment \
#                                    --initonly TRUE \
#                                    --dir_name_len $dir_name_len \
#                                    --verbose $verbose \
#                                    -o \"$cross_mappability_dir\" \
#                     2>&1 | tee \"$log_fn\"" > "$script_fn"
#run_script "$script_fn" $slurm_partition 1 1 "1:30:0" "12GB"
# Memory: 6GB, Time: 45 min

# actually compute cross-mappability (-initonly FALSE)
n_gene_in_mappability_file=$(wc -l $mappability_fn | sed 's/ .*//g')
for n1 in $(seq 1 $n_gene_per_crossmap_batch $n_gene_in_mappability_file)
do
  n2=$(($n1+$n_gene_per_crossmap_batch-1))
  script_fn="${script_dir}/compute_cross_mappability_2_${n1}_${n2}.sh"
  log_fn="${log_dir}/compute_cross_mappability_2_${n1}_${n2}.log"
  echo "Rscript \"$prog_dir/compute_cross_mappability.R\" --annot \"$exon_utr_annot_fn\" \
                                      --mappability \"$mappability_fn\" \
                                      --kmer \"$ambiguous_kmer_dir\" \
                                      --align \"$alignment_dir\" \
                                      --index \"$bowtie_index_prefix\" \
                                      --n1 $n1 \
                                      --n2 $n2 \
                                      --mismatch $mismatch \
                                      --max_chr $max_chr \
                                      --max_gene $max_gene_alignment \
                                      --initonly FALSE \
                                      --dir_name_len $dir_name_len \
                                      --verbose $verbose \
                                      -o \"$cross_mappability_dir\" \
                                      2>&1 | tee \"$log_fn\"" > "$script_fn"
  run_script "$script_fn" $slurm_partition 1 1 "48:0:0" "20GB"
  # Memory: 14GB, Time: 35 hours
done
echo "################Finish cross-mappability computation##################"
# combine all cross-mappability results into one file
combined_cross_mappability_fn="$comp_dir/cross_mappability.txt"
if [ -f $combined_cross_mappability_fn ]; then rm "$combined_cross_mappability_fn";  fi
for fn in "$cross_mappability_dir"/*/*.crossmap.txt
do
  cat $fn >> "$combined_cross_mappability_fn"
done
