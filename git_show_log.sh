
cd `dirname $0`
dir=`pwd`
h_suffix=".h"
library_name=""

#寻找是不是库名
function is_repo_name(){
    result=$(echo `ls "../Lianjia_iOS_Shell_Project/Pods/"` | grep $1)
    if [[ "$result" != "" ]]
    then
        return 1
    fi
    return 0
}

#寻找此此文件是否在当前仓库
function is_current_repo(){
podspec_name=${dir##*/}
    result=`ls -R ${dir}/${podspec_name} |grep -v ^d | awk '{print $1}' | grep $1`
    if [[ "$result" != "" ]]
    then
        return 1
    fi
    return 0
}

#寻找此仓库是否被正确依赖
function is_repo_dependent(){
    podspec_name=${dir##*/}
    result=`cat "${dir}/${podspec_name}.podspec" | grep $1`
    if [[ "$result" != "" ]]
    then
        return 1
    fi
    return 0
}

function finish_execute(){
# rm -f all_diff.txt
exit $1
}

function find_library_name(){
    library_name=""
    result=`find ../Lianjia_iOS_Shell_Project/Pods/Headers -name $1 | grep "Public/"`
    if [[ "$result" != "" ]]
    then
        library_name=${result#*Public/}
        library_name=${library_name%%/*}
    fi
    if [[ "$library_name" != "" ]]
    then
        return 1
    fi
    
    result=`find ../Lianjia_iOS_Shell_Project/Pods/Headers -name $1 | grep "Private/"`
    if [[ "$result" != "" ]]
    then
        library_name=${result#*Private/}
        library_name=${library_name%%/*}
    fi
    if [[ "$library_name" != "" ]]
    then
        return 1
    fi
    
    return 0
}

git show> all_diff.txt
cat all_diff.txt > all_diff1.txt
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
                
                is_repo_name $real_name_before
                if test $? = "1"
                then #如果/前边的是仓库名
                    is_repo_dependent $real_name_before
                    if test $? = 0 #本仓库没有正确依赖了这个.h文件所在仓库
                    then
                        echo ${real_name_before}没有被这个仓库依赖，请正确依赖
                        finish_execute 1
                    fi
                else #如果/前边的不是仓库名，匹配/后面的
                    find_library_name $real_name_after
                    if [[ "$library_name" != "" ]]
                    then
                        is_repo_dependent $library_name
                        if test $? = 0 #本仓库没有正确依赖了这个.h文件所在仓库
                        then
                            echo ${library_name}没有被这个仓库依赖，请正确依赖
                            finish_execute 1
                        fi
                    fi
                fi

            else
                #场景3#import<B.h>
                real_name=${line#*<}
                real_name=${real_name%%>*}
                #判断当前库中是否包含这个头文件
                is_current_repo $real_name
                if [[ "$?" == "0" ]]
                then
                    #当前库不包含这个头文件，找到这个文件所在
                    find_library_name $real_name
                    if [[ "$library_name" != "" ]]
                    then
                        is_repo_dependent $library_name
                        if test $? = 0 #本仓库没有正确依赖了这个.h文件所在仓库
                        then
                            echo ${library_name}没有被这个仓库依赖，请正确依赖
                            finish_execute 1
                        fi
                    fi
                fi
                
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
                
                is_repo_name $real_name_before
                if test $? = 1
                then #如果/前边的是仓库名
                    is_repo_dependent $real_name_before
                    if test $? = 0 #如果是仓库名且本仓库正确依赖了这个仓库
                    then
                        echo ${real_name_before}没有被这个仓库依赖，请正确依赖
                        finish_execute 1;
                    fi
                else #如果/前边的不是仓库名，匹配/后面的
                    find_library_name $real_name_after
                    if [[ "$library_name" != "" ]]
                    then
                        is_repo_dependent $library_name
                        if test $? = 0 #本仓库没有正确依赖了这个.h文件所在仓库
                        then
                            echo ${library_name}没有被这个仓库依赖，请正确依赖
                            finish_execute 1;
                        fi
                    fi
                fi
                
                #调用易哥的方法
                else
                    # 场景4#import"B.h"
                    real_name=${line#*\"}
                    real_name=${real_name%%\"}
                    #判断当前库中是否包含这个头文件
                    is_current_repo $real_name
                    if [[ "$?" == "0" ]]
                    then
                        #当前库不包含这个头文件，找到这个文件所在
                        find_library_name $real_name
                        if [[ "$library_name" != "" ]]
                        then
                            is_repo_dependent $library_name
                            if test $? = 0 #本仓库没有正确依赖了这个.h文件所在仓库
                            then
                                echo ${library_name}没有被这个仓库依赖，请正确依赖
                                finish_execute 1;
                            fi
                        fi
                    fi
                 fi
            fi
        fi
    fi
done






