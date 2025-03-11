#!/bin/bash
#SBATCH --chdir=/storage/users/ccuffe22/atac/raw_high_pass/
#SBATCH --job-name=mapping_0
#SBATCH --output=/storage/users/ccuffe22/atac/logfiles/mapping_%j.log
#SBATCH --mail-user=ccuffe22@rvc.ac.uk
#SBATCH --mail-type=END,FAIL
#SBATCH --mem=60gb #Change this depending on memory requirements
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32 #Change depending on CPU requirements

mkdir -p /storage/users/ccuffe22/atac/data_hp/04.mapped/

#organising the conda environment
module load apps/anaconda-4.7.12.tcl
eval "$(conda shell.bash hook)"
conda activate align 
unset PYTHONPATH
cd /storage/users/ccuffe22/atac/data_hp/03.pre-processing/

#gunzip /storage/users/ccuffe22/references/Equus_caballus.EquCab3.0.dna.toplevel.fa.gz
#have to unzip cause index files made on unzipped files I think

#Load BWA app
module load apps/bwa-0.7.10.tcl

#Do for each sample
#Map paired forward and reverse trimmed reads to the reference genome - the '-t' flag needs to match the number of CPUs above in the header
#for i in $(ls *_1.fq.gz); do k=${i%%_*}; echo $k; 
for i in WB1SM WB1SCDM; do
echo $i
bwa mem /storage/users/ccuffe22/references/Equus_caballus.EquCab3.0.dna.toplevel.fa \
  $i'_1'.fq.gz \
  $i'_2'.fq.gz \
  -t [32] -M | samtools sort -o /storage/users/ccuffe22/atac/data_hp/04.mapped/sorted_$i.bam \
  -O bam -T /storage/users/ccuffe22/temp_00
samtools flagstat /storage/users/ccuffe22/atac/data_hp/04.mapped/sorted_$i.bam \
> /storage/users/ccuffe22/atac/data_hp/04.mapped/sorted_$i.stats


#Samtools indexing
samtools index /storage/users/ccuffe22/atac/data_hp/04.mapped/sorted_$i.bam
echo done_$i
done
conda deactivate

#gzip storage/users/ccuffe22/references/Equus_caballus.EquCab3.0.dna.toplevel.fa
#tidying up after myself

#conda activate multiqc
#cd /storage/users/ccuffe22/atac/data_hp/04.mapped/
#multiqc .

#conda deactivate

