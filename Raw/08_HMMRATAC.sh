#!/bin/bash
#SBATCH --chdir=/storage/users/ccuffe22/atac/data
#SBATCH --job-name=HMMRATAC
#SBATCH --output=/storage/users/ccuffe22/atac/logfiles/HMMRATAC_%j.log
#SBATCH --mail-user=ccuffe22@rvc.ac.uk
#SBATCH --mail-type=END,FAIL
#SBATCH --mem=30gb #Change this depending on memory requirements
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=3 #Change depending on CPU requirements

#To make conda enviro's work
module load apps/anaconda-4.7.12.tcl
eval "$(conda shell.bash hook)"
module load apps/java-8u151.tcl 
mkdir -p /storage/users/ccuffe22/atac/data_hp/08.hmmratac
unset PYTHONPATH
cd "/storage/users/ccuffe22/atac/data_hp/07.rmvdups/"
conda activate MACS

#NB Each step to be run separately from each other so different parts of the script will need to be commented out and uncommented depending

#To start going to jusdge the cut-off values for the analysis (nucleosome length etc)
#Can pool multiple samples together by naming them altogether in the -b arguement with spaces in between
for i in $(ls filtered_*.bam);do echo $i;
macs3 hmmratac --cutoff-analysis-only -b "/storage/users/ccuffe22/atac/data_hp/07.rmvdups/$i"  \
--outdir "/storage/users/ccuffe22/atac/data_hp/08.hmmratac/" \
-n individual_hp_$i
done

#then run the programme to begin finetunning cutoffs
#macs3 hmmratac -b "/storage/users/ccuffe22/atac/data_hp/07.rmvdups/filtered_135313_SCDM.bam" "/storage/users/ccuffe22/atac/data_hp/07.rmvdups/filtered_135313_SM.bam" \
#--outdir "/storage/users/ccuffe22/atac/data_hp/08.hmmratac/" \
#-u 10000 \
#-l 1000 \
#-c 50 \
#-n combined


#trying it with the two samples being called separately
#for i in SCDM SM; do
#macs3 hmmratac --cutoff-analysis-only -b  "/storage/users/ccuffe22/atac/data_hp/07.rmvdups/filtered_135313_$i.bam" \
#--outdir "/storage/users/ccuffe22/atac/data_hp/08.hmmratac/" \
#-n $i 
#done


#peak calling for SM and SCDM sample separately
#for i in $(ls rmvdups_*.bam); do echo $i; 
#macs3 hmmratac -b "/storage/users/ccuffe22/atac/data_hp/07.rmvdups/filtered_135313_$i.bam" \
#--outdir "/storage/users/ccuffe22/atac/data_hp/08.hmmratac/" \
#-u 10000 \
#-l 1000 \
#-c 50 \
#-n $i
#done

conda deactivate