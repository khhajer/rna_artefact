#!/bin/bash 
module load conda 
rm -r -f Raw_variant
source activate RNA_Artefact
snakemake -s snakefile --unlock
snakemake --cleanup-metadata snakefile
echo "Launch RNA artefact analysis "
snakemake -F  -s snakefile  --configfile "/trinity/home/hkhalfaoui/pipeline/rna_artefact/config.yaml"  --cluster-config cluster_config.yml  --cluster "sbatch  --nodes {cluster.nodes} --ntasks {cluster.ntasks} --cpus-per-task {cluster.cpus-per-task} "  --jobs 200 --dry-run
#snakemake -F  -s snakefile  --configfile "/trinity/home/hkhalfaoui/pipeline/rna_artefact/config.yaml" --cluster-config cluster_config.yml  --cluster "sbatch  --nodes {cluster.nodes} --ntasks {cluster.ntasks} --cpus-per-task {cluster.cpus-per-task} "  --notemp --jobs 200
conda deactivate 
