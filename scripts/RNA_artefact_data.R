
#=================================================================================================================================================================
#                                                        load libraries      
#=================================================================================================================================================================

library(dplyr)
library(fs)
library(tidyverse)
library(stringr)
library(data.table)

#=================================================================================================================================================================
#                                                        log file for RNA_artefact_data.R        
#=================================================================================================================================================================

log_file <- file(snakemake@log[[1]], open = "a")
sink(log_file, type = "message")
sink(log_file, type = "output")

#=================================================================================================================================================================
#                                                                load general params 
#=================================================================================================================================================================

print("load general params")
threshold_occurrence_mutations=snakemake@params[["threshold_occurrence_mutations"]]
col_gene_list_genes=snakemake@params[["col_gene_list_genes"]]
depth=snakemake@params[["threshold_depth_ALT_allele"]]
Project_name=snakemake@params[["Project_name"]]

#=================================================================================================================================================================
#                                                               load colname of mutations file: 
#=================================================================================================================================================================

print("load colname of mutations file")
col_chrom=as.name(snakemake@params[["chrom"]])
col_start=as.name(snakemake@params[["start"]])
col_stop=as.name(snakemake@params[["stop"]])
col_ref=as.name(snakemake@params[["ref"]])
col_alt=as.name(snakemake@params[["alt"]])
col_gene=as.name(snakemake@params[["gene"]])
colname_depth_ALT_allele=as.name(snakemake@params[["colname_depth_ALT_allele"]])
#load list artefacts biologists file :
list_artefact_biologists=snakemake@params[["list_artefact_biologists"]]

#=================================================================================================================================================================
#                                                                list genes 
#=================================================================================================================================================================

if(nchar(col_gene_list_genes)==0){
  print ("genes list parameter is empty")
}else{
  print("genes list parameter is not empty")
  print("load genes list file")
  list_genes=read.delim(snakemake@input[["input_list_gene"]])
  print(list_genes[[col_gene_list_genes]])
}

#=================================================================================================================================================================
#                                                               get all mutations files
#=================================================================================================================================================================

print("get all mutations files")
files=list.files(path=dirname(snakemake@input[["input_files"]][1]),pattern="*.txt",full.names=TRUE)

#================================================================================================================================
#                                                  get numbers of patients
#=================================================================================================================================

print("get numbers of patient")
nb_of_patients=length(files)
print("nombre of patients")
print(nb_of_patients)

#================================================================================================================================
#                                                    Functions to process data 
#=================================================================================================================================

read_file=function(files_path){
  read_tsv(files_path ,col_types=cols(!!col_gene:=col_character()))
}
process_data=function(data){
  
  if( depth!=0 && threshold_occurrence_mutations!=0){
    print("Filter Mutation by Depth of Alternative Allele")
    data=data%>%filter(!!colname_depth_ALT_allele >= depth)
    print(data)
  }else{
    print("Depth of Alternative Allele not Define ")
    data=data
  }

  if(nchar(col_gene_list_genes)!=0 && threshold_occurrence_mutations!=0){
    print("Filter Mutation by List of Genes")
    data=data%>%mutate(!!col_gene:=gsub("'","",!!col_gene))%>%filter(!!col_gene %in% list_genes[[col_gene_list_genes]])
    print(data)
  }else{
    print("There is not List of Genes to filter data")
    data=data
  }
  
  
}
#================================================================================================================================
#                                                    Start Treatment for Rna_Artefact MULTIPLI
#=================================================================================================================================

print("Start Treatment for Rna_Artefact MULTIPLI")
proccesed_data_list=map (files,~{
  data=read_file(.x)
  process_data(data)
})
print(proccesed_data_list)

#================================================================================================================================
#                                                    Create data set for all muations
#=================================================================================================================================

print("Create data set for all muations ")
all_RNA_mutations=rbindlist(proccesed_data_list,fill=TRUE)
if(threshold_occurrence_mutations!=0){
    print("calcul frequency of mutation")
    all_RNA_mutations=all_RNA_mutations%>%mutate(key:=paste(!!col_gene,!!col_chrom,!!col_start,!!col_stop,!!col_ref,!!col_alt,sep = ":"))%>%
    group_by(key)%>%count(key)%>%mutate(freq_of_mutations=(n/nb_of_patients)*100)%>%arrange(desc(freq_of_mutations))
    print(data)
    
    if(Project_name=="MULTIPLI" && threshold_occurrence_mutations!=0){
      print("proccessing occurrence of mutation for MULTIPLI project")
      all_RNA_mutations=all_RNA_mutations%>%mutate(artefact=case_when(freq_of_mutations>=threshold_occurrence_mutations ~ "RNA_ARTEFACT", freq_of_mutations<threshold_occurrence_mutations ~ "NO_ARTEFACT_DETECTED"))%>%
      filter(artefact=="RNA_ARTEFACT")%>%mutate(annote="YES")%>%select(key,artefact,annote)%>%arrange(key)
      all_RNA_mutations[c('GENE','CHROM','START','STOP','REF','ALT')]=str_split_fixed(all_RNA_mutations$key,":",6)
      all_RNA_mutations=all_RNA_mutations[c('GENE','CHROM','START','STOP','REF','ALT','artefact','annote')]
      all_RNA_mutations=all_RNA_mutations[,-c(1,4)]
    }else{
      all_RNA_mutations=all_RNA_mutations%>%filter(freq_of_mutations>=threshold_occurrence_mutations)%>%select(key,freq_of_mutations)
      all_RNA_mutations=all_RNA_mutations%>%mutate(artefact="RNA_ARTEFACT_frequency")
    }
  }else{
    stop("ERREUR!!! :You Must define Threshold Occurrence Mutation")
    
  }

#================================================================================================================================
#                                                     add list artefact biologists if exist
#=================================================================================================================================

print("add list artefact biologists if exist")
if (Project_name=="MULTIPLI" ){
  print("add list artefacts biologists for MULTIPLI project")
  if(file.exists(snakemake@params[["list_artefacts_biologists"]])){
  data_artefacts_biologists=read_delim(snakemake@params[["list_artefacts_biologists"]])
  data_artefacts_biologists=data_artefacts_biologists%>%select(CHROM,START,REF,ALT)%>%mutate(artefact="RNA_ARTEFACT_list",annote="YES")
  result_list_artefact=rbind(data_artefacts_biologists,all_RNA_mutations)

  }else{
    print("there is no list artefacts biologists to add for MULTIPLI project")
    result_list_artefact=all_RNA_mutations
  }

}else{
  if(file.exists(snakemake@params[["list_artefacts_biologists"]] )){
  print("add list artefacts biologists")
  data_artefacts_biologists=read_delim(snakemake@params[["list_artefacts_biologists"]])
  print(data_artefacts_biologists)
  data_artefacts_biologists=data_artefacts_biologists%>%mutate(key=paste(CHROM,START,STOP,REF,ALT,sep=":"),freq_of_mutations=100,artefact="RNA_ARTEFACT_list")%>%select(key,freq_of_mutations,artefact)
  result_list_RNA_artefact=rbind(data_artefacts_biologists,all_RNA_mutations)

  }else{
    print("there is no list artefacts biologists to add !!")
    result_list_RNA_artefact=all_RNA_mutations
  }

}

#================================================================================================================================
#                                                     create final result
#=========================================================================================================================

print("create final result")
if (Project_name=="MULTIPLI"){
  file.create(snakemake@output[[1]])
  write.table(result_list_RNA_artefact, file=snakemake@output[[1]], col.names = F,row.names = F, quote = F,sep = "\t",na = "")
}else{
  file.create(snakemake@output[[1]])
  write.table(result_list_RNA_artefact, file=snakemake@output[[1]], col.names = T,row.names = T, quote = F,sep = "\t",na = "")
}

print("END TREATMENT")
sink(type = "message")
sink(type = "output")
close(log_file)

#=======================================================================================================================================================================
