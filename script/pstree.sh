#!/bin/bash

#
# Display process table in tree form
#

if [[ "$1" = "" ]]
then
	PROC_NUM=1
else
	PROC_NUM=$1
fi

main () {

PSOUT=`ps -ef | grep -v "^UID" | sort -n -k2`
# This technique will work in ksh, but since there are going to be array
# subscripts larger than 1024, bash is the way to go.
#ps -ef | grep -v "^UID" | while read line
while read line
do
	line=`echo "$line" | sed -e s/\>/\\\\\\>/g`
	#echo $line
	# works in ksh/pdksh as long as the subscript is below 1024.. here it is not
	# bash works fine though.
	#set -A process $line for a ksh script
	process=( $line )
	pid=${process[1]}
	owner[$pid]=${process[0]}
	ppid[$pid]=${process[2]}
	command[$pid]="`echo $line | awk '{for(i=8;i<=NF;i++) {printf "%s ",$i}}'`"
	children[${ppid[$pid]}]="${children[${ppid[$pid]}]} $pid"
done <<EOF
$PSOUT
EOF

# something about the arrays is that the values seem to be only good in the
# above loop.  This is a known issue with bash that all the piped elements
# are in subshells and their variables aren't available to the parent shell.
# Take the pipe out of the equation and send it to a file, then redirect
# the file into the end of the while loop.
print_tree $proc ""

}

print_tree () {

id=$1

echo "$2$id" ${owner[$id]} ${command[$id]}

if [ "${children[$id]}" = "" ]
then
	return
else
	for child in ${children[$id]}
	do
		if [ "$child" = "`echo ${children[${ppid[$child]}]} | awk '{print $NF}'`" ]
		then
			echo "$2 \\"
			temp="$2  "
		else
			echo "$2|\\"
			temp="$2|  "
		fi
		print_tree $child "$temp"
	done
fi

}

main