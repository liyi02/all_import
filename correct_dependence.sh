cd `dirname $0`
dir=`pwd`
change_name="false"



#寻找此此文件是否在当前仓库
function is_current_repo() {
    podspec_name=${dir##*/}
    result=`ls -R ${dir}/${podspec_name} | grep -v ^d | awk '{print $1}' | grep $1`
    if [[ "$result" != "" ]]
    then
        return 0
    fi
    return 1
}

#寻找此仓库是否正确依赖
function is_correct_dependent() {
    podspec_name=${dir##*/}
    result=`cat ${dir}/*.podspec | grep $1`
    if [[ "$result" != "" ]]
    then
        return 0
    fi
    return 1
}
rm result.txt

echo "`git show | sort | uniq | grep '^+*#import'`">result.txt

while read line
do
    file_name=`echo ${line} |awk -F '[/]' '{print $NF}' |awk -F '["]' '{print $(NF-1)}' |awk -F '[>]' '{print $(NF-1)}'`
    is_current_repo $file_name
    if [[ "$?" == "0" ]]
        then
            result=$(echo ${line} | grep $file_name | grep '>')
            if [[ "$result" != "" ]]
            then
                #输test出红色文案提醒
                echo "\033[31m${file_name}"这个头文件是本库中的，不需要尖括号方式引用，请修改"\033[0m"
                change_name="true"
            fi
    else
        result=$(echo ${line} | grep $file_name | grep '<' | grep '>' | grep '/')
        if [[ "$result" == "" ]]
        then
            #输出红色文案提醒
            echo "\033[31m${file_name}"这个头文件是其他库中的，需要用尖括号库名斜杠类名方式引用，请修改"\033[0m"
            change_name="true"
        else
            repo_name=`echo ${line} |awk -F '[/]' '{print $1}' | awk -F '[<]' '{print $NF}'`
            is_correct_dependent $repo_name
            if [[ "$?" == "1" ]]
            then
                #输出红色文案提醒
                echo "\033[31m$repo_name"没有被本仓库依赖，请正确依赖"\033[0m"
                change_name="true"
            fi
        fi
    fi
done< result.txt

rm result.txt

if [ $change_name == "true" ]
    then
    exit 1
else
    exit 0
fi
