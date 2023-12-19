#!/bin/bash
#SBATCH --chdir=/storage/users/ccuffe22/atac/raw_high_pass/
#SBATCH --job-name=mapping
#SBATCH --output=/storage/users/ccuffe22/atac/logfiles/mapping_%j.log
#SBATCH --mail-user=ccuffe22@rvc.ac.uk
#SBATCH --mail-type=END,FAIL
#SBATCH --mem=16gb #Change this depending on memory requirements
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32 #Change depending on CPU requirements

mkdir -p /storage/users/ccuffe22/atac/data_hp/04.mapped/

#organising the conda environment
module load apps/anaconda-4.7.12.tcl
eval "$(conda shell.bash hook)"
conda activate align 
unset PYTHONPATH

#Load BWA app
module load apps/bwa-0.7.10.tcl

#Do for each sample
#Map paired forward and reverse trimmed reads to the reference genome - the '-t' flag needs to match the number of CPUs above in the header
for i in SM SCDM; do
echo $i
bwa mem /storage/users/ccuffe22/references/Equus_caballus.EquCab3.0.dna.toplevel.fa.gz \
  /storage/users/ccuffe22/atac/data_hp/03.pre-processing/trimmed_WB135313_$i'_1'.fq.gz \
  /storage/users/ccuffe22/atac/data_hp/03.pre-processing/trimmed_WB135313_$i'_2'.fq.gz \
  -t [32] -M | samtools sort -o /storage/users/ccuffe22/atac/data_hp/04.mapped/sorted_135313_$i.bam \
  -O bam -T /storage/users/ccuffe22/temp
samtools flagstat /storage/users/ccuffe22/atac/data_hp/04.mapped/sorted_135313_$i.bam \
> /storage/users/ccuffe22/atac/data_hp/04.mapped/sorted_135313_$i.stats


#Samtools indexing
samtools index /storage/users/ccuffe22/atac/data/04.mapped/sorted_135313_$i.bam
echo done_$i
done
conda deactivate

conda activate multiqc
cd /storage/users/ccuffe22/atac/data/04.mapped/
multiqc .

conda deactivate