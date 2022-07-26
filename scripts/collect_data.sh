################################################ Data collection for the retrospective RNA Artefact study ################################### 
#define tools functions 
clean_create_folders_tmpfile(){
    echo "Clean Result folders"
    rm -r -f $result_output
    echo "Clean tmp file"
    rm -f $file_id_patient
    echo "Clean logging folders"
    rm -rf $logs_output
    echo "Create Result folders"
    mkdir $result_output
    echo "Create logging folders"
    mkdir $logs_output
    echo "Create log file"
    touch $file_log
    
 }
#init result output folder
timestamp=$(date +%s)
result_output=./Raw_variant
file_id_patient=list_id_patients.txt
logs_output=./logs
file_log=${logs_output}/logfile.log 

# set samples dir
samples_dir=/scratch/omic_data/projects/MULTIPLI/ANALYSE
# set sample file
 sample_file=Raw_variant/Union_samples_chrAll.txt
# #set working dir 
working_dir=/scratch/hkhalfaoui/RNA_artefact
ANALYSE=/scratch/omic_data/projects/MULTIPLI/ANALYSE
echo "Start Treatement : $(date)" 
clean_create_folders_tmpfile
#tail -n+2 Multipli-RapportMarieEtHajerU_DATA_LABELS_2022-05-16_1514.csv | cut -d "," -f1 >>$file_id_patient
tail -n+2  $1 | cut -d "," -f1 >>$file_id_patient
echo $2
# while read id_patient 
# do
#     #for filename in ${samples_dir}/${id_patient}-*/Raw_variant/*All.txt*
#     for filename in $2/${id_patient}-*/Raw_variant/*All.txt*
#     do 
#         echo $filename
#         if find $filename| grep -ql '\.txt$' ; then
#             echo $filename
#             fields_num=$(awk '{print NF;exit}' $filename)
#             echo $fields_num
#             if [ $fields_num -eq 79 ] ; then
#                 echo "well done"
#                 #echo $filename | cut $filename -f 1,2,3,4,5,14,23  | less -S  >  ${working_dir}/${result_output}/${id_patient}.txt 
#                 echo $filename | cut $filename -f 1,2,3,4,5,14,23  | less -S  >  $3/${id_patient}.txt
#             else
#                 echo "too long"
#                 #echo $filename | cut $filename -f 1,2,3,4,5,22,31  | less -S >  ${working_dir}/${result_output}/${id_patient}.txt 
#                 echo $filename | cut $filename -f 1,2,3,4,5,22,31  | less -S >  $3/${id_patient}.txt
#              fi
#          fi

#         if find $filename | grep -ql '\.txt.gz$' ; then
#             echo $filename
#             fields_num=$(zcat $filename | awk '{print NF;exit}')
#             echo $fields_num
#             if [ $fields_num -eq 79 ] ; then
#                 echo "well done"
#                 #zcat $filename | cut -f 1,2,3,4,5,14,23  | less -S  >  ${working_dir}/${result_output}/${id_patient}.txt 
#                 zcat $filename | cut -f 1,2,3,4,5,14,23  | less -S  >  $3/${id_patient}.txt

#            else
#                echo "too long"
#                #zcat $filename | cut -f 1,2,3,4,5,22,31  | less -S  >  ${working_dir}/${result_output}/${id_patient}.txt 
#                zcat $filename | cut -f 1,2,3,4,5,22,31  | less -S  >  $3/${id_patient}.txt
#           fi
#        fi 
#     done
# done < ${file_id_patient}

# for file in  /scratch/hkhalfaoui/RNA_artefact/resultats/*.txt
# do 
#      col_name=$(head -n 1 $file | awk '{print $6 }')
#     rename_col="\"MR_DP4_ALT\""
#     sed -i "s/$col_name/$rename_col/g" $file 
#  done 

# # col_name=$(head -n 1 $2 | awk '{print $6 }')
# # rename_col="\"MR_DP4_ALT\""
# # sed -i "s/$col_name/$rename_col/g" $2
# # # done 
# # echo "End Treatement : $(date)" 
