#!/bin/bash
#SBATCH --job-name=rmvdups
#SBATCH --output=/storage/users/ccuffe22/atac/logfiles/align_QC_%j.log
#SBATCH --mail-user=ccuffe22@rvc.ac.uk
#SBATCH --mail-type=END,FAIL
#SBATCH --mem=24gb #Change this depending on memory requirements
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=3 #Change depending on CPU requirements


module load apps/java-8u151.tcl
module load apps/anaconda-4.7.12.tcl
eval "$(conda shell.bash hook)"
conda activate align #environment with samtools

#in this 
#mkdir /storage/users/ccuffe22/atac/data/07.rmvdups

#want to remove any duplicates that were marked previously

unset PYTHONPATH
names=(SM SCDM)
for i in "${names[@]}"; do
    java -jar /storage/apps/picard/2.22.0/picard.jar MarkDuplicates \
      I="/storage/users/ccuffe22/atac/data/05.markdups/MD_135313_$i.bam" \
      O="/storage/users/ccuffe22/atac/data/07.rmvdups/filtered_135313_$i.bam"\
      REMOVE_DUPLICATES=TRUE \
      M=removed_dup_metrics_$i.txt
      done


for i in "${names[@]}"; do
    #write the mitochondrial reads to their own file and calculate stats on them
    samtools view -bh "/storage/users/ccuffe22/atac/data/05.markdups/MD_135313_$i.bam" MT > "/storage/users/ccuffe22/atac/data/07.rmvdups/mito_135313_$i.bam" # mt reads file
    samtools flagstat "/storage/users/ccuffe22/atac/data/07.rmvdups/mito_135313_$i.bam" > "/storage/users/ccuffe22/atac/data/07.rmvdups/mito_135313_$i.stats" #mt reads stats

    #remove any reads mapping to the mitochondrial chromosome or the aren't mapping to any chromosome
    #2820 removes reads flagged as unmapped, not primary alignment, failing platfrom/vendor QC checks and supplementary alignment
    samtools idxstats "/storage/users/ccuffe22/atac/data/05.markdups/MD_135313_$i.bam" | cut -f 1 | grep -v "chrUn" | grep -v "MT" | xargs samtools view -bh -F 2820 \
    "/storage/users/ccuffe22/atac/data/05.markdups/MD_135313_$i.bam" \
    > "/storage/users/ccuffe22/atac/data/07.rmvdups/filtered_135313_$i.bam" #remove mit + unaligned reads
    samtools index "/storage/users/ccuffe22/atac/data/07.rmvdups/filtered_135313_$i.bam" #index the output file
    done
conda deactivate
