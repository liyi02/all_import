
cd `dirname $0`
dir=`pwd`
h_suffix=".h"


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
                real_name_after=${real_name_after_pex%%>*}
                #对库名real_name_before处理，搜索不到库名
                #对real_name_after进行处理
                echo $real_name_before>> findWord.txt
                echo $real_name_after>> findWord.txt
                #调用易哥的方法
            else
                #场景3#import<B.h>
                real_name=${line#*<}
                real_name=${real_name%%>*}
                #对real_name进行处理
                echo  $real_name>> findWord.txt
                #调用易哥的方法
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
                echo  $real_name_after>> findWord.txt
                #调用易哥的方法
                else
                    # 场景4#importB.h
                    real_name=${line#*\"}
                    real_name=${real_name%%\"}
                    echo `ls -R "./"`>result.txt
                    result=$(echo `ls -R "./"`|grep $real_name)
                    if [[ "$result" == "" ]]
                    then
                        #判断当前库中是否包含这个头文件
                        echo $real_name>> findWord.txt
                        #不包含就对real_name进行处理
                        #调用易哥的方法
     
                    fi
                 fi
            fi
        fi
    fi
done





