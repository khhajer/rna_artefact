################################################ Data collection for the retrospective RNA Artefact study ###################################  
echo "Start Treatement : $(date)" 

if find $1| grep -ql '\.txt$' ; then
    echo $1
    fields_num=$(awk '{print NF;exit}' $1)
    echo $fields_num
    if [[ $fields_num -eq 79 ]] ; then
        echo "well done"
        echo $1 | cut $1 -f 1,2,3,4,5,14,23  | less -S  >>  $2
    else
        echo "too long"
        echo $1 | cut $1 -f 1,2,3,4,5,22,31  | less -S >>  $2
    fi
fi

if find $1 | grep -ql '\.txt.gz$' ; then
    echo $1
    fields_num=$(zcat $1| awk '{print NF;exit}')
    echo $fields_num
    if [[ $fields_num -eq 79 ]] ; then
        echo "well done"
        zcat $1| cut -f 1,2,3,4,5,14,23  | less -S  >>  $2

    else
        echo "too long"
        zcat $1 | cut -f 1,2,3,4,5,22,31  | less -S  >> $2
    fi
fi 

# Rename col of final file 
col_name=$(head -n 1 $2 | awk '{print $6 }')
rename_col="\"MR_DP4_ALT\""
sed -i "s/$col_name/$rename_col/g" $2

echo "End of collecting data : $(date)" 
##########################################################################################################################################################################""