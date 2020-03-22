cd `dirname $0`

for project_name in $(ls); do
    #替换文件
    path="./$project_name/review.sh"
    cp -f ./review.sh $path
    cd "./$project_name"
    #提交代码
    git add review.sh
    git commit -m $1
    sh review.sh 
    cd ..
#    sh review.sh
done



