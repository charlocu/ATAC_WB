#!/bin/bash
#SBATCH --chdir=/storage/users/ccuffe22/atac/raw_data/
#SBATCH --job-name=adapter_removal
#SBATCH --output=/storage/users/ccuffe22/atac/logfiles/filtering_%j.log
#SBATCH --mail-user=ccuffe22@rvc.ac.uk
#SBATCH --mail-type=END,FAIL
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=3 #Change depending on CPU requirements

#make directory only if doesn't already exist
mkdir -p /storage/users/ccuffe22/atac/data_hp/03.pre-processing/


module load apps/anaconda-4.7.12.tcl
eval "$(conda shell.bash hook)"
conda activate preproc
unset PYTHONPATH

#removing the nextera adaptor sequence from the reads
#next-seq trim specifically cause of two colour chemistry used in next-seq and nova-seq, and is a quality filtering step based on phred-33
# --minimum-length= is stating minimum read length, --max-n is the maximum amount of allowable N's called in the sequences
# -q is quality to trim for
# apparently -max-n and --nextseq-trim are only available in more recent versions
#--cores=15 \ doesn't work with Python 2 which is what I use because of issues with Python 3 in my conda

#SCDM read1 & 2 high-depth

cutadapt -a CTGTCTCTTATACACATCT -A CTGTCTCTTATACACATCT \
-q 30 \
--minimum-length=25 \
-o /storage/users/ccuffe22/atac/data_hp/03.pre-processing/trimmed_WB135313_SCDM_1.fq.gz \
-p /storage/users/ccuffe22/atac/data_hp/03.pre-processing/trimmed_WB135313_SCDM_2.fq.gz \
/storage/users/ccuffe22/atac/raw_high_pass/X204SC23092804-Z01-F001/01.RawData/WB135313_SM/WB135313_SM_EKDL230007342-1A_HG3GNDSX7_L3_1.fq \
/storage/users/ccuffe22/atac/raw_high_pass/X204SC23092804-Z01-F001/01.RawData/WB135313_SM/WB135313_SM_EKDL230007342-1A_HG3GNDSX7_L3_2.fq

#SM read1 & 2
cutadapt -a CTGTCTCTTATACACATCT -A CTGTCTCTTATACACATCT \
-q 30 \
--minimum-length=25 \
-o /storage/users/ccuffe22/atac/data_hp/03.pre-processing/trimmed_WB135313_SM_1.fq.gz \
-p /storage/users/ccuffe22/atac/data_hp/03.pre-processing/trimmed_WB135313_SM_2.fq.gz \
/storage/users/ccuffe22/atac/raw_high_pass/X204SC23092804-Z01-F001/01.RawData/WB135313_SCDM/WB135313_SCDM_EKDL230007343-1A_HG25KDSX7_L3_2.fq \
/storage/users/ccuffe22/atac/raw_high_pass/X204SC23092804-Z01-F001/01.RawData/WB135313_SCDM/WB135313_SCDM_EKDL230007343-1A_HG25KDSX7_L3_1.fq

conda deactivate 
conda activate multiqc
unset PYTHONPATH
#fastqc of the above
module load apps/fastqc-0.11.9.tcl

fastqc /storage/users/ccuffe22/atac/data_hp/03.pre-processing/trimmed_WB135313_SCDM_1.fq.gz 
fastqc /storage/users/ccuffe22/atac/data_hp/03.pre-processing/trimmed_WB135313_SCDM_2.fq.gz 
fastqc /storage/users/ccuffe22/atac/data_hp/03.pre-processing/trimmed_WB135313_SM_1.fq.gz
fastqc /storage/users/ccuffe22/atac/data_hp/03.pre-processing/trimmed_WB135313_SM_2.fq.gz
multiqc -n -f adaptor_removal_multiqc /storage/users/ccuffe22/atac/data_hp/03.pre-processing/

conda deactivate

echo 'done'