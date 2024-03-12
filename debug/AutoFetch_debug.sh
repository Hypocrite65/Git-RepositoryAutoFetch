#!/bin/bash
# $1 = index parent path.
# $2 = log file path.
# $3 = operate.(Fetch/Push)
# $4 = max operated repos
# $5 = Debug log(0 = no print; 1 = print info in shell)

#####define start#####
IndexParentPath="$1"
LogFilePath="$2"
GitOperate="$3"
MaxRepoSrh="$4"
Debug="$5"
TotalRepoCnt=0
CurRepoCnt=1
OperatePASSRepoCnt=0
OperateFailedRepoCnt=0
Current_time=`date +"%Y-%m-%d %H:%M:%S"`

#check input parameters valid 
function f_check_var(){	
	#check IndexParentPath
	if [ -d "$IndexParentPath" ]; then
	 	:
	else
		echo "Index parent path: $IndexParentPath is not a valid directory path."
		exit 1
	fi


	#check LogFilePath
	if [ -d "$LogFilePath" ]; then
	 	:
	else
		echo "Log file path: $LogFilePath is not a valid directory path."
		exit 1
	fi
	cd "$LogFilePath" && echo "Init">AutoGitTaskLog.txt
	echo "Run time is :$Current_time">>AutoGitTaskLog.txt


	#check GitOperate
	if [ -z "$GitOperate" ]; then
		GitOperate=Fetch
		echo "No Target Operate, use default value $GitOperate"
	elif [ "Fetch" != "$GitOperate" ] && [ "Pull" != "$GitOperate" ]; then
		sed -i "s/Init/ERROR CMD, used Fetch or Pull /g" AutoGitTaskLog.txt
		exit 1
	else
		:
	fi

	#check MaxRepoSrh
	if [ -z "$MaxRepoSrh" ]; then
		MaxRepoSrh=10
		echo "No Max RepoSrh, use default value $MaxRepoSrh"
	fi
}


#add log info
function f_log(){
	#go to the LogFilePath to substitute the first line "Init" by the result of script
	cd "$LogFilePath"
	echo "" >> AutoGitTaskLog.txt
	echo "" >> AutoGitTaskLog.txt
	echo "↓---- Success -----" >> AutoGitTaskLog.txt
	for path in "${Success_repos[@]}"; do
		((OperatePASSRepoCnt+=1))
		echo "|--->$OperatePASSRepoCnt $path" >> AutoGitTaskLog.txt
	done
	echo "↑---- end -----" >> AutoGitTaskLog.txt
	echo "" >> AutoGitTaskLog.txt
	echo "↓---- Failed -----" >> AutoGitTaskLog.txt
	for path in "${Failed_repos[@]}"; do
		((OperateFailedRepoCnt+=1))
		echo "|--->$OperateFailedRepoCnt $path" >> AutoGitTaskLog.txt
	done
	echo "↑---- end -----" >> AutoGitTaskLog.txt

	if [ $OperateFailedRepoCnt -eq 0 ]; then
		sed -i "s/Init/Congratulations! We have found a total of $TotalRepoCnt repositories that have been successfully operated! /g" AutoGitTaskLog.txt
	else
		sed -i "s/Init/Unexpectedly!  A total of $TotalRepoCnt repositories were detected under this disk, Among them, $OperateFailedRepoCnt repositories were not successfully operated. The specific content is as follows. /g" AutoGitTaskLog.txt
	fi
	echo "" >> AutoGitTaskLog.txt
	echo "The index parent path is ($IndexParentPath)" >> AutoGitTaskLog.txt
	echo "The log file path is ($LogFilePath--AutoGitTaskLog.txt)" >> AutoGitTaskLog.txt
	echo "The operate is ($GitOperate)" >> AutoGitTaskLog.txt
	echo "The max operated repos is ($MaxRepoSrh)" >> AutoGitTaskLog.txt
	echo "The Debug log status is ($Debug)" >> AutoGitTaskLog.txt
}


#check if the repos has remote address
function f_check_remote(){
	remote_url=`git remote -v`
	if [ -z "$remote_url" ]; then
		f_debug "The current repository is not linked to a remote repository."
		Failed_repos+=("`pwd`")
		return 1
	else
		:
		return 0
		# echo "The current repository is linked to a remote repository with URL: $remote_url"
	fi
}


#initialize Cnt
function f_init(){
	TotalRepoCnt=0
	CurRepoCnt=1
	OperatePASSRepoCnt=0
	OperateFailedRepoCnt=0
}

#if debug mode = 1, then print the info in bash
function f_debug(){
	if [ 1 -eq "${Debug:-0}" ]; then
		echo -e "$1"
	fi
}

#find the all git repos in the parent path
function f_find(){
	# 使用find命令搜索文件，并通过管道传递给read命令来读取每一行，然后存储到数组中
	while IFS= read -r line; do
		((TotalRepoCnt+=1)) 
		PathArray+=("$line")
	done < <(find "$IndexParentPath" -maxdepth 4 -a -type d -name ".git")
}


#main function
function f_main(){
	f_check_var
	f_init
	f_find
	#total display
	f_debug "The number of total git repository is $TotalRepoCnt"
	#split line
	f_debug "----- start -----"
	for ProcessingRepo in "${PathArray[@]}"
	do
	#the max repo limit
		if test $CurRepoCnt -gt $MaxRepoSrh
		then
			f_debug "Too many repository, the limit times can be changed using variable <MaxRepoSrh>, and now it is $MaxRepoSrh"
			CurRepoCnt=1
			break
		fi
	#display the index of repo
		f_debug "----- $CurRepoCnt/$TotalRepoCnt -----"
		((CurRepoCnt+=1))
	# #check if the repo has add remote, if not then continue
		cd "$ProcessingRepo"
		f_check_remote
		if [ 1 -eq "$?" ]; then
			continue
		fi
	#enter and operate
		if [ "Fetch" == "$GitOperate" ]; then
			# git fetch --all 2>> AutoGitTaskLog.txt
			Error_output=$(git fetch --all 2>&1 > /dev/null)
		elif [ "Pull" == "$GitOperate" ]; then
			Error_output=$(git pull 2>&1 > /dev/null)
		else
		 	git log 1 --oneline
		fi
	#check whether the cmd completed
		if [ "$?" -eq 0 ]; then
			Success_repos+=("`pwd`")
			f_debug "Update completed!"
		else
		 	Failed_repos+=("`pwd`--→$Error_output")
			f_debug "Operate failed."
			f_debug "$Error_output"
			cd "$LogFilePath"
		fi
	done
	f_log
	echo "Finish, time: $Current_time"
}


#####RUN#####
f_main