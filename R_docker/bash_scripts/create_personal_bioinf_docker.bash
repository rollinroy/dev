#!/bin/bash
#  script for personal bioinformatics server.  See help below.

# error handling
f () {
    errcode=$? # save the exit code as the first thing done in the trap function
    echo ">>>Error in create_bioinf_docker.bash $errorcode"
    echo "     the command executing at the time of the error was"
    echo "     $BASH_COMMAND"
    echo "     on line ${BASH_LINENO[0]}"
    exit $errcode  # or use some other value or do return instead
}
trap f ERR
# set docker group (linux ony)
function SetDockerGroup() {
    if [[ "$(uname)" == "Linux" ]]; then
        if getent group docker | grep -qw "$D_USER"; then
            echo $D_USER is already in docker group
        else
            sudo usermod -a -G docker $D_USER
            echo $D_USER has been added to the docker group
        fi
    fi
}

# set user port
function SetUserPort() {
    let RSTUDIO_PORT=8680
    UPDATE_CFG="y"
    PORT_FNAME=personal_port.cfg
    PORTCFG_DIR=/usr/local/bin
    PORT_FILE=$PORTCFG_DIR/$PORT_FNAME
    # read the port cfg file
    if [[ -f $PORT_FILE ]]; then
#        sed '/^[ \t]*$/d' $PORT_FILE | while IFS= read -ra line
        while IFS= read -ra line
        do
            if [[ ! -z $line ]]; then
                let "RSTUDIO_PORT++"
                read -ra lineArray <<< "$line"
                if [[ ${lineArray[0]} == $D_USER ]]; then
                    echo User $D_USER already assigned port ${lineArray[1]}
                    UPDATE_CFG="n"
                    break
                fi
            fi
        done < "$PORT_FILE"
    else
        echo "Port config file ($PORT_FILE) not found; RStudio port not assigned"
    fi

    # update cfg
    if [[ $UPDATE_CFG == "y" ]]; then
        echo "Updating $PORT_FILE for $D_USER to use port $RSTUDIO_PORT"
        USER_PORT="$D_USER $RSTUDIO_PORT"
        echo $USER_PORT >> $PORT_FNAME
    fi
}

# help
function Help() {
cat  << EOF
    This script creates a personal bioinformatics docker image.  Options include:
      1   option -f : docker build file (default: personal_bioinf.dfile)
      2   option -u : user (default: <user>)
      3   option -b : name of base docker image (default: m2gen/bioinformatics-4.2.1)
      4   option -d : dry run and don't execute build (default: execute build)
      5   option -n : name of personal docker image (default: m2gen/bioinformatics-4.2.1-<user>)
      6   option -h : help
EOF
}

# input arguments and options
D_CMD=build
D_BUILD_FILE=personal_bioinf.dfile
D_USER=$USER
D_DRYRUN=n
D_BASE_IMAGE=""
D_NEW_IMAGE=""
# process options
while getopts ":f:u:b:n:hd" opt; do
  case $opt in
    f) D_BUILD_FILE="$OPTARG"
    ;;
    b) D_BASE_IMAGE="$OPTARG"
    ;;
    n) D_NEW_IMAGE="$OPTARG"
    ;;
    u) D_USER="$OPTARG"
    ;;
    d) D_DRYRUN=y
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
# make sure there's nothing else
shift $((OPTIND -1))
if [[ ! -z $1 ]]; then
    echo Unsupported arguments given: $1
    exit 1;
fi

# docker base image
if [[ -z $D_BASE_IMAGE ]]; then
    D_BASE_IMAGE=m2gen/bioinformatics-4.2.1
fi
# docker new image
if [[ -z $D_NEW_IMAGE ]]; then
    D_NEW_IMAGE=$D_BASE_IMAGE-$D_USER
fi

# user id
D_USERID=`id -u $D_USER`

# set user port
SetUserPort

# set user to docker group
SetDockerGroup

case $D_CMD in
    build)
        DOCKER_CMD="docker $D_CMD -t $D_NEW_IMAGE --no-cache --progress plain \
                    --build-arg base_name=$D_BASE_IMAGE \
                    --build-arg user=$D_USER \
                    --build-arg user_id=$D_USERID \
                    -f $D_BUILD_FILE . 2>&1 | tee build_personal_$D_USER.log"
        echo $DOCKER_CMD
        # check for build file
        if [[ ! -f $D_BUILD_FILE ]]; then
            echo ">>> Build file $D_BUILD_FILE does not exist" 1>&2
            exit 1
        fi
        # execute if not a dry run
        if [[ "$D_DRYRUN" != "y" ]]; then
           eval "$DOCKER_CMD"
        fi
        ;;
    *)
        echo "Invalid command $D_CMD" >&2
        exit 1
esac
