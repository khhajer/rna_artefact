#install.packages("dplyr") 
#install.packages("tidyverse")
#install.packages("stringr")
#install.packages("fs")
library(dplyr)
library(fs)
library(tidyverse)
library(stringr)
log <- file(snakemake@log[[1]], open="wt")
sink(log)
#====================================================================================================================================================================
#                                                       Remove all slurm-xxx.out from the previous step 
#================================================================================================================================================================
dir <- paste(getwd(),"/",sep="")
delfiles <- dir(path=dir ,pattern="slurm-*")
file.remove(file.path(dir, delfiles))
#=================================================================================================================================================================
#                                                         Redcapfile :patients informations
#=================================================================================================================================================================
Redcap_infoSamples=read.delim(snakemake@input[[1]],header =T,sep = ",")%>%select(Patient.ID,Tumor.RNA.platform)
Redcap_infoSamples=Redcap_infoSamples%>%filter(str_detect(Tumor.RNA.platform,"Seq"),str_detect(Patient.ID,"OLD")==F)
Redcap_infoSamples=Redcap_infoSamples%>%mutate(Tumor.RNA.platform=str_replace(str_to_upper(Tumor.RNA.platform),"6000",""))%>%rename(PATIENT=Patient.ID,arn_platform=Tumor.RNA.platform)

#====================================================================================================================================================================
#                                                       list genes : panel census
#====================================================================================================================================================================

census_panel=read.delim(snakemake@input[[2]],header = T)

#====================================================================================================================================================================
#                                                          Raw_variant : list files
#====================================================================================================================================================================
print("START TREATMENT")
files = dir_ls(paste(getwd(),"/Raw_variant",sep=""))
df_list = map(files, read_tsv)
all_RNA_mutations=bind_rows(df_list, .id = 'PATIENT')%>% mutate(PATIENT= str_match(PATIENT,paste(getwd(),"/Raw_variant/(.*)\\.txt",sep=""))[,2],GENE=gsub("'","",GENE))%>%
filter(MR_DP4_ALT>=10 ,GENE %in% census_panel$GENE)%>%rowwise()%>%mutate(key = paste(CHROM,as.numeric(START),REF,ALT,sep = ":"), PATIENT=str_sub(PATIENT,1,12))
all_RNA_mutations=all_RNA_mutations%>%group_by(PATIENT)%>%filter(!duplicated(START)) 

#==================================================================================================================================================================
#                                                           merge raw_variant files with Redcap file informations
#==================================================================================================================================================================

all_RNA_mutations=merged.data <- merge(all_RNA_mutations, Redcap_infoSamples, by="PATIENT")
Patient_RNA_platform=(all_RNA_mutations%>%group_by(PATIENT)%>%count(arn_platform))

#=================================================================================================================================================================
#                                                                 calculate the frequency of mutations by platform                                        
#====================================================================================================================================================================
 nb_Patient_by_Platform = function (platforme_sequecing) {
  nb_samples=0
   for (i in 1:length(Patient_RNA_platform$arn_platform)){
     if(Patient_RNA_platform$arn_platform[i]==platforme_sequecing){
      nb_samples=nb_samples+1
    }
  }
  return(nb_samples)
  }
nb_Patient_NOVASEQ=nb_Patient_by_Platform("NOVASEQ")
nb_Patient_NEXTSEQ=nb_Patient_by_Platform("NEXTSEQ")
nb_Patient_NEXTSEQ
nb_Patient_NOVASEQ
frequency_mutation_byPatient=all_RNA_mutations%>%group_by(key)%>%count(arn_platform)%>%mutate(frequency= case_when (arn_platform=="NOVASEQ"
  ~ n/nb_Patient_NOVASEQ,arn_platform=="NEXTSEQ"~n/nb_Patient_NEXTSEQ))

#===================================================================================================================================================================
#                                                                         annote artefact and create the final file : artefact to add 
#========================================================================================================================================================================

Annot_ARTEFACT=frequency_mutation_byPatient%>%group_by(key)%>%mutate(artefact=case_when(frequency>=0.5  ~ "RNA_ARTEFACT", frequency<0.5 ~ "NO_ARTEFACT_DETECTED"))%>%
  select(key,frequency,artefact)%>%filter(artefact=="RNA_ARTEFACT")

select_column=all_RNA_mutations%>%select(CHROM,START,STOP,REF,ALT,key)
merge_info=merged.data<-merge(Annot_ARTEFACT,select_column,by="key")%>%mutate(ANNOTE="YES")%>%filter(!duplicated(key))%>%arrange(desc(START))

print("merge info")
artefact_to_add=merge_info%>%select(CHROM,START,REF,ALT,ANNOTE,artefact)%>%arrange(desc(START))

print("add artefact")

file.create(file.path("/trinity/home/prod_user/pipeline/rna_artefact/", snakemake@output[[1]]))
write.table(artefact_to_add, file =  paste("/trinity/home/prod_user/pipeline/rna_artefact/",snakemake@output[[1]],sep=""), col.names = F,row.names = F, quote = F,sep = "\t",na = "")
print("END TREATMENT")

#=======================================================================================================================================================================
