# tools

## prepare_eval.sh
Shell script for uploading project to 42 Git repository with a clean state - not taking any already existing .git files (or any other hidden files) except for .gitignore.

.gitignore exptions:
It copies the '.gitignore' file over to the temporary directory, but leaves it out for upload.