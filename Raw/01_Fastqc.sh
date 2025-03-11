#!/bin/bash
#SBATCH --chdir=/storage/users/ccuffe22/atac/raw_high_pass
#SBATCH --job-name=fastqc
#SBATCH --output=/storage/users/ccuffe22/atac/logfiles/fastqc_%j.log
#SBATCH --mail-user=ccuffe22@rvc.ac.uk
#SBATCH --mail-type=END,FAIL
#SBATCH --mem=30gb #Change this depending on memory requirements
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1 #Change depending on CPU requirements


#Load fastqc app
module load apps/fastqc-0.11.9.tcl

# Define the parent directory containing your folders
PARENT_DIR="/storage/users/ccuffe22/atac/raw_high_pass/X204SC24100513-Z01-F001_01/01.RawData/"

# Loop over each folder in the parent directory
for file in "$PARENT_DIR"*/; do
    echo "Processing folder: $file"
    
    # Run FastQC on all fastq files in the folder
    fastqc "$file"*.fq.gz -o "$file"
    
done

#View html outputs manually
#admin stuff to make conda environments work
#module load apps/anaconda-4.7.12.tcl
#eval "$(conda shell.bash hook)"
#conda activate multiqc
#module load multiqc
#multiqc /storage/users/ccuffe22/atac/raw_high_pass/
#conda deactivate

#echo 'done'
