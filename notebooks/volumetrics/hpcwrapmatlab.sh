#!/bin/sh

usage() {
    cat <<EOF

wrap_matlab.sh 

Usage: wrapmatlab.sh <command> 
e.g.   wrapmatlab.sh "myfunction('go', 2, 4);"

	<command>			MATLAB function to execute, inside ""

EOF
    exit 1
}

############################################################################
[ "$#" -lt 1 ] && usage

module load matlab;

wd=`dirname "$(readlink -f "$0")"`;
cmd="matlab -nodesktop -r \"addpath('$wd');$1;exit\"";
eval ${cmd}
