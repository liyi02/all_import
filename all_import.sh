#! /bin/bash
#!/bin/bash

m_suffix=".m"
h_suffix=".h"
pch_suffix="pch"

function read_dir(){
for file in ` ls $1 `
    do
        if [ -d $1"/"$file ]
        then
            read_dir $1"/"$file
        else
            fileName=$1"/"$file
            d_suffix=${fileName:0-2:2}
            long_d_suffix=${fileName:0-4:4}
            if test "$d_suffix" = "$m_suffix" || test "$d_suffix" = "$h_suffix"
            then
                echo "hhhhhhh"$fileName
                findWord $fileName
            elif test "$long_d_suffix" = "$pch_suffix"
            then
                echo "pchpchpchpch"$fileName
                findWord $fileName
            fi
        fi
done
}

function findWord(){
    num=1
    cat $1 | while read line
    do
        result=$(echo $line | grep "#import <")
        if [[ "$result" != "" ]]
        then
            echo $line>> findWord.txt
        fi
    num=$((num+1))
    done
    checkReplace "findWord.txt"
}

function checkReplace() {
    sort $1 |uniq > checkReplace.txt
    subSplitStr "checkReplace.txt"
}


#截取字符串
function subSplitStr() {
    cat $1 | while read line;
    do
       result=$(echo $line | grep "/")
       if [[ "$result" != "" ]]
        then
          real_name=${line#*<}
          real_name1=${real_name%%/*}
        else
            real_name=${line#*<}
            real_name1=${real_name%%>*}
        fi
        echo $real_name1>> subSplitStr.txt
    done
     sort "subSplitStr.txt" |uniq > end_result.txt
}


function find_file() {
    cat $1 | while read line;
    do
        if [ `grep -c $line $2` -le '0' ];
        then
            echo $line>> finally_result.txt
        fi
    done
}
left_file=$1
right_file=$2


#测试目录 test
read_dir $1
find_file "end_result.txt" $right_file
