#!/bin/bash
MaxRepoSrh=3
CurRepoCnt=1
FetchFailedRepoCnt=0

#declare function body
function auto_fetch(){
	#stage parent path
	ParentPath=`pwd`
	#echo "${ParentPath: 0: 3}"
	ParentPath=${ParentPath: 0: 3}
	#cd parent path for create a log file which will appending issues by the recursive fetch
	cd "$ParentPath"
	echo "Init">GitAutoFetchLogFile.rtf
	#split line
	echo "----- start -----"
	#total display
	echo "The number of git repository is $#"
	for ProcessingRepo in $*
	do
		#if the path is Non, brake
		if [ 0 -eq "$#" ]
		then
			echo "Non"
			break
		fi
		#the max repo limit
		if test $CurRepoCnt -gt $MaxRepoSrh
		then
			echo "Too many repository, the limit times can be changed using variable <MaxRepoSrh>, and now it is $MaxRepoSrh"
			CurRepoCnt=1
			break
		fi
		#display the index of repo
		echo "----- $CurRepoCnt/$# -----"
		let "CurRepoCnt++"
		#becase of the cmd, the current will been changed by cd and fetch, for the next cycle, we have to make the path back
		cd "$ParentPath"
		#echo "Current path is $ParentPath"
		echo "Git repository path is $ProcessingRepo"
	 	#enter and fetch 
		cd "$ProcessingRepo" && git fetch
		#check whether the cmd completed
		if [ "$?" -eq 0 ]
		then
			echo "Update completed!"
		else
			#fetch error
			cd "$ParentPath"
			#cd "$ProcessingRepo" && git fetch
			let "FetchFailedRepoCnt++"
			#print the path that fetch failed in the log file named GitAutoFetchLogFile
			echo "$FetchFailedRepoCnt- $ProcessingRepo">>GitAutoFetchLogFile.rtf
		fi
	done
	#go to the parent path to substitute the first line "Init" by the result of script
	cd "$ParentPath"
	if [ "$FetchFailedRepoCnt" -eq 0 ]
	then 
		sed -i "s/Init/Congratulations! All the repository we found have been upgrade!/g" GitAutoFetchLogFile.rtf
	else
		sed -i "s/Init/On no! There are $FetchFailedRepoCnt repositories can not update automaticaly, may be network error or the local file has diff with remote, use the command <git status> to confirm current status/g" GitAutoFetchLogFile.rtf
		#reset the cnt, or the next invoke will cnt continue
		FetchFailedRepoCnt=0
	fi
}
#auto_fetch `find . -name .git|xargs dirname`
#auto_fetch .
#echo "Enter D://"
#auto_fetch `find D://* -mount -maxdepth 4 -not -path "C:\\*" -a -name .git|xargs dirname`
echo "Enter E://"
cd "E://"
auto_fetch `find E://* -mount -maxdepth 4 -not -path "C:\\*" -a -name .git|xargs dirname`
echo "Enter F://"
cd "F://"
auto_fetch `find F://* -mount -maxdepth 4 -not -path "C:\\*" -a -name .git|xargs dirname`
#echo "Enter G://"
#auto_fetch `find G://* -mount -maxdepth 4 -not -path "C:\\*" -a -name .git|xargs dirname`
