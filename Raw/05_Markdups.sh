#!/bin/bash
#SBATCH --chdir=/storage/users/ccuffe22/atac/raw_data
#SBATCH --job-name=markdups
#SBATCH --output=/storage/users/ccuffe22/atac/raw_data/fastqc_%j.log
#SBATCH --mail-user=ccuffe22@rvc.ac.uk
#SBATCH --mail-type=END,FAIL
#SBATCH --mem=3gb #Change this depending on memory requirements
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1 #Change depending on CPU requirements

#Load java
module load apps/java-8u151.tcl

#To make conda enviro's work
module load apps/anaconda-4.7.12.tcl
eval "$(conda shell.bash hook)"

#enviro containing samtools
conda activate align 

#Load picard and markdup
java -jar apps/picard-2.22.0.tcl MarkDuplicates \
      I= "/storage/users/ccuffe22/atac/data/04.mapped/sorted_135313SM.bam" \
      O= "/storage/users/ccuffe22/atac/data/04.mapped/MD_135313SM.bam"\
      M=marked_dup_metrics_SM.txt
      samtools flagstat "/storage/users/ccuffe22/atac/data/04.mapped/MD_135313SM.bam" \
> "/storage/users/ccuffe22/atac/data/04.mapped/MD_135313SM.stats"

java -jar apps/picard-2.22.0.tcl MarkDuplicates \
      I= "/storage/users/ccuffe22/atac/data/04.mapped/sorted_135313SCDM.bam" \
      O= "/storage/users/ccuffe22/atac/data/04.mapped/MD_135313SCDM.bam"\
      M=marked_dup_metrics_SCDM.txt

      samtools flagstat "/storage/users/ccuffe22/atac/data/04.mapped/MD_135313SCDM.bam" \
> "/storage/users/ccuffe22/atac/data/04.mapped/MD_135313SCDM.stats"

#index again the newest file
samtools index "/storage/users/ccuffe22/atac/data/04.mapped/MD_135313SM.bam"
samtools index "/storage/users/ccuffe22/atac/data/04.mapped/MD_135313SCDM.bam"