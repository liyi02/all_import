
cd `dirname $0`
dir=`pwd`
git show> all_diff.txt

cat all_diff.txt | while read line
do
    result=$(echo $line | grep "+")
    if [[ "$result" != "" ]]
    then
        #场景1#import<A/B.h>
        #场景2#import"A/B.h"
        #场景3#import<B.h>
        #场景4#import"B.h"
    result=$(echo $line | grep "#import <")
        if [[ "$result" != "" ]]
        then
            result=$(echo $line | grep "/")
            if [[ "$result" != "" ]]
            then
                #场景1#import<A/B.h>
                real_name=${line#*<}
                #库名
                real_name_before=${real_name%%/*}
                #后面的.h
                real_name_after_pex=${real_name##*/}
                real_name_after=${real_name_after_pex: -1}
                #对库名real_name_before处理，搜索不到库名
                #对real_name_after进行处理
                echo $real_name_before>> findWord.txt
                echo $real_name_before>> findWord.txt

            else
                #场景3#import<B.h>
                real_name=${line#*<}
                real_name=${real_name%%>*}
                #对real_name进行处理
                echo  $real_name>> findWord.txt
            fi
        else
        result=$(echo $line | grep "#import \"")
            if [[ "$result" != "" ]]
            then
                result=$(echo $line | grep "/")
                if [[ "$result" != "" ]]
                then
                #场景2#import"A/B.h"
                real_name=${line#* \"}
                #库名
                real_name_before=${real_name%%/*}
                #后面的.h
                real_name_after_pex=${real_name##*/}
                real_name_after=${real_name_after_pex: -1}
                #对库名real_name_before处理，搜索不到库名
                #对real_name_after进行处理
                echo  $real_name_before>> findWord.txt
                echo  $real_name_before>> findWord.txt
                
                else
                    # 场景4#importB.h
                    real_name=${line#*\"}
                    real_name=${real_name%%\"}
                    #判断当前库中是否包含这个头文件
                    echo $real_name>> findWord.txt

                    if [[ `grep -c $real_name "all_file.txt"` -le '0' ]];
                    then
                        #不包含就对real_name进行处理
                        echo #场景-----4 $real_name>> findWord.txt
                    fi
                 fi
            fi
        fi
    fi
done


