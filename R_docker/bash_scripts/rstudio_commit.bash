#!/bin/bash
#  script accessing the rstudio docker image.  See help below.

# error handling
f () {
    errcode=$? # save the exit code as the first thing done in the trap function
    echo ">>>Error in personal_bioinformatics.bash $errorcode"
    echo "     the command executing at the time of the error was"
    echo "     $BASH_COMMAND"
    echo "     on line ${BASH_LINENO[0]}"
    exit $errcode  # or use some other value or do return instead
}
trap f ERR

# help
function Help() {
cat  << EOF
    This script executes 'docker commit' on the rstudio container. Syntax:
        rstudio_commit [options]

    The input options are:
      1   option -n : container name (default: rstudio-<user>)
      2   option -u : user name (default: LOGNAME environment variable)
      3   option -d : dry run (default: execute the docker command exec)
      4   option -r : docker repository (default: none)
      5   option -i : name of docker image (default: rstudio-4.2.2)
      6   option -t : docker image tag(default: latest)
      7   option -h : help
EOF
}
# get the state of the docker image/container (container is running; container stopped; image exists)
function DockerState() {
    # check if container is running (can't attach)
    docker ps | grep $D_NAME > /dev/null
    if [[ $? > 0 ]]; then
        # check if container exists and not runniung
        docker ps -a | grep -q $D_NAME
        if [[ $? -eq 0 ]]; then
            D_STATE="stopped"
        else
            D_STATE="nocontainer"
        fi
    else
        # container is running
        D_STATE="running"
    fi
}
# set default cmd based on docker state
function SetCmd() {
    # get the docker state
    D_STATE="undefined"
    DockerState
    case $D_STATE in
        stopped)
            echo "The container $D_NAME is stopped"
            D_CMD=commit
            ;;
        running)
            echo "The container $D_NAME is running"
            D_CMD=commit
            ;;
        nocontainer)
            echo "The container $D_NAME is not running; cannot execute a command"
            D_CMD=noop
            ;;
        *)
            echo Invalid docker state: $D_STATE
            D_CMD=noop
            ;;
    esac
}
# execute the docker command
function ExecuteCmd() {
    # run the cmd; handle cmd "reset"
    case $D_CMD in
        commit)
            DOCKER_CMD="docker commit $D_NAME $D_IMAGE:$D_TAG"
            echo $DOCKER_CMD
            if [[ "$D_DRYRUN" != "y" ]]; then
               trap '' ERR
               eval "$DOCKER_CMD"
            fi
            ;;
        *)
            echo "Invalid command $D_CMD" >&2
            exit 1
    esac
}
# input arguments and options
D_CMD="commit"
D_USER=$LOGNAME
D_NAME=""
D_IMAGE="rstudio-4.2.2"
D_TAG=latest
D_REPOSITORY=""
# process options
while getopts ":u:n:r:i:t:hd" opt; do
  case $opt in
    d) D_DRYRUN=y
    ;;
    n) D_NAME="$OPTARG"
    ;;
    u) D_USER="$OPTARG"
    ;;
    r) D_REPOSITORY="$OPTARG"
    ;;
    i) D_IMAGE="$OPTARG"
    ;;
    t) D_TAG="$OPTARG"
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
# get the command to exec
shift $((OPTIND -1))
if [[ ! -z $1 ]]; then
    echo Unsupported arguments given: $1
    exit 1;
fi
# container name
if [[ -z $D_NAME ]]; then
    D_NAME="rstudio-$D_USER"
fi
# docker image
if [[ -z $D_IMAGE ]]; then
    D_IMAGE=$(D_REPOSITORY)rstudio-4.2.2
fi
# container name
if [[ -z $D_NAME ]]; then
    D_NAME="rstudio-$D_USER"
fi


SetCmd
if [[ $D_CMD != "noop" ]]; then
    ExecuteCmd
fi
