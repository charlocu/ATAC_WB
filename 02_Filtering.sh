#!/bin/bash
#SBATCH --chdir=/storage/users/ccuffe22/atac/raw_data/
#SBATCH --job-name=adapter_removal
#SBATCH --output=/storage/users/ccuffe22/atac/raw_data/filtering_%j.log
#SBATCH --mail-user=ccuffe22@rvc.ac.uk
#SBATCH --mail-type=END,FAIL
#SBATCH --mem=1gb #Change this depending on memory requirements
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1 #Change depending on CPU requirements

module load apps/anaconda-4.7.12.tcl
eval "$(conda shell.bash hook)"
conda activate preproc
#removing the nextera adaptor sequence from the reads
#next-seq trim specifically cause of two colour chemistry used in next-seq and nova-seq, and is a quality filtering step based on phred-33
# -m is stating minimum read length, --max-n is the maximum amount of allowable N's called in the sequences
# apparently -max-n and --nextseq-trim are only available in more recent versions
#SCDM read1 & 2

cutadapt -a CTGTCTCTTATACACATCT --nextseq-trim=30 --minimum-length=25 \
--max-n 0 \
-o /storage/users/ccuffe22/atac/data/03.pre-processing/trimmed_WB135313_SCDM_1.fq.gz \
-p /storage/users/ccuffe22/atac/data/03.pre-processing/trimmed_WB135313_SCDM_2.fq.gz \
/storage/users/ccuffe22/atac/raw_data/X204SC23050247-Z01-F001/01.RawData/WB135313_SCDM/WB135313_SCDM_EKDL230007343-1A_HF35WDSX7_L3_1.fq.gz \
/storage/users/ccuffe22/atac/raw_data/X204SC23050247-Z01-F001/01.RawData/WB135313_SCDM/WB135313_SCDM_EKDL230007343-1A_HF35WDSX7_L3_2.fq.gz

#SM read1 & 2
cutadapt -a CTGTCTCTTATACACATCT \
--nextseq-trim=30 \
--minimum-length=25 \
--max-n 0 \
-o /storage/users/ccuffe22/atac/data/03.pre-processing/trimmed_WB135313_SM_1.fq.gz \
-p /storage/users/ccuffe22/atac/data/03.pre-processing/trimmed_WB135313_SM_2.fq.gz \
/storage/users/ccuffe22/atac/raw_data/X204SC23050247-Z01-F001/01.RawData/WB135313_SM/WB135313_SM_EKDL230007342-1A_HF35WDSX7_L3_1.fq.gz \
/storage/users/ccuffe22/atac/raw_data/X204SC23050247-Z01-F001/01.RawData/WB135313_SM/WB135313_SM_EKDL230007342-1A_HF35WDSX7_L3_2.fq.gz

conda deactivate preproc
conda activate multiqc

#fastqc of the above
module load apps/fastqc-0.11.9.tcl

fastqc /storage/users/ccuffe22/atac/data/03.pre-processing/trimmed_WB135313_SCDM_1.fq.gz 
fastqc /storage/users/ccuffe22/atac/data/03.pre-processing/trimmed_WB135313_SCDM_2.fq.gz 
fastqc /storage/users/ccuffe22/atac/data/03.pre-processing/trimmed_WB135313_SM_1.fq.gz
fastqc /storage/users/ccuffe22/atac/data/03.pre-processing/trimmed_WB135313_SM_2.fq.gz
multiqc -n -f adaptor_removal_multiqc /storage/users/ccuffe22/atac/data/03.pre-processing/

conda deactivate multiqc