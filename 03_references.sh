#!/bin/bash
#SBATCH --chdir=/storage/users/ccuffe22/atac/raw_data/
#SBATCH --job-name=ref
#SBATCH --output=/storage/users/ccuffe22/atac/logfiles/filtering_%j.log
#SBATCH --mail-user=ccuffe22@rvc.ac.uk
#SBATCH --mail-type=END,FAIL
#SBATCH --mem=3gb #Change this depending on memory requirements
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1 #Change depending on CPU requirements


#Load BWA app
module load apps/bwa-0.7.10.tcl

#Index reference genome using BWA
bwa index "/storage/users/ccuffe22/references/Equus_caballus.EquCab3.0.dna.toplevel.fa.gz"

#Index ref with samtools
apps/samtools-1.9.tcl  faidx "/storage/users/ccuffe22/references/Equus_caballus.EquCab3.0.dna.toplevel.fa.gz"

#Load java
module load apps/java-8u151.tcl

#Generate sequence dictionary
java -jar apps/picard-2.22.0.tcl  CreateSequenceDictionary R="/storage/users/ccuffe22/references/Equus_caballus.EquCab3.0.dna.toplevel.fa.gz" \
O=/storage/users/ccuffe22/references/Equus_caballus.EquCab3.0.dna.toplevel.dict

#Download variation file as a VCF or download manually
#wget ftp://ftp.ensembl.org/[path/to/variation.vcf]

#Sort the vcf file with Picard
java -jar apps/picard-2.22.0.tcl  SortVcf I="/storage/users/ccuffe22/references/equus_caballus_incl_consequences.vcf.gz" \
O=/storage/users/ccuffe22/references/equcab_incl_consequences_sorted.vcf \
SEQUENCE_DICTIONARY=/storage/users/ccuffe22/references/Equus_caballus.EquCab3.0.dna.toplevel.dict