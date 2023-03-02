
configfile : "config.yaml"
#!/usr/bin/env python
import requests
import pandas as pd
import numpy as np
from io import StringIO
from pathlib import Path
import os 

data = {
    'token': 'C68FCD462DAA114203BEC2307631F07D',
    'content': 'report',
    'format': 'csv',
    'report_id': '309',
    'rawOrLabel': 'raw',
    'rawOrLabelHeaders': 'raw',
    'exportCheckboxLabel': 'false',
    'returnFormat': 'csv'
}
r = requests.post('http://129.10.20.120/redcap/api/',data=data)
print('HTTP Status: ' + str(r.status_code))
print(r.text)
df = pd.read_csv(StringIO(r.text))
columns=["patient_id","redcap_repeat_instrument","redcap_repeat_instance","arn_platform"]
df=pd.DataFrame(df,columns=columns)
df_Repport_RNA_Patient=df.rename(columns={"patient_id": "Patient ID", "redcap_repeat_instrument": "Repeat Instrument","redcap_repeat_instance":"Repeat Instance","arn_platform":"Tumor RNA platform"})
df_Repport_RNA_Patient.to_csv(config["current_dir"]+"input_files/Repport_RNA_Patient.csv",sep=",",index=False)


# get wilcards for all patients
dirnameForUnzipFile, =glob_wildcards("/scratch/omic_data/projects/MULTIPLI/ANALYSE/"+"{DIRNAME}/Raw_variant/Union_samples_chrAll.txt")
dirnameForzipFile, =glob_wildcards("/scratch/omic_data/projects/MULTIPLI/ANALYSE/"+"{DIRNAME}/Raw_variant/Union_samples_chrAll.txt.gz")

# remove duplicate id patients
id_patient_file=list(set(dirnameForUnzipFile))
id_patient_gzfile=list(set(dirnameForzipFile))
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
        config["current_dir"]+"input_files/Repport_RNA_Patient.csv",
        config["Genes_list"]
    output:
        config["result_file"]+".tsv"
    log:
        "logs/artefact/artefact_to_add.log"
    script:   
        "scripts/RNA_artefact_data.R"  
#========================================================================================================================================================================