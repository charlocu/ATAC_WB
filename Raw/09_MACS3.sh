#!/bin/bash
#SBATCH --chdir=/storage/users/ccuffe22/atac/data
#SBATCH --job-name=MACS3
#SBATCH --output=/storage/users/ccuffe22/atac/logfiles/MACS3_%j.log
#SBATCH --mail-user=ccuffe22@rvc.ac.uk
#SBATCH --mail-type=END,FAIL
#SBATCH --mem=12gb #Change this depending on memory requirements
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=3 #Change depending on CPU requirements

module load apps/anaconda-4.7.12.tcl
eval "$(conda shell.bash hook)"
conda activate MACS

module load apps/java-8u151.tcl

unset PYTHONPATH

#following commands in guidelines MACS3 online documentation
for i in 135313SCDM 135313SM; do
macs3 callpeak -f BAMPE -t "/storage/users/ccuffe22/atac/data/04.mapped/sorted_$i.bam" \
-g '2.5e9' -n test_$i -B -q 0.01 --outdir  "/storage/users/ccuffe22/atac/data/09.macs3/"
done

conda deactivate