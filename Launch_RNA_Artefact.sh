#!/bin/bash 
#SBATCH -J RNA_artefact
#SBATCH -o /scratch/hkhalfaoui/RNA_ARTEFACT/logs/slurm_RNA_ARTEFACT.out
#SBATCH -e /scratch/hkhalfaoui/RNA_ARTEFACT/logs/slurm_RNA_ARTEFACT.err
#SBATCH --mail-type=END
#SBATCH --mail-user=h.khalfaoui@bordeaux.unicancer.fr
module load conda 
rm -r -f Raw_variant
source activate RNA_Artefact
snakemake -s snakefile --unlock
snakemake --cleanup-metadata snakefile
snakemake -F  -s snakefile --configfile config.yaml --cluster-config cluster_config.yml  --cluster "sbatch  -N {cluster.nodes} --mem {cluster.mem} --ntasks-per-node {cluster.ntasks-per-node} -p {cluster.partition} "  --jobs 200 
#--dry-run
conda deactivate 
