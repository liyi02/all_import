#! /bin/bash
#!/bin/bash

list_commend=`ls "../Lianjia_iOS_Shell_Project/Pods/"`

#检测所传参数是否为仓库名
function check_repo () {
for line in $list_commend
do
    if test "$1" = "$line"
    then
        return 1;
    fi
done
return 0;
}

check_repo $1
if test $? = "0"
then
    echo 123;
fi

