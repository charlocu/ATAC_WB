#!/bin/bash
#SBATCH --chdir=/storage/users/ccuffe22/atac/raw_data/05.markdups/
#SBATCH --job-name=indexing
#SBATCH --output=/storage/users/ccuffe22/atac/logfiles/scratch_%j.log
#SBATCH --error=/storage/users/ccuffe22/atac/logfiles/scratch_%j.err
#SBATCH --mail-user=ccuffe22@rvc.ac.uk
#SBATCH --mail-type=END,FAIL
#SBATCH --mem=3gb #Change this depending on memory requirements
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1 #Change depending on CPU requirements

module load apps/anaconda-4.7.12.tcl
eval "$(conda shell.bash hook)"
conda activate align 

unset PYTHONPATH

names=(SM SCDM)
for i in "${names[@]}"; do
    echo $i
#java -jar /storage/apps/picard/2.22.0/picard.jar MarkDuplicates \
 #     I= "/storage/users/ccuffe22/atac/data/05.markdups/MD_135313_$i.bam" \
  #    O= "/storage/users/ccuffe22/atac/data/07.rmvdups/filtered_135313_$i.bam"\
   #   --REMOVE_DUPLICATES \
    #  M=removed_dup_metrics_$i.txt
      done
#samtools

#module load libs/htslib-1.2.1.tcl

#samtools index  "/storage/users/ccuffe22/atac/data/04.mapped/MD_135313SCDM.bam"
#samtools index  "/storage/users/ccuffe22/atac/data/04.mapped/MD_135313SM.bam"

conda deactivate