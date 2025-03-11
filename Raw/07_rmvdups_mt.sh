#!/bin/bash
#SBATCH --job-name=rmvdups
#SBATCH --output=/storage/users/ccuffe22/atac/logfiles/rmv_dups_%j.log
#SBATCH --mail-user=ccuffe22@rvc.ac.uk
#SBATCH --mail-type=END,FAIL
#SBATCH --mem=60gb #Change this depending on memory requirements
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=3 #Change depending on CPU requirements


module load apps/java-8u151.tcl
module load apps/anaconda-4.7.12.tcl
eval "$(conda shell.bash hook)"
conda activate align #environment with samtools

#in this 
mkdir -p /storage/users/ccuffe22/atac/data_hp/07.rmvdups

#want to remove any duplicates that were marked previously
cd "/storage/users/ccuffe22/atac/data_hp/04.mapped/"
unset PYTHONPATH
for i in $(ls sorted_C*.bam); do echo $i; 
    j=$(echo $i | cut -f2 -d '_') k=$(echo $j | cut -f1 -d '.'); 
    java -jar /storage/apps/picard/2.22.0/picard.jar MarkDuplicates \
      I="/storage/users/ccuffe22/atac/data_hp/04.mapped/$i" \
      O="/storage/users/ccuffe22/atac/data_hp/07.rmvdups/rmvdups_$j"\
      REMOVE_DUPLICATES=TRUE \
      M=removed_dup_metrics_$k.txt 
      samtools flagstat "/storage/users/ccuffe22/atac/data_hp/07.rmvdups/rmvdups_$j" > "/storage/users/ccuffe22/atac/data_hp/07.rmvdups/rmvdups_$k.stats"
      done

cd /storage/users/ccuffe22/atac/data_hp/07.rmvdups
#Choosing to remove mito reads etc from the file that has already had duplicates removed

for i in $(ls rmvdups_C*.bam); do echo $i; 
    j=$(echo $i | cut -f2 -d '_') k=$(echo $j | cut -f1 -d '.'); 
    samtools index $i
    #write the mitochondrial reads to their own file and calculate stats on them
    samtools view -bh $i MT > "/storage/users/ccuffe22/atac/data_hp/07.rmvdups/mito_$j" # mt reads file
    samtools flagstat "/storage/users/ccuffe22/atac/data_hp/07.rmvdups/mito_$j" > "/storage/users/ccuffe22/atac/data_hp/07.rmvdups/mito_$k.stats" #mt reads stats

   
    #remove any reads mapping to the mitochondrial chromosome or the aren't mapping to any chromosome
    #2820 removes reads flagged as unmapped, not primary alignment, failing platfrom/vendor QC checks and supplementary alignment
    samtools idxstats $i | cut -f 1 | grep -v "chrUn" | grep -v "MT" | xargs samtools view -bh -F 2820 \
    $i > "/storage/users/ccuffe22/atac/data_hp/07.rmvdups/filtered_$j" #remove mit + unaligned reads
    samtools index "/storage/users/ccuffe22/atac/data_hp/07.rmvdups/filtered_$j" #index the output file
    done
conda deactivate
