# **************************************************************************** #
#                                                                              #
#                                                         ::::::::             #
#    prepare_eval.sh                                    :+:    :+:             #
#                                                      +:+                     #
#    By: fras <fras@student.codam.nl>                 +#+                      #
#                                                    +#+                       #
#    Created: 2023/05/05 03:44:02 by fras          #+#    #+#                  #
#    Updated: 2023/05/06 04:54:20 by fras          ########   odam.nl          #
#                                                                              #
# **************************************************************************** #

#!/bin/bash

starting_directory=$(PWD)
destination_directory=temp_project_repo

# Get project source from command-line arguments
source_files=${@}

# Check if command-line arguments are valid
if [ $# -lt 1 ];
then
	echo ERROR: Select project files.
	echo ------------------------------------------------
	echo Example: 
	echo "$0 <source_files>"
	echo ------------------------------------------------
	exit 1;
fi

file_not_found=false
for i in $source_files; 
do
	if [ ! -e "$i" ];
	then
		echo "ERROR: File '$i' does not exists..";
		file_not_found=true;
	fi
done
if [ "$file_not_found" = true ];
then
	echo Found unexisting files. Closing program. 
	echo "\n"
	echo Select correct files.
	echo ------------------------------------------------
	echo Example: 
	echo "$0 <source_project_files>"
	echo ------------------------------------------------
	exit 1;
fi

# <destination_directory> should not exist already
if [ ! -z $(find . -name $destination_directory -d 1) ]
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
		echo "Continueing program..."
	else
		echo Delete directory and try again.
		exit;
	fi
fi

# Copying files
echo Transfering files to temporary directory
rsync -av --exclude=".*" $source_files $destination_directory

gitignore_paths=$(find . -name '.gitignore')
if [ ! -z "$gitignore_paths" ];
then
	echo .gitignore found
	echo "Copying file(s) <$gitignore_paths> to <$destination_directory>"
	cp $gitignore_paths $destination_directory
fi

echo "Files transfered to $destination_directory -> changing directory"
cd $destination_directory

# Git working
echo Starting to initialize git
git init
echo Enter the Git remote url to setup upload for eval:
read git_repository
git remote add origin $git_repository
echo Repository remote added succesfully..
git add .
git commit -m "project done"
git push
echo Files pushed, operation done.
cd $starting_directory
echo Going back to starting directory.
rm -rf $destination_directory
echo Copied files deleted.