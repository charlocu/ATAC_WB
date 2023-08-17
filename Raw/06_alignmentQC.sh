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
    -b  "/storage/users/ccuffe22/atac/data/04.mapped/MD_135313_$i.bam" \
    -samplesLabel $i  \
    --table
    done
    
#Transcription start site attempts
conda activate deeptools

unset PYTHONPATH #cause my terminal has a hissy fit otherwise
mkdir -p /storage/users/ccuffe22/atac/data/10.tsse
#step 1. create the BigWig file
#in future try? --ignoreForNormalization chrMT --normalizeUsing RPGC
for i in 135313SCDM 135313SM; do
bamCoverage --bam /storage/users/ccuffe22/atac/data/04.mapped/sorted_$i.bam -o /storage/users/ccuffe22/atac/data/10.tsse/coverage_no_norm_$i.bw  --effectiveGenomeSize 25000000000 --extendReads
echo bam_$i
done
#effective genome size required for RPGC normalisation --extended the reads bc preferred for ChIP (so assuming similar for ATAC) as reads map contiguously

#step 2. compute the matrix to use as base for the TSS plots
for i in 135313SCDM 135313SM; do
computeMatrix reference-point -S /storage/users/ccuffe22/atac/data/10.tsse/coverage_no_norm_$i.bw -R /storage/users/ccuffe22/references/Equus_caballus.EquCab3.0.110.gtf -o /storage/users/ccuffe22/atac/data/10.tsse/coverage_matrix4_$i.mat.gz --referencePoint TSS --smartLabels --transcriptID start_codon -b 1000 -a 1000
echo compute_$i

done

#step 3. make the plots!! making a profile plot and a heatmap
#profile plot first
#for i in 135313SCDM 135313SM; do
#plotProfile -m /storage/users/ccuffe22/atac/data/10.tsse/coverage_matrix_$i.mat.gz -out /storage/users/ccuffe22/atac/data/10.tsse/TSSE_profile3_$i.png --plotTitle 'TSS enrichment for '$i
plotHeatmap -m /storage/users/ccuffe22/atac/data/10.tsse/coverage_matrix2_$i.mat.gz -out /storage/users/ccuffe22/atac/data/10.tsse/TSSE_heatmap2_$i.png 
plotHeatmap -m /storage/users/ccuffe22/atac/data/10.tsse/coverage_matrix3_$i.mat.gz -out /storage/users/ccuffe22/atac/data/10.tsse/TSSE_heatmap3_$i.png 
plotHeatmap -m /storage/users/ccuffe22/atac/data/10.tsse/coverage_matrix4_$i.mat.gz -out /storage/users/ccuffe22/atac/data/10.tsse/TSSE_heatmap4_$i.png 
echo plot_$i
done
conda deactivate