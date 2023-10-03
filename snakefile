
configfile : "config.yaml"
#=================================================== Get Repport RNA Patient from REDcap for MULTIPLI Project ====================================================================
import requests
import pandas as pd
import numpy as np
from io import StringIO
from pathlib import Path
import os 
import sys
#======================================================================= get wilcards for all patients ( MULTIPLI OR Rnaseqpatho ) =============================================================================== 
if len(config["Project_name"])!= 0 and config["Project_name"]!="MULTIPLI":
    print(config["Project_name"])
    dirnameForUnzipFile, =glob_wildcards("/scratch/omic_data/projects/"+str(config["Project_name"])+"/ANALYSE/"+"{DIRNAME}/Raw_variant/Union_samples_chrAll.txt")
    dirnameForzipFile, =glob_wildcards("/scratch/omic_data/projects/"+str(config["Project_name"])+"/ANALYSE/"+"{DIRNAME}/Raw_variant/Union_samples_chrAll.txt.gz")
    wildcards=list(set(dirnameForUnzipFile))
    wildcards1=list(set(dirnameForzipFile))
    print(wildcards)
    print(wildcards1)
    
elif len(config["Project_name"])!= 0 and config["Project_name"]=="MULTIPLI":
    print (config["Project_name"])
    print(" Get Repport RNA Patient from REDcap")
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
    df = pd.read_csv(StringIO(r.text))
    columns=["patient_id","redcap_repeat_instrument","redcap_repeat_instance","arn_platform","analysisid"]
    df=pd.DataFrame(df,columns=columns)
    df["patient_id"]=df["patient_id"].str.split("-OLD|_OLD").str[0]
    df=df[~df["patient_id"].str.contains("NEXTSEQ|NOVASEQ")]
    df["patient_analysis_id"]=df["patient_id"].astype(str)+"-"+df["analysisid"]
    df=df[["patient_analysis_id","arn_platform"]]
    list_patient_id=df.patient_analysis_id.values.tolist()
    dirnameForUnzipFile, =glob_wildcards("/scratch/omic_data/projects/"+str(config["Project_name"])+"/ANALYSE/"+"{DIRNAME}/Raw_variant/Union_samples_chrAll.txt")
    dirnameForzipFile, =glob_wildcards("/scratch/omic_data/projects/"+str(config["Project_name"])+"/ANALYSE/"+"{DIRNAME}/Raw_variant/Union_samples_chrAll.txt.gz")
    wildcards=[element for element in dirnameForUnzipFile if element in list_patient_id ]
    wildcards1=[element for element in dirnameForzipFile if element in list_patient_id]
    print(wildcards)
    print(wildcards1)
elif(len(config["Project_name"])==0 and len(config["input_files"])!=0):
    print("Get input files path from config file")
    wildcards,=glob_wildcards(config["input_files"]+"{WILDCARDS}.txt")
    wildcards1,=glob_wildcards(config["input_files"]+"{WILDCARDS1}.txt.gz")
    print(wildcards)
    print(wildcards1)
   
else:
    print("ERREUR : We must define path for input files !!! ")
    sys.exit()
#==================================================================================target rules=====================================================================================
rule all:
    input: 
        expand(config["current_dir"]+"Raw_variant/"+"{WILDCARDS}.txt",WILDCARDS=wildcards) ,
        expand(config["current_dir"]+"Raw_variant/"+"{WILDCARDS1}.txt" ,WILDCARDS1=wildcards1 ),
        #"/scratch_ssd/reference/annotation/gvx_historyartefacts_to_add_rna_artefact.tsv" if config["Project_name"]=="MULTIPLI" else [],# Sur la branche prod il faut changer le current dir pour mettre le fichier dans le bon chemin
        #"/scratch/omic_data/projects/Rnaseqpatho/rna_artefact_Rnaseqpatho.tsv" if config["Project_name"]=="Rnaseqpatho" else [] ,# sur la branche prod il faut changer le current dir pour mettre le fichier dans le dossier filter artefact
        config["current_dir"]+"artefacts_to_add_rna_artefact.tsv" if config["Project_name"]=="MULTIPLI" else [],
        config["current_dir"]+"rna_artefact_Rnaseqpatho.tsv" if config["Project_name"]=="Rnaseqpatho" else [] ,
        config["current_dir"]+"rna_artefact.tsv" if len(config["Project_name"])==0 else [] 
        

# # #========================================================================collect data from uncompressed files ========================================================
if config["Project_name"]:
    rule collect_data:
        input:
            "/scratch/omic_data/projects/"+str(config["Project_name"])+"/ANALYSE/"+"{WILDCARDS}/Raw_variant/Union_samples_chrAll.txt" 
        output:
            config["current_dir"]+"Raw_variant/"+"{WILDCARDS}.txt" 
        params:
            Project_name=config["Project_name"]    
        log:
            "logs/collect_data/{WILDCARDS}.log"   
        shell:   
            "bash scripts/collect_data.sh  {input}   {output} {params.Project_name} &>{log}"

# #======================================================================== collect data from compressed files (gz) ====================================================
if config["Project_name"] == "MULTIPLI" :
    rule compresed_data:
        input:
            "/scratch/omic_data/projects/"+str(config["Project_name"])+"/ANALYSE/"+"{WILDCARDS1}/Raw_variant/Union_samples_chrAll.txt.gz" 
        output:
            config["current_dir"]+"Raw_variant/"+"{WILDCARDS1}.txt"
        params:
            Project_name=config["Project_name"] 
        log:
            "logs/collect_data/{WILDCARDS1}.log"
        shell:   
            "bash scripts/collect_data.sh  {input}  {output} {params.Project_name} &> {log}" 

# #======================================================================== Annote RNA_Artefact For MULTIPLI Project =========================================================================

rule Annote_artefact:
    input:
        input_files=expand(config["current_dir"]+"Raw_variant/{WILDCARDS}.txt",WILDCARDS=wildcards) if len(config["Project_name"])!=0 else [expand(config["input_files"]+"{WILDCARDS}.txt",WILDCARDS=wildcards )],  
        input_file_gz=expand(config["current_dir"]+"Raw_variant/{WILDCARDS1}.txt",WILDCARDS1=wildcards1) if len(config["Project_name"])!=0 else [expand(config["input_files"]+"{WILDCARDS1}.txt",WILDCARDS1=wildcards1)],
        input_list_gene=config["input_genes_list_file"] if len(config["input_genes_list_file"])!=0 else [] 
        
    output:
<<<<<<< HEAD
        "/scratch_ssd/reference/annotation/gvx_history/artefacts_to_add_rna_artefact.tsv" if config["Project_name"]=="MULTIPLI" else [],
        "/scratch/omic_data/projects/Rnaseqpatho/rna_artefact_Rnaseqpatho.tsv" if config["Project_name"]=="Rnaseqpatho" else [] ,
        #config["current_dir"]+"artefacts_to_add_rna_artefact.tsv" if config["Project_name"]=="MULTIPLI" else [],
        #config["current_dir"]+"rna_artefact_Rnaseqpatho.tsv" if config["Project_name"]=="Rnaseqpatho" else [] ,
=======
        #"/scratch_ssd/reference/annotation/gvx_history/artefacts_to_add_rna_artefact.tsv" if config["Project_name"]=="MULTIPLI" else [],
        #"/scratch/omic_data/projects/Rnaseqpatho/rna_artefact_Rnaseqpatho.tsv" if config["Project_name"]=="Rnaseqpatho" else [] ,
        config["current_dir"]+"artefacts_to_add_rna_artefact.tsv" if config["Project_name"]=="MULTIPLI" else [],
        config["current_dir"]+"rna_artefact_Rnaseqpatho.tsv" if config["Project_name"]=="Rnaseqpatho" else [] ,
>>>>>>> Slurm_development
        config["current_dir"]+"rna_artefact.tsv" if len(config["Project_name"])==0 else [] 
             
    params:
        threshold_occurrence_mutations=config["threshold_occurrence_mutations"],
        col_gene_list_genes=config["colname_genes_list_genes"],
        colname_depth_ALT_allele=config["colname_depth_ALT_allele"], 
        Project_name=config["Project_name"] ,         
        chrom=config["colname_chromosome"],
        start=config["colname_start_position"],
        stop=config["colname_stop_position"],
        ref=config["colname_ref_allele"], 
        alt=config["colname_alt_allele"] ,
        gene=config["colname_gene"] ,
        threshold_depth_ALT_allele=config["threshold_depth_ALT_allele"],
        list_artefact_biologists=config["input_list_artefact_biologists"]
    log:
        "logs/artefact/artefact_to_add.log"
    script:   
        "scripts/RNA_artefact_data.R"  

#=================================================================================================================================================
