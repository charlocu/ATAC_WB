#!/bin/bash
#SBATCH --chdir=/storage/users/ccuffe22/atac/data/06b.qc
#SBATCH --job-name=QC
#SBATCH --output=/storage/users/ccuffe22/atac/logfiles/intersect_%j.log
#SBATCH --mail-user=ccuffe22@rvc.ac.uk
#SBATCH --mail-type=END,FAIL
#SBATCH --mem=12gb #Change this depending on memory requirements
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1 #Change depending on CPU requirements

mkdir -p /storage/users/ccuffe22/atac/data/06b.qc
unset PYTHONPATH
#trying to make individual gtf files for the different features to assess number of reads overlapping each type
#first separating out the gtf file into files for exons and genes 

 #grep -w 'gene' /storage/users/ccuffe22/references/Equus_caballus.EquCab3.0.110.gtf > /storage/users/ccuffe22/references/equine_genes.gtf
 #grep -w 'exon' /storage/users/ccuffe22/references/Equus_caballus.EquCab3.0.110.gtf > /storage/users/ccuffe22/references/equine_exons.gtf

#second seeing if they interesct with the bam files, and count how many reads overlap
#will be using bedtools for this
#convert gtf to bed files first before bedtools


"/storage/users/ccuffe22/software/GFFUtils-0.12.0/" gtf2bed "/storage/users/ccuffe22/references/equine_exons.gtf" > "/storage/users/ccuffe22/references/equine_exons.bed"
"/storage/users/ccuffe22/software/GFFUtils-0.12.0/" gtf2bed "/storage/users/ccuffe22/references/equine_genes.gtf" > "/storage/users/ccuffe22/references/equine_genes.bed" 

#now for bedtools intersect

module load apps/bedtools-2.29.tcl

for i in SM SCDM; do
    bedtools intersect -wo -a "/storage/users/ccuffe22/atac/data/07.rmvdups/filtered_135313_$i.bam" -b "/storage/users/ccuffe22/references/equine_exons.bed" , "/storage/users/ccuffe22/references/equine_genes.bed" -sorted -names gene,exon -f 0.5 -C 
done