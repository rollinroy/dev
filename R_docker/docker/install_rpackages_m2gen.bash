#!/bin/bash
# install m2gen packages
#    optional arg1: path of the m2gen R package libraries
#    optional arg2: path of R home
# e.g.,
#   ./install_r_pkgs.bash > /tmp/install_r_pkgs.log 2>&1 &

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
# change DEF_LIB_PATH appropriately
DEF_LIB_PATH=/usr/lib/R/site-library
DEF_R_HOME="/usr/lib/R"
LIB_PATH=${1:-$DEF_LIB_PATH}
R_HOME=${2:-$DEF_R_HOME}

# call a python script to generate a script install m2gen packages
INSTALLSCRIPT="installm2gen.R"
R_SCRIPT=$R_HOME/bin/Rscript
if [ -f $INSTALLSCRIPT ]; then
    rm $INSTALLSCRIPT
fi
python ./install_rpackages_m2gen.py "$LIB_PATH" -i "$INSTALLSCRIPT" -R "$R_SCRIPT"
if [ $? -eq 0 ]; then
    echo "Installing m2gen packages into $LIB_PATH ..."
    # execute the script to install in site
    chmod +x "$INSTALLSCRIPT"
    ./"$INSTALLSCRIPT"
else
    echo "Executing python script to create R install script failed."
fi
