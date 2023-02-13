#!/bin/bash
#  script for parsing out rows in the rnaseq ngs file (e.g.,for desired genes)

# error handling
f () {
    errcode=$? # save the exit code as the first thing done in the trap function
    echo ">>>Error in parse_ngs_file.bash $errorcode"
    echo "     the command executing at the time of the error was"
    echo "     $BASH_COMMAND"
    echo "     on line ${BASH_LINENO[0]}"
    exit $errcode  # or use some other value or do return instead
}
trap f ERR

# help
function Help() {
cat  << EOF
    This script parses an rnaseq NGS file.  Command syntax:
       parse_ngs_file [options] <filename> where options include:
         1   option -c : column numnber (default: 1)
         2   option -s : search string(s) - comma delimited
         3   option -f : search file
         4   optoin -n : no header/line 1
         4   option -d : dry run (don't execute)
         5   option -h : help
EOF
}

function CreateCommand() {
    CC_KEY=$1
    CC_COLUMN=$2
    CC_INFILE=$3
    if [[ $D_INCHDR == 'y' ]]; then
        AWK_CMD="awk 'NR==1' $CC_INFILE && awk "\'"index("\"$CC_KEY\",'$'$CC_COLUMN")"\'" $CC_INFILE"
    else
        AWK_CMD="awk "\'"index("\"$CC_KEY\",'$'$CC_COLUMN")"\'" $CC_INFILE"
    fi
}

function ReadKeyFile() {
    # read the file into input array
    RKF_INFILE=$1
    if [[ "$D_DRYRUN" == "y" ]]; then
        echo ">>> Reading file $RKF_INFILE"
    fi
    KEY_LIST=""
    while IFS= read -ra line
    do
      if [[ ! -z $line ]]; then
          if [[ ! -z $KEY_LIST ]]; then
              KEY_LIST+=","
          fi
          KEY_LIST+="$line"
      fi
    done < "$RKF_INFILE"

}

function CreateKeyArray() {
    # Creates an array of keys from a list of keys (comma delimited)nk size)
    # for example, with chunk size of 10,:
    #    keylist="key1,....,key12"
    #    keyArray[0]="key1,key2,key3,...,key10"
    #    keyArray[1]="key11,key12"
    PKF_KEYLIST=$1
    # iterate over the list
    IFS=',' read -ra LISTARRAY <<< "$PKF_KEYLIST"
    KEY_ARRAY=()
    KEYS=""
    declare -i PKF_CHUNK=9
    declare -i CTR=0
    for k in "${LISTARRAY[@]}"
    do
       if [ "$CTR" -gt "$PKF_CHUNK" ]; then
           KEY_ARRAY+=($KEYS)
           KEYS=""
           let "CTR=0"
       fi
       if [[ ! -z $KEYS ]]; then
           KEYS+=","
       fi
       KEYS+=$k
       let "CTR+=1"
    done
    KEY_ARRAY+=($KEYS)

}

# input arguments and options
D_COL="1"
D_SFILE=""
D_SSTRING=""
D_DRYRUN=""
D_INCHDR="y"
# process options
while getopts ":c:s:f:hdn" opt; do
  case $opt in
    c) D_COL="$OPTARG"
    ;;
    f) D_SFILE="$OPTARG"
    ;;
    s) D_SSTRING="$OPTARG"
    ;;
    d) D_DRYRUN="y"
    ;;
    n) D_INCHDR="n"
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
# get the ngs file
NGS_FILE=""
shift $((OPTIND -1))
if [[ ! -z $1 ]]; then
    NGS_FILE=$1
else
    echo NGS file not specified
    exit 1;
fi

# check if comma delimited search string or search file is given
if [[ -z $D_SSTRING ]]; then
    # chedk file
    if [[ -z $D_SFILE ]]; then
        echo "Either a search string (-s) or file (-f) must be specified"
        exit 1;
    else
        if [[ ! -f $D_SFILE ]]; then
            echo "Search file $D_SFILE doesn't exist"
            exit 1;
        fi
    fi
fi

# check if input ngs file exist
if [[ ! -f $NGS_FILE ]]; then
    echo "NGS input file $NGS_FILE doesn't exist"
    exit 1;
fi

# build the cmd loop
if [[ ! -z $D_SSTRING ]]; then
    CreateCommand $D_SSTRING $D_COL $NGS_FILE
    if [[ "$D_DRYRUN" != "y" ]]; then
        eval "$AWK_CMD"
    else
        echo "$AWK_CMD"
    fi
else
    # read the key file
    ReadKeyFile $D_SFILE
    if [[ "$D_DRYRUN" == "y" ]]; then
        echo ">>> keylist is $KEY_LIST"
    fi
    # create the key array
    CreateKeyArray $KEY_LIST
    for k in "${KEY_ARRAY[@]}"
    do
        if [[ "$D_DRYRUN" == "y" ]]; then
            echo ">>> key is $k"
        fi
        CreateCommand $k $D_COL $NGS_FILE
        if [[ "$D_DRYRUN" != "y" ]]; then
            eval "$AWK_CMD"
        else
            echo "$AWK_CMD"
        fi
    done
fi
