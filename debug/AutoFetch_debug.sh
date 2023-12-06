#!/bin/bash
echo "Init">log.rtf
MaxCnt=15
CurCnt=1
PullFailedCnt=0
#stage parent path
CurrentPath=`pwd`

#declare function body
function auto_fetch(){
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
		cd "$CurrentPath"
		echo "Current path is $CurrentPath"
		echo "Git repository path is $GitPath"
	 	#enter and pull 
		cd "$GitPath" && git pull
		if [ "$?" -eq 0 ]
		then
			echo "Update completed!"
		else
			#pull merge error, use fetch cmd, but pull can also fetch the revision
			cd "$CurrentPath"
			#cd "$GitPath" && git fetch
			let "PullFailedCnt++"
			echo "$PullFailedCnt- $GitPath">>log.rtf
		fi
	done
	cd "$CurrentPath"
		if [ "$PullFailedCnt" -eq 0 ]
		then 
			sed -i "s/Init/Congratulations! All the repository we found have been upgrade!/g" log.rtf
		else
			sed -i "s/Init/On no! There are $PullFailedCnt repositories can not update automaticaly, may be the local file has diff with remote, use the command <git status> to make sure current status/g" log.rtf
		fi
}
#auto_fetch `find . -name .git|xargs dirname`
#auto_fetch .
#echo "Enter D://"
#auto_fetch `find D://* -mount -maxdepth 4 -not -path "C:\\*" -a -name .git|xargs dirname`
#echo "Enter E://"
#auto_fetch `find E://* -mount -maxdepth 4 -not -path "C:\\*" -a -name .git|xargs dirname`
echo "Enter F://"
auto_fetch `find F://* -mount -maxdepth 4 -not -path "C:\\*" -a -name .git|xargs dirname`
#echo "Enter G://"
#auto_fetch `find G://* -mount -maxdepth 4 -not -path "C:\\*" -a -name .git|xargs dirname`
