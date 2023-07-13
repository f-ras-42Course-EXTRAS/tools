# **************************************************************************** #
#                                                                              #
#                                                         ::::::::             #
#    prepare_eval.sh                                    :+:    :+:             #
#                                                      +:+                     #
#    By: fras <fras@student.codam.nl>                 +#+                      #
#                                                    +#+                       #
#    Created: 2023/05/05 03:44:02 by fras          #+#    #+#                  #
#    Updated: 2023/07/13 20:52:24 by fras          ########   odam.nl          #
#                                                                              #
# **************************************************************************** #

#!/bin/bash

# Global variables
starting_directory=$(PWD)
project_directory=$1
destination_directory=temp_project_repo

# Check if command-line arguments are valid
if [ $# -ne 1 ];
then
	echo ERROR: Select path to project files.
	echo ------------------------------------------------
	echo Example: 
	echo "$0 ."
	echo or
	echo "$0 ~/path/to/project/"
	echo ------------------------------------------------
	exit 1;
fi
if [ ! -d "$1" ];
	then
	echo "ERROR: Directory '$1' does not exists..";
	echo "\n"
	echo Select correct directory.
	echo ------------------------------------------------
	echo Example: 
	echo "$0 ."
	echo or
	echo "$0 ~/path/to/project/"
	echo ------------------------------------------------
	exit 1;
fi

# <destination_directory> should not exist already
if [ ! -z $(find $1 -name $destination_directory -d 1) ]
then
	echo "ERROR: Found temporary destination directory $destination_directory/"
	echo "Do you want program to delete it? (yes/no)"
	read answer
	if [ "$answer" = "yes" ]
	then
		rm -rf $destination_directory
		echo $destination_directory/ - DIRECTORY DELETED..
		echo "Press ENTER to continue"
		read
		echo "Continuing program..."
	else
		echo Delete directory and try again.
		exit;
	fi
fi

# Get project source
echo Going to project directory
cd $project_directory
source_files=$(find . ! -name '.*' ! -name $0) ##(bug 1) <- find command not working properly.

# Copying files
echo Transfering files to temporary directory
rsync -av $source_files $destination_directory

gitignore_paths=$(find . -name '.gitignore')
if [ ! -z "$gitignore_paths" ];
then
	echo .gitignore found
	echo "Copying file(s) <$gitignore_paths> to <$destination_directory>"
	cp -r $gitignore_paths $destination_directory
fi

echo "Files transfered to $destination_directory -> changing directory"
cd $destination_directory

# Git upload
echo Starting to initialize git
git init
echo Enter the Git remote-url to setup your upload for eval:
read git_remote
git remote add origin $git_remote
echo Repository remote added succesfully..
git add .
git commit -m "project upload"

while [ -z "${git_push_done_check}" ]
do
	git push
	git_push_done_check=$(git push 2>&1 | grep "up-to-date");
	if [ ! -z "${$git_push_done_check}" ];
	then
		echo Files pushed, operation done.;
	else
		echo Upload not succesful. Try checking your remote.
		echo Enter the Git remote-url to setup your upload for eval:
		git remote rm origin
		read git_remote
		git remote add origin $git_remote;
fi

cd ..
echo Going back to project directory
rm -rf $destination_directory
echo Temporary copy deleted

##verififing Git clone (--YET UNTESTED)
echo Testing if upload was succesful:
echo Cloning repository..
git clone $git_remote $destination_directory
echo Checking if files are uploaded as expected..
cd $destination_directory
dest_files=$(find . ! -name '.git') ##(bug 2) <-- fix here as well.
echo Deleting clone..
rm -rf $destination_directory
if [ "$source_files" == "$dest_files"]; ##(3) <-- add .gitignore to sourcefiles
then
	echo Upload succesful! Congrats. Good luck with the eval.;
else
	echo ERROR: Upload unsuccesful.
	echo Expected files in destination:
	echo $source_files
	echo Actual files uploaded in destination:
	echo $dest_files
fi
echo Going back to starting directory.
cd $starting_directory