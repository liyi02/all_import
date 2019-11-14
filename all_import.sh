#! /bin/bash
#!/bin/bash

m_suffix=".m"
h_suffix=".h"
pch_suffix=".pch"

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
            echo $line>> liyi_result2.txt
        fi
    num=$((num+1))
    done
    checkReplace "liyi_result2.txt"
}

function checkReplace() {
    sort $1 |uniq > replace.txt
    subSplitStr "replace.txt"
}

function subSplitStr() {
    cat $1 | while read line;
        do
            result=$(echo $line | grep "/")
        if [[ "$result" != "" ]]
        then
            real_name=${line#*<}
            real_name1=${real_name%%/*}
        else
            real_name1=line
        fi
        echo $real_name1>> resultsolit.txt
        done
        sort "resultsolit.txt" |uniq > end_result1.txt
}

#测试目录 test
read_dir $1
