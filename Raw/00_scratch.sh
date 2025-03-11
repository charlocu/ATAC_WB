#!/bin/bash
#SBATCH --chdir=/storage/users/ccuffe22/atac/raw_high_pass/
#SBATCH --job-name=indexing
#SBATCH --output=/storage/users/ccuffe22/atac/logfiles/scratch_%j.log
#SBATCH --error=/storage/users/ccuffe22/atac/logfiles/scratch_%j.err
#SBATCH --mail-user=ccuffe22@rvc.ac.uk
#SBATCH --mail-type=END,FAIL
#SBATCH --mem=16gb #Change this depending on memory requirements
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1 #Change depending on CPU requirements

module load apps/anaconda-4.7.12.tcl
eval "$(conda shell.bash hook)"
#conda activate picard

#unset PYTHONPATH

#java -jar picard.jar ValidateSamFile I=WB6SCDM2_1.fq.gz MODE=SUMMARY
#java -jar picard.jar ValidateSamFile I=WB6SCDM2_2.fq.gz MODE=SUMMARY

#conda deactivate


#names=(SM SCDM)
#for i in "${names[@]}"; do
#    echo $i
#java -jar /storage/apps/picard/2.22.0/picard.jar MarkDuplicates \
 #     I= "/storage/users/ccuffe22/atac/data/05.markdups/MD_135313_$i.bam" \
  #    O= "/storage/users/ccuffe22/atac/data/07.rmvdups/filtered_135313_$i.bam"\
   #   --REMOVE_DUPLICATES \
    #  M=removed_dup_metrics_$i.txt
      #done
#samtools

#module load libs/htslib-1.2.1.tcl

#samtools index  "/storage/users/ccuffe22/atac/data/04.mapped/MD_135313SCDM.bam"
#samtools index  "/storage/users/ccuffe22/atac/data/04.mapped/MD_135313SM.bam"

#conda deactivate

conda activate deeptools
unset PYTHONPATH

cd '/storage/users/ccuffe22/atac/data_hp/09a.macs2/'
#attempt for FRiP
for i in  *_summits.bed; do 
  #removing the beginning of the file names
  j=${i#*filtered_*} j=${j#*0.05_*} 
  #removing the end of the file names
  k=${j%%_summits.bed} k=${k%%.bam*}; 
  echo "Processing $k"; 
  plotEnrichment -b /storage/users/ccuffe22/atac/data_hp/04.mapped/sorted_$k.bam \
  --BED $i \
  -o /storage/users/ccuffe22/atac/data_hp/09a.macs2/FRiP_macs2_$k.png --smartLabels -T "Fraction of Reads in Peaks (FRiP), $k" \
  --outRawCounts /storage/users/ccuffe22/atac/data_hp/09a.macs2/enrichment_macs2_$k.tab
  echo "Processing $k done..."
done
conda deactivate


#looking at reads mapped to individual chromosomes
module load apps/samtools-1.9.tcl 
cd '/storage/users/ccuffe22/atac/data_hp/04.mapped/'

for i in  *_summits.bed; do 
  #removing the beginning of the file names
  j=${i#*filtered_*} j=${j#*0.05_*} 
  #removing the end of the file names
  k=${j%%_summits.bed} k=${k%%.bam*}; 
  echo "Processing $k"; 
  samtools idxstats $i | awk '{print $1" "$3}'| > /storage/users/ccuffe22/atac/data_hp/04.mapped/$k.info
  echo $k done
done
#conda deactivate

#module load apps/bedtools-2.29.tcl 
#cd ~/atac/data_hp/09.macs3/
#sed "s/^chr//" /storage/users/ccuffe22/atac/data_hp/09.macs3/MACS2_callpeaks_on_WB135313-SM_peaks.bed  > /storage/users/ccuffe22/atac/data_hp/09.macs3/MACS2_callpeaks_on_WB135313-SM_peaks_renamed.bed
#sed "s/^chr//" /storage/users/ccuffe22/atac/data_hp/09.macs3/MACS2_callpeak_on_WB135313-SCDM_narrow_Peaks.bed > /storage/users/ccuffe22/atac/data_hp/09.macs3/MACS2_callpeak_on_WB135313-SCDM_narrow_Peaks_renamed.bed

#bedtools intersect \
#-a /storage/users/ccuffe22/atac/data_hp/09.macs3/MACS2_callpeaks_on_WB135313-SM_peaks_renamed.bed \
#-b /storage/users/ccuffe22/atac/data_hp/09.macs3/test_135313_SM_peaks.bed \
#-bed >intersect_peaks_SM.bed

#bedtools intersect \
#-a /storage/users/ccuffe22/atac/data_hp/09.macs3/MACS2_callpeak_on_WB135313-SCDM_narrow_Peaks_renamed.bed \
#-b /storage/users/ccuffe22/atac/data_hp/09.macs3/test_135313_SCDM_peaks.bed \
#-bed >intersect_peaks_SCDM.bed


