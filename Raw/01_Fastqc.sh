#!/bin/bash
#SBATCH --chdir=/storage/users/ccuffe22/atac/raw_data
#SBATCH --job-name=fastqc
#SBATCH --output=/storage/users/ccuffe22/atac/raw_data/fastqc_%j.log
#SBATCH --mail-user=ccuffe22@rvc.ac.uk
#SBATCH --mail-type=END,FAIL
#SBATCH --mem=1gb #Change this depending on memory requirements
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1 #Change depending on CPU requirements

#Load fastqc app
module load apps/fastqc/0.10.1/noarch

#Run fastqc
fastqc /X204SC23050247-Z01-F001/01.RawData/WB135313_SCDM/WB135313_SCDM_EKDL230007343-1A_HF35WDSX7_L3_1.fq
fastqc /X204SC23050247-Z01-F001/01.RawData/WB135313_SCDM/WB135313_SCDM_EKDL230007343-1A_HF35WDSX7_L3_2.fq
fastqc /X204SC23050247-Z01-F001/01.RawData/WB135313_SM/WB135313_SM_EKDL230007342-1A_HF35WDSX7_L3_1.fq
fastqc /X204SC23050247-Z01-F001/01.RawData/WB135313_SM/WB135313_SM_EKDL230007342-1A_HF35WDSX7_L3_2.fq

#View html outputs manually
#module load multiqc may or may not work
multiqc /storage/users/ccuffe22/atac/raw_data/X204SC23050247-Z01-F001/01.RawData/
