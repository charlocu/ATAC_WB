#!/bin/bash
#SBATCH --chdir=/storage/users/ccuffe22/atac/raw_data/
#SBATCH --job-name=mapping
#SBATCH --output=/storage/users/ccuffe22/atac/logfiles/filtering_%j.log
#SBATCH --mail-user=ccuffe22@rvc.ac.uk
#SBATCH --mail-type=END,FAIL
#SBATCH --mem=16gb #Change this depending on memory requirements
#SBATCH --ntasks=8
#SBATCH --cpus-per-task=1 #Change depending on CPU requirements

module load apps/anaconda-4.7.12.tcl
eval "$(conda shell.bash hook)"
conda activate align 

#Load BWA app
#module load apps/bwa-0.7.10.tcl

#Do for each sample
#Map paired forward and reverse trimmed reads to the reference genome - the '-t' flag needs to match the number of CPUs above in the header
#bwa mem "/storage/users/ccuffe22/references/Equus_caballus.EquCab3.0.dna.toplevel.fa.gz" \
 # "/storage/users/ccuffe22/atac/data/03.pre-processing/trimmed_WB135313_SM_1.fq.gz" \
  #"/storage/users/ccuffe22/atac/data/03.pre-processing/trimmed_WB135313_SM_2.fq.gz" \
  #-t [8] -M | samtools sort -o "/storage/users/ccuffe22/atac/data/04.mapped/sorted_135313SM.bam" \
  #-O bam -T "/storage/users/ccuffe22/temp"
#samtools flagstat "/storage/users/ccuffe22/atac/data/04.mapped/sorted_135313SM.bam" \
#> "/storage/users/ccuffe22/atac/data/04.mapped/sorted_135313SM.stats"

#for sample #2 now, SCDM  
#  bwa mem "/storage/users/ccuffe22/references/Equus_caballus.EquCab3.0.dna.toplevel.fa.gz" \
#  "/storage/users/ccuffe22/atac/data/03.pre-processing/trimmed_WB135313_SCDM_1.fq.gz" \
#  "/storage/users/ccuffe22/atac/data/03.pre-processing/trimmed_WB135313_SCDM_2.fq.gz" \
#  -t [8] -M | samtools sort -o "/storage/users/ccuffe22/atac/data/04.mapped/sorted_135313SCDM.bam" \
#  -O bam -T "/storage/users/ccuffe22/temp"
#samtools flagstat "/storage/users/ccuffe22/atac/data/04.mapped/sorted_135313SCDM.bam" \
#> "/storage/users/ccuffe22/atac/data/04.mapped/sorted_135313SCDM.stats"

#Samtools indexing
samtools index "/storage/users/ccuffe22/atac/data/04.mapped/sorted_135313SM.bam"
samtools index "/storage/users/ccuffe22/atac/data/04.mapped/sorted_135313SCDM.bam"

conda deactivate