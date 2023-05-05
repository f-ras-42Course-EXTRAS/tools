# **************************************************************************** #
#                                                                              #
#                                                         ::::::::             #
#    prepare_eval.sh                                    :+:    :+:             #
#                                                      +:+                     #
#    By: fras <fras@student.codam.nl>                 +#+                      #
#                                                    +#+                       #
#    Created: 2023/05/05 03:44:02 by fras          #+#    #+#                  #
#    Updated: 2023/05/05 05:36:06 by fras          ########   odam.nl          #
#                                                                              #
# **************************************************************************** #

#!/bin/bash

source_directory=${*%${!#}}
destination_directory=${@:$#}
# | ${*%${!#}} = all arg except last | ${@:$#} = only last arg

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

cp -r $source_directory $destination_directory \
	&& find ${@:$#} -name '.*' | xargs rm -rf

echo "Copying files <${*%${!#}}> to.. <{@:$#}>"
