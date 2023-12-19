#!/bin/bash
#SBATCH --chdir=/storage/users/ccuffe22/atac/raw_high_pass
#SBATCH --job-name=fastqc
#SBATCH --output=/storage/users/ccuffe22/atac/logfiles/fastqc_%j.log
#SBATCH --mail-user=ccuffe22@rvc.ac.uk
#SBATCH --mail-type=END,FAIL
#SBATCH --mem=30gb #Change this depending on memory requirements
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1 #Change depending on CPU requirements



#first unzip samples
gunzip "/storage/users/ccuffe22/atac/raw_high_pass/X204SC23092804-Z01-F001/01.RawData/WB135313_SM/WB135313_SM_EKDL230007342-1A_HG3GNDSX7_L3_2.fq.gz"
gunzip "/storage/users/ccuffe22/atac/raw_high_pass/X204SC23092804-Z01-F001/01.RawData/WB135313_SM/WB135313_SM_EKDL230007342-1A_HG3GNDSX7_L3_1.fq.gz"

#next SCDM
gunzip "/storage/users/ccuffe22/atac/raw_high_pass/X204SC23092804-Z01-F001/01.RawData/WB135313_SCDM/WB135313_SCDM_EKDL230007343-1A_HG25KDSX7_L3_2.fq.gz"
gunzip "/storage/users/ccuffe22/atac/raw_high_pass/X204SC23092804-Z01-F001/01.RawData/WB135313_SCDM/WB135313_SCDM_EKDL230007343-1A_HG25KDSX7_L3_1.fq.gz"

#Load fastqc app
module load apps/fastqc-0.11.9.tcl
#Run fastqc
#first SM
fastqc "/storage/users/ccuffe22/atac/raw_high_pass/X204SC23092804-Z01-F001/01.RawData/WB135313_SM/WB135313_SM_EKDL230007342-1A_HG3GNDSX7_L3_2.fq"
fastqc "/storage/users/ccuffe22/atac/raw_high_pass/X204SC23092804-Z01-F001/01.RawData/WB135313_SM/WB135313_SM_EKDL230007342-1A_HG3GNDSX7_L3_1.fq"

#next SCDM
fastqc "/storage/users/ccuffe22/atac/raw_high_pass/X204SC23092804-Z01-F001/01.RawData/WB135313_SCDM/WB135313_SCDM_EKDL230007343-1A_HG25KDSX7_L3_2.fq"
fastqc "/storage/users/ccuffe22/atac/raw_high_pass/X204SC23092804-Z01-F001/01.RawData/WB135313_SCDM/WB135313_SCDM_EKDL230007343-1A_HG25KDSX7_L3_1.fq"

#View html outputs manually
#module load multiqc
#multiqc /storage/users/ccuffe22/atac/raw_high_pass/$i/

#lastly rezip samples
gzip "/storage/users/ccuffe22/atac/raw_high_pass/X204SC23092804-Z01-F001/01.RawData/WB135313_SM/WB135313_SM_EKDL230007342-1A_HG3GNDSX7_L3_2.fq.gz"
gzip "/storage/users/ccuffe22/atac/raw_high_pass/X204SC23092804-Z01-F001/01.RawData/WB135313_SM/WB135313_SM_EKDL230007342-1A_HG3GNDSX7_L3_1.fq.gz"

#next SCDM
gzip "/storage/users/ccuffe22/atac/raw_high_pass/X204SC23092804-Z01-F001/01.RawData/WB135313_SCDM/WB135313_SCDM_EKDL230007343-1A_HG25KDSX7_L3_2.fq.gz"
gzip "/storage/users/ccuffe22/atac/raw_high_pass/X204SC23092804-Z01-F001/01.RawData/WB135313_SCDM/WB135313_SCDM_EKDL230007343-1A_HG25KDSX7_L3_1.fq.gz"

echo 'done'
