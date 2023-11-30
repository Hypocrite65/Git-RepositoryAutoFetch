#!/bin/bash
#export TOP_PID=$$ 
#function check_par(){
#	if [ ! -d "$1"];then
#		echo "Enter the outermost path to avoid finding unnecessary paths"
#		kill -s TERM $TOP_PID
#	fi
#}
#check_par
#stage parent path
CurrentPath=`pwd`
MaxCnt=20
CurCnt=1
#declare function body
function auto_fetch(){
	echo "----- start -----"
	echo "The number of git repository is $#"
	for RelativePath in $*
	do
		if test $CurCnt -gt $MaxCnt
		then
			echo "Too many repository, the limit times can be changed by variable <MaxCnt>, and now it is $MaxCnt"
			CurCnt=1
			break
		fi
		echo "----- $CurCnt -----"
		let "CurCnt++"
		RelativePath=${Relative%/*}
		GitPath="$CurrentPath/${RelativePath#*/}"
		echo "Git repository path is $GitPath"
		#check wether the target path is complete
		if test -d $GitPath 
		then
			#enter and fetch
			cd $GitPath && git status && git fetch
		fi
		
	done
}
auto_fetch `find . -mount -not -path "C:/*" -a -name .git`
