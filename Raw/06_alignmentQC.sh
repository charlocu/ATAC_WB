#!/bin/bash
#SBATCH --chdir=/storage/users/ccuffe22/atac/data/04.mapped/
#SBATCH --job-name=QC
#SBATCH --output=/storage/users/ccuffe22/atac/logfiles/align_QC_%j.log
#SBATCH --mail-user=ccuffe22@rvc.ac.uk
#SBATCH --mail-type=END,FAIL
#SBATCH --mem=16gb #Change this depending on memory requirements
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1 #Change depending on CPU requirements

#module admin 
module load apps/java-8u151.tcl
module load apps/anaconda-4.7.12.tcl
eval "$(conda shell.bash hook)"
conda activate align 
module load apps/R-4.2.1.tcl  

#For SCDM, collecting GC bias metrics + making graph
for i in SM SCDM;
java -jar /storage/apps/picard/2.22.0/picard.jar CollectGcBiasMetrics \ 
      I="/storage/users/ccuffe22/atac/data/04.mapped/MD_135313_$i.bam" \
      O=gc_bias_metrics_$i.txt \
      CHART=gc_bias_metrics_$i.pdf \
      S=GC_summary_metrics_$i.txt \
      R="/storage/users/ccuffe22/references/Equus_caballus.EquCab3.0.dna.toplevel.fa.gz"
      done

#fragment size assessment
conda activate deeptools 
for i in 135313_SM 135313_SCDM;
    deepTools2.0/bin/bamPEFragmentSize \
    -hist fragmentSize_$i.png \
    -T "Fragment size of PE ATAC-seq data" \
    --maxFragmentLength 1000 \
    -b  "/storage/users/ccuffe22/atac/data/04.mapped/MD_135313_$.bam" \
    -samplesLabel $i  \
    --table
    done