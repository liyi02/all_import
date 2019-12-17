cd `dirname $0`
dir=`pwd`
change_name="false"
dir_name=${dir##*/}


#寻找此此文件是否在当前仓库
function is_current_repo() {
    result=`ls -R ${dir}/${dir_name} | grep -v ^d | awk '{print $1}' | grep $1`
    if [[ "$result" != "" ]]
    then
        return 0
    fi
    return 1
}

#寻找此仓库是否正确依赖
function is_correct_dependent() {
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
    #计算出文件名：左侧剪切掉<与/左侧的字符；右侧剪切掉"或者>以右的字符
    file_name=`echo ${line} |awk -F '/' '{print $NF}'|awk -F '<' '{print $NF}' |awk -F '"' '{print $(NF-1)}' |awk -F '>' '{print $(NF-1)}'`
    is_current_repo $file_name
    if [[ "$?" == "0" ]]
        then
            result=$(echo ${line} | grep '>')
            if [[ "$result" != "" ]]
            then
                #输test出红色文案提醒
                echo "\033[31m${file_name}"这个头文件是本库中的，不需要尖括号方式引用，请修改"\033[0m"
                change_name="true"
            fi
    else
        result=$(echo ${line} | grep '<' | grep '>' | grep '/')
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
