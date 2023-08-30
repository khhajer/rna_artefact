################################################ Data collection for the retrospective RNA Artefact study ###################################  
echo "Start Treatement : $(date)" 
if [ "$3" == "MULTIPLI" ] ;
then
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
fi
if [ "$3" == "Rnaseqpatho" ] ;
then
    if find $1 | grep -ql '\.txt$' ; then
        echo $1
        fields_num=$(cat $1| awk '{print NF;exit}')
        echo $fields_num
        if [[ $fields_num -eq 70 ]] ; then
            cat $1| cut -f 1,2,3,4,5,6,15,21-26  | less -S  >>  $2 
        elif [[ $fields_num -eq 166 ]] ; then
            cat $1| cut -f 1,2,3,4,5,6,111,117-122  | less -S  >>  $2 
        elif [[ $fields_num -eq 126 ]] ; then
            cat $1| cut -f 1,2,3,4,5,6,71,77-82 | less -S  >>  $2
        else
            echo "file has a different fields number !!! "
        fi
    else
        echo "the file dosn't exist !!!"
    fi
fi
# Rename patient_id-set-MR_DP4_ALT col to MR_DP4_ALT of final file 
col_name=$(head -n 1 $2 | awk '{print $6 }')
rename_col="\"MR_DP4_ALT\""
sed -i "s/$col_name/$rename_col/g" $2

echo "End of collecting data : $(date)" 
##########################################################################################################################################################################""