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

cd "/storage/users/ccuffe22/atac/raw_high_pass/"
pwd
module load apps/anaconda-4.7.12.tcl
eval "$(conda shell.bash hook)"
conda activate preproc
unset PYTHONPATH

for i in $(ls X204SC241*/*/*/*_1.fq.gz); do 
    x=$(echo $i | cut -f4 -d "/" ), j=${i%_*}; k=${x%%_*}; echo $k; cutadapt -a CTGTCTCTTATACACATCT -A CTGTCTCTTATACACATCT -q 32 --minimum-length=25 -o "/storage/users/ccuffe22/atac/data_hp/03.pre-processing/"$k"_1.fq.gz" -p "/storage/users/ccuffe22/atac/data_hp/03.pre-processing/"$k"_2.fq.gz" $j"_1.fq.gz" $j"_2.fq.gz"; 
done

 
#removing the nextera adaptor sequence from the reads
#next-seq trim specifically cause of two colour chemistry used in next-seq and nova-seq, and is a quality filtering step based on phred-33
# --minimum-length= is stating minimum read length, --max-n is the maximum amount of allowable N's called in the sequences
# -q is quality to trim for
# apparently -max-n and --nextseq-trim are only available in more recent versions
#--cores=15 \ doesn't work with Python 2 which is what I use because of issues with Python 3 in my conda

#conda deactivate 
conda activate multiqc
unset PYTHONPATH
#fastqc of the above
module load apps/fastqc-0.11.9.tcl

PARENT_DIR=/storage/users/ccuffe22/atac/data_hp/03.pre-processing/

# Loop over each folder in the parent directory
for file in "$PARENT_DIR"; do
    echo "Processing folder: $file"
    
    # Run FastQC on all fastq files in the folder
    fastqc "$file"*.fq.gz -o "$file"
    
done

conda deactivate

echo 'done'