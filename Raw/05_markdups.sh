#!/bin/bash
#SBATCH --chdir=/storage/users/ccuffe22/atac/raw_datadata_hp
#SBATCH --job-name=markdups
#SBATCH --output=/storage/users/ccuffe22/atac/logfiles/markdups_%j.log
#SBATCH --mail-user=ccuffe22@rvc.ac.uk
#SBATCH --mail-type=END,FAIL
#SBATCH --mem=20gb #Change this depending on memory requirements
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1 #Change depending on CPU requirements

#Load java
module load apps/java-8u151.tcl

#To make conda enviro's work
module load apps/anaconda-4.7.12.tcl
eval "$(conda shell.bash hook)"

#enviro with samtools
conda activate align 
unset PYTHONPATH #because terminal is fussy

#make new folder for reads that have had duplicates marked

mkdir -p /storage/users/ccuffe22/atac/data_hp/05.markdups
cd /storage/users/ccuffe22/atac/data_hp/05.markdups

#Load picard and markdup
for i in SM SCDM; do
echo MD_$i
java -jar /storage/apps/picard/2.22.0/picard.jar MarkDuplicates \
      I= /storage/users/ccuffe22/atac/data_hp/04.mapped/sorted_135313_$i.bam \
      O= /storage/users/ccuffe22/atac/data_hp/05.markdups/MD_135313_$i.bam\
      M=marked_dup_metrics_$i.txt
      samtools flagstat /storage/users/ccuffe22/atac/data_hp/05.markdups/MD_135313_$i.bam \
      > /storage/users/ccuffe22/atac/data_hp/05.markdups/MD_135313_$i.stats
      samtools index  "/storage/users/ccuffe22/atac/data_hp/05.markdups/MD_135313SCDM.bam"

echo done MD_$i
done 

#actually remove the duplicates from the file for MACS3
mkdir -p /storage/users/ccuffe22/atac/data_hp/07.rmvdups/
cd /storage/users/ccuffe22/atac/data_hp/07.rmvdups/

names=(SM SCDM)
for i in "${names[@]}"; do
   echo $i
java -jar /storage/apps/picard/2.22.0/picard.jar MarkDuplicates \
      I= "/storage/users/ccuffe22/atac/data_hp/05.markdups/MD_135313_$i.bam" \
      O= "/storage/users/ccuffe22/atac/data_hp/07.rmvdups/nodupes_135313_$i.bam"\
      --REMOVE_DUPLICATES \
      M=removed_dup_metrics_$i.txt
      samtools index "/storage/users/ccuffe22/atac/data_hp/07.rmvdups/nodupes_135313_$i.bam"
      
echo done remove_dups_$i
done

#remove mitochondrial reads and other unmapped/not primary alignment esq reads
names=(SM SCDM)
for i in "${names[@]}"; do
    #write the mitochondrial reads to their own file and calculate stats on them nb to calculate % mitochondrial contamination
    samtools view -bh "/storage/users/ccuffe22/atac/data_hp/05.markdups/MD_135313_$i.bam" MT > "/storage/users/ccuffe22/atac/data_hp/07.rmvdups/mito_135313_$i.bam" # mt reads file
    samtools flagstat "/storage/users/ccuffe22/atac/data_hp/07.rmvdups/mito_135313_$i.bam" > "/storage/users/ccuffe22/atac/data_hp/07.rmvdups/mito_135313_$i.stats" #mt reads stats

    #remove any reads mapping to the mitochondrial chromosome or the aren't mapping to any chromosome
    #2820 removes reads flagged as unmapped, not primary alignment, failing platfrom/vendor QC checks and supplementary alignment
    samtools idxstats "/storage/users/ccuffe22/atac/data_hp/05.markdups/MD_135313_$i.bam" | cut -f 1 | grep -v "chrUn" | grep -v "MT" | xargs samtools view -bh -F 2820 \
    "/storage/users/ccuffe22/atac/data_hp/05.markdups/MD_135313_$i.bam" \
    > "/storage/users/ccuffe22/atac/data_hp/07.rmvdups/nodupes_135313_$i.bam" #remove mit + unaligned reads
    samtools index "/storage/users/ccuffe22/atac/data_hp/07.rmvdups/nodupes_135313_$i.bam" #index the output file
    done
conda deactivate
conda deactivate