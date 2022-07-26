#!/bin/bash 
#SBATCH -J RNA_artefact
#SBATCH -o /scratch/hkhalfaoui/RNA_ARTEFACT/logs/slurm_RNA_ARTEFACT.out
#SBATCH -e /scratch/hkhalfaoui/RNA_ARTEFACT/logs/slurm_RNA_ARTEFACT.err
#SBATCH --mail-type=END
#SBATCH --mail-user=h.khalfaoui@bordeaux.unicancer.fr
module load conda 
source activate RNA_Artefact
srun snakemake -F -s snakefile --configfile=config.yaml --cluster "sbatch  -N 1 -c 14  --mem=1G --cpus-per-task=20" --jobs 20 -c1
conda deactivate 