# **************************************************************************** #
#                                                                              #
#                                                         ::::::::             #
#    prepare_eval.sh                                    :+:    :+:             #
#                                                      +:+                     #
#    By: fras <fras@student.codam.nl>                 +#+                      #
#                                                    +#+                       #
#    Created: 2023/05/05 03:44:02 by fras          #+#    #+#                  #
#    Updated: 2023/05/06 00:56:34 by fras          ########   odam.nl          #
#                                                                              #
# **************************************************************************** #

#!/bin/bash

# Save starting directory 
starting_directory=$(echo "$PWD")

# Get copy directory from command-line arguments
source_directory=${@:1:$#-1}
destination_directory=${@:$#}

# Check if command-line arguments are valid
if [ $# -lt 2 ];
	then
		echo Choose directory to copy files 'from' and 'to'. 
		echo Like how you would use cp.
		echo ------------------------------------------------
		echo Example: 
		echo "$0 <source_directory(s)> <destination_directory>"
		echo ------------------------------------------------
		echo Leads to: 
		echo "cp <source_directory(s)> <destination_directory>"
		echo ------------------------------------------------
		exit 1;
	fi

# Start script
cp -r $source_directory $destination_directory \
	&& find $destination_directory -name '.*' | xargs rm -rf
cp .gitignore $destination_directory

echo "Copying files <$source_directory> to <$destination_directory>"
cd $destination_directory
echo Changing directory to $destination_directory.

echo Starting to initialize git.
git init
echo Enter the Git remote link to setup upload for eval:
read git_repository
git remote add origin $git_repository
echo Repository remote added succesfully..
git add .
git commit -m "project done"
git push
echo Files pushed, operation done.
cd $starting_directory
echo Going back to starting directory.
rm -rf $starting_directory
echo Copied files deleted.