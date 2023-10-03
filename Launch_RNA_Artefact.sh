#!/bin/bash 
<<<<<<< HEAD
module load conda 
rm -r -f Raw_variant
source activate RNA_Artefact
snakemake -s snakefile --unlock
snakemake --cleanup-metadata snakefile
echo "Launch RNA artefact analysis "
snakemake -F  -s snakefile  --configfile "/trinity/home/hkhalfaoui/pipeline/rna_artefact/config.yaml"  --cluster-config cluster_config.yml  --cluster "sbatch  --nodes {cluster.nodes} --ntasks {cluster.ntasks} --cpus-per-task {cluster.cpus-per-task} "  --jobs 200 --dry-run
#snakemake -F  -s snakefile  --configfile "/trinity/home/hkhalfaoui/pipeline/rna_artefact/config.yaml" --cluster-config cluster_config.yml  --cluster "sbatch  --nodes {cluster.nodes} --ntasks {cluster.ntasks} --cpus-per-task {cluster.cpus-per-task} "  --notemp --jobs 200
=======
#rm -r -f Raw_variant
# Define code color 
terminalColorError='\033[1;31m'
terminalColorMessage='\033[1;33m'

#Define args Launch_RNA_Artefact.sh
while getopts "R:" optionName; do
case "$optionName" in
R) run_on_slurm="$OPTARG";;                                            
esac
done
#check arg for Launch_RNA_Artefact.sh script 
if [[ -z "$run_on_slurm" ]];
then 
    echo -e "${terminalColorError} ERREUR!!!: Please specify if you want to turn this pipeline in slurm or not by using -R ( yes or no ) ${terminalColorError}"
    echo -e "-R yes : if you want to turn this analysis on slurm"
    echo  -e "-R no : if you don't want to turn this analysis on slurm"
    exit 1
fi


if [ "$run_on_slurm" == "yes" ] ;
then 
    echo -e  "${terminalColorMessage}Launch RNA artefact analysis on SLURM${terminalColorMessage} "
    module load conda 
    snakemake -s snakefile --unlock
    snakemake --cleanup-metadata snakefile
    source activate RNA_Artefact
    snakemake -F  -s snakefile  --configfile "/trinity/home/hkhalfaoui/pipeline/rna_artefact/config.yaml"  --cluster-config cluster_config.yml  --cluster "sbatch  --nodes {cluster.nodes} --ntasks {cluster.ntasks} --cpus-per-task {cluster.cpus-per-task} "  --jobs 200 --dry-run #This is useful to test if the workflow is defined properly and to estimate the amount of needed computation.
    #snakemake -F  -s snakefile  --configfile "/trinity/home/hkhalfaoui/pipeline/rna_artefact/config.yaml" --cluster-config cluster_config.yml  --cluster "sbatch  --nodes {cluster.nodes} --ntasks {cluster.ntasks} --cpus-per-task {cluster.cpus-per-task} "  --notemp --jobs 200
else
    echo -e "${terminalColorMessage}Launch RNA artefact analysis${terminalColorMessage}"
    conda activate RNA_Artefact
    snakemake -s snakefile --unlock
    snakemake --cleanup-metadata snakefile
    snakemake -F  -s snakefile -c1 --dry-run # This is useful to test if the workflow is defined properly and to estimate the amount of needed computation.
    #snakemake -F  -s snakefile -c1 

fi
>>>>>>> Slurm_development
conda deactivate 
