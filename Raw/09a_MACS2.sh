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
mkdir -p /storage/users/ccuffe22/atac/data_hp/09a.macs2/

module load apps/anaconda-4.7.12.tcl
eval "$(conda shell.bash hook)"
conda activate macs2
module load apps/java-8u151.tcl
unset PYTHONPATH

#cd "/storage/users/ccuffe22/atac/data_hp/09a.macs2/"
cd "/storage/users/ccuffe22/atac/data_hp/07.rmvdups/"
#following commands in guidelines MACS2 online documentation
#for i in $(ls filtered_*.bam);do echo $i;
   # macs2 callpeak -f BAMPE -t "/storage/users/ccuffe22/atac/data_hp/07.rmvdups/$i" \
   # -g '2.5e9' -n macs2_0.05_$i -B -q 0.05 --outdir  "/storage/users/ccuffe22/atac/data_hp/09a.macs2/" \
   # --call-summits
#done

#conda deactivate
#as this analysis was done in different batches, checking if output file already exists
#if yes then skipping, if no then calling peaks on it

shopt -s nullglob #ensures the loop skips if no matching files
#in_dir= "/storage/users/ccuffe22/atac/data_hp/07.rmvdups/"

for i in  filtered_*.bam; do 
    echo $i;
    if [ -z "$i" ]; then
        echo "No input files found. Exiting loop."
        break
    fi

    output_file="/storage/users/ccuffe22/atac/data_hp/09a.macs2/macs2_0.05_${i}_summits.bed"
    echo "Output file path: $output_file"
    if [ -f "$output_file" ]; then 
        if [ ! -w "$output_file" ]; then
            echo "Output file $output_file exists but is not writable. Skipping..."
            continue
        fi
        echo "Output file $output_file exists and is writeable. Skipping..."
        continue
    fi 

    k=${i#*_}
    k=${k%.bam}; echo "Processing $k"

    macs2 callpeak -f BAMPE -t "/storage/users/ccuffe22/atac/data_hp/07.rmvdups/$i" \
    -g "2.5e9" -n "macs2_0.05_${k}" -B -q 0.05 --outdir  "/storage/users/ccuffe22/atac/data_hp/09a.macs2/" \
    --call-summits
done
conda deactivate