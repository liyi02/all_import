#! /bin/bash
#!/bin/bash

m_suffix=".m"
h_suffix=".h"
pch_suffix="pch"
repo_name=""
first_param=$1
second_param=$2
third_param=$3
library_name=""

function read_dir(){
for file in ` ls $1 `
    do
        if [[ -d $1"/"$file ]]
        then
            read_dir $1"/"$file
        else
            fileName=$1"/"$file
            d_suffix=${fileName:0-2:2}
            long_d_suffix=${fileName:0-4:4}
            if test "$d_suffix" = "$m_suffix" || test "$d_suffix" = "$h_suffix"
            then
                findWord $fileName
            elif test "$long_d_suffix" = "$pch_suffix"
            then
                findWord $fileName
            fi
        fi
done
}

function findRepoName(){
    for file in ` ls $1 `
    do
        if [[ -d $1"/"$file ]]
        then
            findRepoName $1"/"$file
        else
            fileName=$1"/"$file
            repo_real_name=${fileName##*/}
            if test "$repo_real_name" = "$repo_name"
            then
            deal_name=${fileName##*Public/}
            deal_name=${deal_name%%/*}
            library_name=$deal_name
            fi
        fi
    done
}

function findWord(){
    cat $1 | while read line
    do
        result=$(echo $line | grep "#import <")
        if [[ "$result" != "" ]]
        then
            result=$(echo $line | grep "/")
            if [[ "$result" != "" ]]
            then
                real_name=${line#*<}
                real_name=${real_name%%/*}
            else
                real_name=${line#*<}
                real_name=${real_name%%>*}
            fi
            echo $real_name>> findWord.txt
        else
        result=$(echo $line | grep "#import \"")
            if [[ "$result" != "" ]]
            then
                #截取字符串
                real_name=0
                real_name=${line#*\"}
                real_name=${real_name%%\"}
                repo_name=$real_name
                if [[ `grep -c $real_name "all_file.txt"` -le '0' ]];
                then
                    library_name=""
                    findRepoName $third_param
                    if [[ "$library_name" != "" ]]
                    then
                        echo $library_name>> findWord.txt
                        new_string="<$library_name\/$real_name>"
                        origin_string="\"$real_name\""
                        sed -i "" "s/$origin_string/$new_string/g" "$1"
                    fi
                fi
            fi
        fi
    done
    checkReplace "findWord.txt"
}

function checkReplace() {
    sort $1 |uniq > checkReplace.txt
}


function find_file() {
    cat $1 | while read line;
    do
        if [[ `grep -c $line $2` -le '0' ]];
        then
            echo $line>> finally_result.txt
        fi
    done
}

function find_all_file () {

for file in ` ls $1 `
    do
        if [[ -d $1"/"$file ]]
        then
            find_all_file $1"/"$file
        else
            fileName=$1"/"$file
            fileName=${fileName##*/}

            d_suffix=${fileName:0-2:2}
            long_d_suffix=${fileName:0-4:4}
            if test "$d_suffix" = "$m_suffix" || test "$d_suffix" = "$h_suffix" || test "$long_d_suffix" = "$pch_suffix"
            then
                echo $fileName>> all_file.txt
            fi
            
        fi
done
}


#测试目录 test
find_all_file $1
read_dir $1
find_file "checkReplace.txt" $2

