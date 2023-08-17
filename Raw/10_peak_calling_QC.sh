#!/bin/bash
#SBATCH --chdir=/storage/users/ccuffe22/atac/data
#SBATCH --job-name=MACS3_QC
#SBATCH --output=/storage/users/ccuffe22/atac/logfiles/MACS3_QC_%j.log
#SBATCH --mail-user=ccuffe22@rvc.ac.uk
#SBATCH --mail-type=END,FAIL
#SBATCH --mem=3gb #Change this depending on memory requirements
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=3 #Change depending on CPU requirements

module load apps/anaconda-4.7.12.tcl
eval "$(conda shell.bash hook)"
conda activate deeptools

module load apps/java-8u151.tcl

#trying to make a Fraction of Reads in Peaks plot
unset PYTHONPATH
for i in 135313SCDM 135313SM; do
plotEnrichment -b /storage/users/ccuffe22/atac/data/04.mapped/sorted_$i.bam \
--BED /storage/users/ccuffe22/atac/data/$i"_peaks.gappedPeak" \
-o /storage/users/ccuffe22/atac/data/09.macs3/FRiP_hmmr_$i.png --smartLabels -T "Fraction of Reads in Peaks (FRiP), $i" \
--outRawCounts /storage/users/ccuffe22/atac/data/09.macs3/enrichment_hmmr_$i.tab
done

#doing separately so doing for MACS3 now
for i in 135313SCDM 135313SM; do echo $i; plotEnrichment -b /storage/users/ccuffe22/atac/data/04.mapped/sorted_$i.bam --BED /storage/users/ccuffe22/atac/data/09.macs3/test_$i"_peaks.narrowPeak" -o /storage/users/ccuffe22/atac/data/09.macs3/FRiP_macs3_$i.png --smartLabels -T "Fraction of Reads in Peaks (FRiP), $i" --outRawCounts /storage/users/ccuffe22/atac/data/09.macs3/enrichment_macs3_$i.tab; done
conda deactivate