#!/bin/bash
#SBATCH --chdir=/storage/users/ccuffe22/atac/raw_data/
#SBATCH --job-name=mapping
#SBATCH --output=/storage/users/ccuffe22/atac/logfiles/filtering_%j.log
#SBATCH --mail-user=ccuffe22@rvc.ac.uk
#SBATCH --mail-type=END,FAIL
#SBATCH --mem=16gb #Change this depending on memory requirements
#SBATCH --ntasks=8
#SBATCH --cpus-per-task=1 #Change depending on CPU requirements

#Load BWA app
module load apps/bwa-0.7.10.tcl

#Map paired forward and reverse trimmed reads to the reference genome - the '-t' flag needs to match the number of CPUs above in the header
bwa mem [/path/to/reference.fa] \
  [/path/to/file_R1_paired.fastq.gz] \
  [/path/to/file_R2_paired.fastq.gz] \
  -t [8] | [/path/to/samtools] sort -o [/path/to/output.bam] \
  -O bam -T [/path/to/temp_output.deleteme-g]

#Samtools indexing
[/path/to/samtools] index [/path/to/output.bam]