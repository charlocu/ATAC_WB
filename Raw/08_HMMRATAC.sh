#!/bin/bash
#SBATCH --chdir=/storage/users/ccuffe22/atac/data
#SBATCH --job-name=HMMRATAC
#SBATCH --output=/storage/users/ccuffe22/atac/logfiles/HMMRATAC_%j.log
#SBATCH --mail-user=ccuffe22@rvc.ac.uk
#SBATCH --mail-type=END,FAIL
#SBATCH --mem=12gb #Change this depending on memory requirements
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=3 #Change depending on CPU requirements

#To make conda enviro's work
module load apps/anaconda-4.7.12.tcl
eval "$(conda shell.bash hook)"

module load apps/java-8u151.tcl


#enviro with samtools
#conda activate align 
mkdir -p /storage/users/ccuffe22/atac/data/08.hmmratac

#this is the old HMMRATAC, so going to comment it all out but it is the first thing I tried

#should already have the bam straight from the aligner (here in 04. data file)
#This bam should be sorted and have an index made
#next step is step 3 of file prep
#Genome information file for chromosome sizes
#samtools view -H "/storage/users/ccuffe22/atac/data/04.mapped/sorted_135313SCDM.bam" |\
#perl -ne 'if(/^@SQ.*?SN:(\w+)\s+LN:(\d+)/){print $1,"\t",$2,"\n"}' \
#> "/storage/users/ccuffe22/atac/data/08.hmmratac/genome.info"

#conda deactivate
#now to begin the actual peak calling
#for i in 135313SCDM 135313SM; do
#java -jar "/storage/users/ccuffe22/software/HMMRATAC_V1.2.10_exe.jar" \
#-b "/storage/users/ccuffe22/atac/data/04.mapped/sorted_$i.bam" \
#-i "/storage/users/ccuffe22/atac/data/04.mapped/sorted_$i.bam.bai" \
#-g "/storage/users/ccuffe22/atac/data/08.hmmratac/genome.info" \
#-o "/storage/users/ccuffe22/atac/data/08.hmmratac/$i"
#done

unset PYTHONPATH
#To start going to jusdge the cut-off values for the analysis (nucleosome length etc)
#Can pool multiple samples together by naming them altogether in the -b arguement with spaces in between
conda activate MACS
for i in 135313SCDM 135313SM; do
macs3 hmmratac --cutoff-analysis-only -b "/storage/users/ccuffe22/atac/data/04.mapped/sorted_$i.bam" \
--outdir "/storage/users/ccuffe22/atac/data/08.hmmratac/" \
-n "$i_cutoff_analysis" 
done
conda deactivate
