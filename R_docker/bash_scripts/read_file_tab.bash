#!/bin/bash
#  script for parsing out rows in the rnaseq ngs file (e.g.,for desired genes)

# error handling
f () {
    errcode=$? # save the exit code as the first thing done in the trap function
    echo ">>>Error in read_file_tab.bash $errorcode"
    echo "     the command executing at the time of the error was"
    echo "     $BASH_COMMAND"
    echo "     on line ${BASH_LINENO[0]}"
    exit $errcode  # or use some other value or do return instead
}
trap f ERR

# help
function Help() {
cat  << EOF
    This script reads a one column text file into a comma-separated list.
    Command syntax:
       read_file_onecolumn <filename> where options include:
         1   option -c : column to compare (default 1)
         2   option -k : key to compare-comma delimited (default key)
         3   option -h : help
EOF
}

# input arguments and options
D_COL=0
D_KEY=key
# process options
while getopts ":k:ch" opt; do
  case $opt in
    c) D_COL="$OPTARG"
    ;;
    k) D_KEY="$OPTARG"
    ;;
    h) Help
    exit
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    exit 1
    ;;
    :) echo "Invalid option: $OPTARG requires an argument" 1>&2
    exit 1
    ;;
  esac

done
# get the input  file
IN_FILE=""
shift $((OPTIND -1))
if [[ ! -z $1 ]]; then
    IN_FILE=$1
else
    echo Input file not specified
    exit 1;
fi
# check if input ngs file exist
if [[ ! -f $IN_FILE ]]; then
    echo "Input file $IN_FILE doesn't exist"
    exit 1;
fi
# convert the key into array
IFS="," read -ra KEY_ARRAY <<< "$D_KEY"
# read the file line by line
echo Reading file $IN_FILE
input=$IN_FILE
while IFS= read -r -a line
do
  #echo info line is $line
  IFS=$'\t' read -ra lineArray <<< "$line"
  for k in "${KEY_ARRAY[@]}"
  do
      if [[ ${lineArray[D_COL]} == $k ]]; then
          echo $line
          break
      fi
  done

done < "$input"
