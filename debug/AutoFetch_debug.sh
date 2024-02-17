#!/bin/bash
# $1 = index parent path.
# $2 = log file path.
# $3 = operate.(fetch/push)
# $4 = max operated repos

#####define start#####
IndexParentPath="$1"
LogFilePath="$2"
GitOperate="$3"
MaxRepoSrh="$4"
CurRepoCnt=1
FetchFailedRepoCnt=0
Current_time=`date +"%Y-%m-%d %H:%M:%S"`


#check input parameters valid 
function f_check_var(){	
	#check IndexParentPath
	if [ -d "$IndexParentPath" ]; then
	 	:
		# echo "$IndexParentPath is a valid directory path."
	elif [ -f "$IndexParentPath" ]; then
	 	:
		# echo "$IndexParentPath is a valid file path."
	else
		echo "$IndexParentPath is not a valid path."
		exit 1
	fi


	#check LogFilePath
	if [ -d "$LogFilePath" ]; then
	 	:
		# echo "$LogFilePath is a valid directory path."
	elif [ -f "$LogFilePath" ]; then
	 	:
		# echo "$LogFilePath is a valid file path."
	else
		echo "$LogFilePath is not a valid path."
		exit 1
	fi
	cd "$LogFilePath" && echo "Init">AutoGitTaskLog.txt


	#check GitOperate
	if [ -z "$GitOperate" ]; then
		GitOperate=Fetch
		echo "No Target Operate, use default value $GitOperate"
	elif [ "Fetch" != "$GitOperate" ] && [ "Pull" != "$GitOperate" ]; then
		echo "ERROR CMD, used Fetch/Pull"
		exit 1
	else
		:
	fi

	#check MaxRepoSrh
	if [ -z "$MaxRepoSrh"]; then
		MaxRepoSrh=10
		echo "No Max RepoSrh, use default value $MaxRepoSrh"
	fi
}


#add log info
function f_log(){
	local log_path=$LogFilePath
	local index=$1
	local repos=$2
	if [ "$#" -ne 0 ]; then
		cd "$log_path" && echo "$index $repos">>AutoGitTaskLog.txt
	fi
}


#main function
function f_operate(){
#check if the `find` Non
	if [ "$?" -ne 0 ]; then
	 	echo "No Target Repostory"
		exit 1
	fi
#stage parent path
	ParentPath=`pwd`
#cd parent path for create a log file which will appending issues by the recursive fetch
	cd "$ParentPath"
#split line
	echo "----- start -----"
#total display
	echo "The number of total git repository is $#"
	for ProcessingRepo in $*
	do
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
#check if the repo has add remote, if not then continue
		cd "$ProcessingRepo"
		echo "Git repository path is `pwd`"
		remote_url=`git remote -v`
		if [ -z "$remote_url" ]; then
			echo "The current repository is not linked to a remote repository."
			let "FetchFailedRepoCnt++"
			f_log "$FetchFailedRepoCnt" "`pwd`"
			continue
		else
		  	:
			# echo "The current repository is linked to a remote repository with URL: $remote_url"
		fi
#enter and operate
		if [ "Fetch" == "$GitOperate" ]
		then
			git fetch --all
		elif [ "Pull" == "$GitOperate" ]
		then
			git pull
		else
		 	:
		fi
#check whether the cmd completed
		if [ "$?" -eq 0 ]
		then
			echo "Update completed!"
		else
			let "FetchFailedRepoCnt++"
#log the path that fetch failed in the log file named GitAutoFetchLogFile
			f_log "$FetchFailedRepoCnt" "`pwd`"
		fi
	done
#go to the LogFilePath to substitute the first line "Init" by the result of script
	cd "$LogFilePath"
	echo "Run time is :$Current_time">>AutoGitTaskLog.txt
	if [ $FetchFailedRepoCnt -eq 0 ]
	then 
		sed -i "s/Init/Congratulations! We have found a total of $# repositories that have been successfully operated!\n在此盘下共检测到 $# 个仓库，均已操作成功！/g" AutoGitTaskLog.txt
	else
		sed -i "s/Init/Unexpectedly!  A total of $# repositories were detected under this disk, Among them, $FetchFailedRepoCnt repositories were not successfully operated. The specific content is as follows.\n在此盘下共检测到 $# 个仓库，其中有 $FetchFailedRepoCnt 个仓库未能成功操作，具体内容如下。/g" AutoGitTaskLog.txt
#reset the cnt, or the next invoke will cnt continue
		FetchFailedRepoCnt=0
	fi
}

#####define end#####


#####RUN#####
f_check_var
echo "Enter $IndexParentPath"
cd "$IndexParentPath"
f_operate `find $IndexParentPath * -mount -maxdepth 2 -not -path "C:\\*" -a -name .git|xargs dirname`
