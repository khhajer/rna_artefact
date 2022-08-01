
configfile : "config.yaml"
#Get all subdirectories.
import pandas as pd
from pathlib import Path
import os 
dir_list=[]
p = Path("/scratch/omic_data/projects/MULTIPLI/ANALYSE/")
df = pd.read_csv(config["Redcap_info"])
for i in df.index:
    PATIENT=(df["Patient ID"][i])
    for it in os.scandir(p):
        if it.is_dir():
            if it.name.startswith(PATIENT):
                dir_list.append(it.path)
def get_path_sample(extension_file):
    list_file=[]
    for path in dir_list:
        for  root, dirs, files in os.walk(path):
            for file in files :
                if file.endswith(extension_file) :
                    file_path=os.path.join(root,file)
                    list_file.append(file_path)
    return(list_file)
#Return all id patients from compressed files and uncompressed files 
id_patient_file=[]
id_patient_gzfile=[]
for i in range(len(get_path_sample("Union_samples_chrAll.txt"))):
    id_patient_file.append(get_path_sample("Union_samples_chrAll.txt")[i][45:62])
for i in range(len(get_path_sample("Union_samples_chrAll.txt.gz"))):
   id_patient_gzfile.append(get_path_sample("Union_samples_chrAll.txt.gz")[i][45:62])
print(id_patient_file)
print(id_patient_gzfile)
#==================================================================================target rules=====================================================================================
rule all:
    input: 
        expand(config["current_dir"]+"Raw_variant/"+"{ID_PATIENT}.txt",ID_PATIENT=id_patient_file) ,
        expand(config["current_dir"]+"Raw_variant/"+"{ID_PATIENT_GZ}.txt" , ID_PATIENT_GZ=id_patient_gzfile),
        config["result_file"]+".tsv"
#========================================================================collect data from uncompressed files ========================================================
rule collect_data:
    input:
        "/scratch/omic_data/projects/MULTIPLI/ANALYSE/{ID_PATIENT}/Raw_variant/Union_samples_chrAll.txt"  
    output:
        config["current_dir"]+"Raw_variant/"+"{ID_PATIENT}.txt" 
    log:
        "logs/collect_data/{ID_PATIENT}.log"   
    shell:   
        "bash scripts/collect_data.sh  {input}   {output} &> {log}"
#========================================================================collect data from compressed files (gz)====================================================
rule compresed_data:
    input:
        "/scratch/omic_data/projects/MULTIPLI/ANALYSE/{ID_PATIENT_GZ}/Raw_variant/Union_samples_chrAll.txt.gz"  
    output:
        config["current_dir"]+"Raw_variant/"+"{ID_PATIENT_GZ}.txt"
    log:
        "logs/collect_data/{ID_PATIENT_GZ}.log"
    shell:   
        "bash scripts/collect_data.sh  {input}  {output} &> {log}" 
#========================================================================Annote RNA_Artefact =========================================================================
rule Annote_artefact:
    input:
        config["Redcap_info"],
        config["Genes_list"]
    output:
        config["result_file"]+".tsv"
    log:
        "logs/artefact/artefact_to_add.log"
    script:   
        "scripts/RNA_artefact_data.R"  
#========================================================================================================================================================================