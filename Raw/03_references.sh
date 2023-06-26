#!/bin/bash
#SBATCH --chdir=/storage/users/ccuffe22/atac/raw_data/
#SBATCH --job-name=ref
#SBATCH --output=/storage/users/ccuffe22/atac/logfiles/filtering_%j.log
#SBATCH --mail-user=ccuffe22@rvc.ac.uk
#SBATCH --mail-type=END,FAIL
#SBATCH --mem=24gb #Change this depending on memory requirements
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4 #Change depending on CPU requirements

#module admin and code to allow us to activate/deactivate conda environments
module load apps/anaconda-4.7.12.tcl
eval "$(conda shell.bash hook)"
conda activate align 

#Load BWA app
module load apps/bwa-0.7.10.tcl

#Index reference genome using BWA
bwa index "/storage/users/ccuffe22/references/Equus_caballus.EquCab3.0.dna.toplevel.fa.gz"

#Index ref with samtools
samtools  faidx "/storage/users/ccuffe22/references/Equus_caballus.EquCab3.0.dna.toplevel.fa.gz"

#Load java
module load apps/java-8u151.tcl

#Generate sequence dictionary
java -jar /storage/apps/picard/2.22.0/picard.jar CreateSequenceDictionary \
R="/storage/users/ccuffe22/references/Equus_caballus.EquCab3.0.dna.toplevel.fa.gz" \
O=/storage/users/ccuffe22/references/Equus_caballus.EquCab3.0.dna.toplevel.dict

#Download variation file manually

#Sort the vcf file with Picard
java -jar /storage/apps/picard/2.22.0/picard.jar SortVcf \
I="/storage/users/ccuffe22/references/equus_caballus_incl_consequences.vcf.gz" \
O=/storage/users/ccuffe22/references/equcab_incl_consequences_sorted.vcf \
SEQUENCE_DICTIONARY=/storage/users/ccuffe22/references/Equus_caballus.EquCab3.0.dna.toplevel.dict

conda deactivate