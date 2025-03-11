#!/bin/bash
#SBATCH --chdir=/storage/users/ccuffe22/atac/data
#SBATCH --job-name=MACS3
#SBATCH --output=/storage/users/ccuffe22/atac/logfiles/MACS3_%j.log
#SBATCH --mail-user=ccuffe22@rvc.ac.uk
#SBATCH --mail-type=END,FAIL
#SBATCH --mem=32gb #Change this depending on memory requirements
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=3 #Change depending on CPU requirements

#admin bits
mkdir -p /storage/users/ccuffe22/atac/data_hp/09.macs3/

module load apps/anaconda-4.7.12.tcl
eval "$(conda shell.bash hook)"
conda activate MACS
module load apps/java-8u151.tcl
unset PYTHONPATH

#following commands in guidelines MACS3 online documentation
for i in SCDM SM; do
macs3 callpeak -f BAMPE -t "/storage/users/ccuffe22/atac/data_hp/07.rmvdups/filtered_135313_$i.bam" \
-g '2.5e9' -n test0.05_135313_$i -B -q 0.05 --outdir  "/storage/users/ccuffe22/atac/data_hp/09.macs3/"
done

conda deactivate