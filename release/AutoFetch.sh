#!/bin/bash
MaxRepoSrh=35
CurRepoCnt=1
FetchFailedRepoCnt=0
Current_time=`date +"%Y-%m-%d %H:%M:%S"`
#declare function body
function auto_fetch(){
	#stage parent path
	ParentPath=`pwd`
	#echo "${ParentPath: 0: 3}"
	ParentPath=${ParentPath: 0: 3}
	#cd parent path for create a log file which will appending issues by the recursive fetch
	cd "$ParentPath"
	echo "Init">GitAutoFetchLogFile.txt
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
		cd "$ProcessingRepo" && git fetch --all
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
			echo "$FetchFailedRepoCnt- $ProcessingRepo">>GitAutoFetchLogFile.txt
		fi
	done
	#go to the parent path to substitute the first line "Init" by the result of script
	cd "$ParentPath"
	echo "Run time is :$Current_time">>GitAutoFetchLogFile.txt
	if [ $FetchFailedRepoCnt -eq 0 ]
	then 
		sed -i "s/Init/Congratulations! We have found a total of $# repositories that have been successfully updated!(The quantity depends on the maximum local repositories quantity limit, in order to prevent too many and time-consuming items)\n在此盘下共检测到 $# 个仓库，$MaxRepoSrh 个仓库均已拉取成功！(该数量取决本地最多仓库数量限制，目的为防止太多，耗时太久）/g" GitAutoFetchLogFile.txt
	else
		sed -i "s/Init/Unexpectedly!  A total of $# repositories were detected under this disk, and $MaxRepoSrh repositories were pulled. Among them, $FetchFailedRepoCnt repositories were not successfully pulled. The specific content is as follows.\n在此盘下共检测到 $# 个仓库，对 $MaxRepoSrh 个仓库进行拉取，其中有 $FetchFailedRepoCnt 个仓库未能成功拉取，具体内容如下./g" GitAutoFetchLogFile.txt
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
