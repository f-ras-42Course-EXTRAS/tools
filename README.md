# tools

## prepare_eval.sh
Shell script for uploading project to 42 Git repository with a clean state - not taking any already existing .git files (or any other hidden files) except for .gitignore.

.gitignore exeptions:
It copies the '.gitignore' file over to the temporary directory for .gitignore rules to maintain, but doesn't upload it to the Git remote.