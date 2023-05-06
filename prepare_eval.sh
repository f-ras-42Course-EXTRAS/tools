# **************************************************************************** #
#                                                                              #
#                                                         ::::::::             #
#    prepare_eval.sh                                    :+:    :+:             #
#                                                      +:+                     #
#    By: fras <fras@student.codam.nl>                 +#+                      #
#                                                    +#+                       #
#    Created: 2023/05/05 03:44:02 by fras          #+#    #+#                  #
#    Updated: 2023/05/06 06:31:04 by fras          ########   odam.nl          #
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
	exclude_gitignore_files_for_upload=" --"
	for i in $gitignore_paths;
	do
		exclude_gitignore_files_for_upload+=" '!:$i'";
	done
fi

echo "Files transfered to $destination_directory -> changing directory"
cd $destination_directory

# Git working
echo Starting to initialize git
git init
echo Enter the Git remote url to setup your upload for eval:
read git_repository
git remote add origin $git_repository
echo Repository remote added succesfully..
##TODO: ^ built verification.
git add . $exclude_gitignore_files_for_upload
git commit -m "project done"
git push
echo Files pushed, operation done.
cd $starting_directory
echo Going back to starting directory.
rm -rf $destination_directory
echo Copied files deleted.

##verififing Git clone (--YET UNTESTED)
echo Testing if was upload succesful
source_files=$(find . ! -name '.*')
echo Cloning repository..
git clone $git_repository test
echo Checking if files are as expected..
cd test
dest_files=$(find . | -name '.git')
cd ..
rm -rf $destination_directory
if [ "$source_files" == "$dest_files"];
then
	echo Upload succesful! Congrats. Good luck with the eval.;
else
	echo ERROR: Upload unsuccesful.
	echo Expected files in destination:
	echo $source_files
	echo Actual files uploaded in destination:
	echo $dest_files
	exit 1;
fi