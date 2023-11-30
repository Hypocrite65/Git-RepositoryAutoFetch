#!/bin/bash
#
MaxCnt=15
CurCnt=1
#declare function body
function auto_fetch(){
	#stage parent path
	CurrentPath=`pwd`
	echo "----- start -----"
	echo "The number of git repository is $#"
	for GitPath in $*
	do
		if [ 0 -eq "$#" ]
		then
			echo "Non"
			break
		fi

		if test $CurCnt -gt $MaxCnt
		then
			echo "Too many repository, the limit times can be changed by variable <MaxCnt>, and now it is $MaxCnt"
			CurCnt=1
			break
		fi
		echo "----- $CurCnt/$# -----"
		let "CurCnt++"
		echo "Git repository path is $GitPath"
		#enter and fetch
		cd "$GitPath" && git status && git fetch
		
	done
}
echo "Enter D://"
auto_fetch `find D://* -mount -maxdepth 4 -not -path "C:\\*" -a -name .git|xargs dirname`
echo "Enter E://"
auto_fetch `find E://* -mount -maxdepth 4 -not -path "C:\\*" -a -name .git|xargs dirname`
echo "Enter F://"
auto_fetch `find F://* -mount -maxdepth 4 -not -path "C:\\*" -a -name .git|xargs dirname`
echo "Enter G://"
auto_fetch `find G://* -mount -maxdepth 4 -not -path "C:\\*" -a -name .git|xargs dirname`
