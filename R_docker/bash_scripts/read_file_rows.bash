#!/bin/bash
#  script for parsing out rows in the rnaseq ngs file (e.g.,for desired genes)

# error handling
f () {
    errcode=$? # save the exit code as the first thing done in the trap function
    echo ">>>Error in read_file_rows.bash $errorcode"
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
         1   option -h : help
EOF
}

# input arguments and options
# process options
while getopts "h" opt; do
  case $opt in
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
if [[ $# -gt 1 ]]; then
    echo "Too many arguments $@"
    exit 1
fi
shift "$((OPTIND -1))"
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

# read the file into input array
echo Reading file $IN_FILE
RESULTS=""
input=$IN_FILE
while IFS= read -ra line
do
  echo "$line"
  if [[ ! -z $line ]]; then
      if [[ ! -z $RESULTS ]]; then
          RESULTS+=","
      fi
      RESULTS+="$line"
  fi
done < "$input"

echo $RESULTS
