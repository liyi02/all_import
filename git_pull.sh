#!/bin/sh
#切换分支
cd $(dirname $0)
shell_path=$(pwd)

pull() {
	if [[ -d $1 ]]; then
		cd $1
        echo "\033[32m正在拉取$1 \033[0m"
		git pull --no-log
        
        if [[ $? == "0" ]]; then
            echo "\033[32m拉取$1成功✅ \033[0m\n"
        else
            echo "\033[31m拉取$1失败❌ \033[0m\n"
        fi
		cd ../
            pwd=$(pwd)
        echo "pwd:$pwd"
	fi
}

cd $(dirname $shell_path)
if [[ $1 != "" ]]; then
    for arg in $*
    do
        project_name=$arg
        pull $project_name
    done
	
else
	for project_name in $(ls); do
	    pull $project_name
    done
fi








