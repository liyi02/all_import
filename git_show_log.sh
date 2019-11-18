
cd `dirname $0`
dir=`pwd`
h_suffix=".h"

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

git show> all_diff.txt
sort all_diff.txt |uniq > all_diff1.txt
cat all_diff1.txt | while read line
do
    result=$(echo $line | grep "+")
    if [[ "$result" != "" ]]
    then
        result=$(echo $line | grep "#import <")
        if [[ "$result" != "" ]]
        then
            result=$(echo $line | grep "/")
            if [[ "$result" != "" ]]
            then
                real_name=${line#*<}
                real_name_before=${real_name%%/*}
                is_repo_dependent $real_name_before
                if test $? = 0
                then
                echo ${real_name_before}"没有被这个仓库依赖，请正确依赖">>result.txt
            fi
            else
                real_name=${line#*<}
                real_name=${real_name%%>*}
                echo ${real_name}"其他仓库的头文件不可以使用<>不带库名的方式引入，请修改">>result.txt
            fi
        else
        result=$(echo $line | grep "#import \"")
            if [[ "$result" != "" ]]
            then
                result=$(echo $line | grep "/")
                if [[ "$result" != "" ]]
                then
                    real_name=${line#* \"}
                    real_name_before=${real_name%%/*}
                    is_repo_dependent $real_name_before
                    if test $? = 0
                    then
                    echo ${real_name_before}"没有被这个仓库依赖，请正确依赖">>result.txt
                    fi
                else
                    real_name=${line#*\"}
                    real_name=${real_name%%\"}
                    is_current_repo $real_name
                    if [[ "$?" == "0" ]]
                    then
                    echo ${real_name}"不是本仓库的头文件，请使用<库名/类名>的方式引用">>result.txt
                    fi
                 fi
            fi
        fi
    fi
done


if [ -s "result.txt" ];
then
   cat "result.txt" | while read line
   do
       echo $line
   done
   rm -f all_diff.txt
   rm -f all_diff1.txt
   rm -f result.txt
   exit 1
else
   exit 1
   rm -f all_diff.txt
   rm -f all_diff1.txt
fi





