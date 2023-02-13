#!/bin/bash
#
# df_folders
# Find the differences for files with a specific extension in a source folder
# (or root folder of a directory tree) for the same file names in different folder
# Arguments:
#   arg1: source folder
#   arg2: compare folder
#   arg3: source file extension (def: *.m)
#
#   optional arg2: base R (R-3, R-4, etc)
f () {
    errcode=$? # save the exit code as the first thing done in the trap function
    echo "error $errorcode"
    echo "the command executing at the time of the error was"
    echo "$BASH_COMMAND"
    echo "on line ${BASH_LINENO[0]}"
    # do some error handling, cleanup, logging, notification
    # $BASH_COMMAND contains the command that was being executed at the time of the trap
    # ${BASH_LINENO[0]} contains the line number in the script of that command
    # exit the script or return to try again, etc.
    exit $errcode  # or use some other value or do return instead
}
trap f ERR

find_src() {
#    echo find_src: "$@"
    MFILE=missing_files.txt
    AFILE=mulitple_files.txt
    FFile=found_files.txt
    [[ -f $MFILE ]] && rm $MFILE
    [[ -f $AFILE ]] && rm $MFILE
    [[ -f $FFile ]] && rm $MFILE
    for f in "$@"
    do
        sfn=`echo $f | awk -F "/" '{print $NF}'`
        echo function: $sfn
        cfn=`find $CFOLDER -name "$sfn"`
        if [[ ! -z $cfn ]]; then
            # find returns multiple lines
            counter=0
            while IFS= read -r line
            do
               if [[ $counter -eq 0 ]]; then
                   tfile=tmp.diff
                   echo compare $f and $line
                   diff -w $f $line > $tfile
                   if [[ -s $tfile ]]; then
                       dfile=$sfn.diff
                       echo -e "< $f \n> $line" | cat - $tfile > $dfile
                   fi
                   rm $tfile
               else
                  echo "skipping multiple source files in compare: $line"
               fi
               counter=$((counter+1))
            done <<< "$cfn"
        else
            echo "$sfn not found in compare folder" >> $MFILE
        fi
    done
    exit 0
}

cmp_file () {
    # to accommodate a source file existing in multple places in the
    # compare tree, we need to identify the directory level up one
    # (in most cases).  but in matlab, even going up one level is
    # not sufficient for objects that have "private" folder in the
    # as a paraent folder; so we must go up two levels
    IFILE=$1

    FNAME=`echo $IFILE | awk -F "/" '{print $NF}'`
    LDIR1=`echo $IFILE | awk -F "/" '{print $(NF-1)}'`
    LDIR2=`echo $IFILE | awk -F "/" '{print $(NF-2)}'`
#    echo ">>> LDIR1: $LDIR1"
#    echo ">>> LDIR2: $LDIR2"
    if [[ $LDIR1 = "private" ]]; then
        CDIR=`find $CMP_FOLDER -type d -iname $LDIR2`
        CFILE="$CDIR"/"$LDIR1"/"$FNAME"
    else
        CDIR=`find $CMP_FOLDER -type d -iname $LDIR1`
        CFILE="$CDIR"/"$FNAME"
    fi

    # first see if the file is in the same parent folder
    if [[ -f $CFILE ]]; then
        echo "Diff $IFILE and $CFILE" >> $FFILE
        diff -w $IFILE $CFILE > $TFILE
    else
        # check if the src file is someplace else (there may be mutipile places)
        echo Compare $CFILE does not exist but will check other places
        CFIND=`find $CMP_FOLDER -name $FNAME`
        NOFINDS=`echo $CFIND | awk '{print NF}'`
        if [[ $NOFINDS = 0 ]]; then
            echo "$IFILE not found in $CMP_FOLDER" >> $MFILE
        elif [[ $NOFINDS = 1 ]]; then
            CFILE=$CFIND
            diff -w $IFILE $CFILE > $TFILE
        else
            echo "$IFILE multiple: $CFIND" >> $AFILE
        fi
    fi
    # rename diff file and add header
    if [[ -s $TFILE ]]; then
        DFILE=$FNAME.diff
        if [[ -f $DFILE ]]; then
            NF=`ls "$FNAME"*`
            FN=`echo $NF | awk '{print NF}'`
            DFILE=${FNAME}_${FN}.diff
        fi
        echo -e "< $IFILE \n> $CFILE" | cat - $TFILE > $DFILE
    fi
    if [[ -f $TFILE ]]; then
        rm $TFILE
    fi
}

SRC_FOLDER=$1
CMP_FOLDER=$2
FILE_EXT=${3:-*.m}

if [[ $# -lt 2 ]]; then
    echo 2 arguments are required - source folder and compare folders
    exit 1
fi

# check src/cmp folders
if [[ ! -d $SRC_FOLDER ]]; then
    echo $SRC_FOLDER does not exist
    exit 1
fi

if [[ ! -d $CMP_FOLDER ]]; then
    echo $CMP_FOLDER does not exist
    exit 1
fi

SFG=$SRC_FOLDER/$FILE_EXT
echo Comparing each file $FILE_EXT found in $SRC_FOLDER to the same file in $CMP_FOLDER ...

# find the files
#export CFOLDER=$CMP_FOLDER
#export -f find_src
#find $SRC_FOLDER -name "$FILE_EXT" -exec bash -c 'find_src "$@"' bash {} +
# find can return multi-lines so we handle that case special with IFS/read
# initialize the output files - missing, multiple, found
MFILE=missing_files.txt
AFILE=multiple_files.txt
FFILE=found_files.txt
TFILE=tmp.diff
[[ -f $MFILE ]] && rm $MFILE
[[ -f $AFILE ]] && rm $AFILE
[[ -f $FFILE ]] && rm $FFILE
[[ -f $TFILE ]] && rm $TFILE

while IFS= read -r file
do
    echo "Processing file: $file"
    cmp_file "$file"
    counter=$((counter+1))
done < <(find $SRC_FOLDER -name "$FILE_EXT")

exit 0
