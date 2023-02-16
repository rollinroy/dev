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
    This script executes 'docker exec -it command' on the rstudio container. Syntax:
        rstudio_exec [cmd] [options]
    where cmd can be a command like:
        R
        /bin/bash
        rstudio-server active-sessions

    The input options are:
      1   option -n : container name (default: rstudio-<user>)
      2   option -u : user name (default: LOGNAME environment variable)
      3   option -d : dry run (default: execute the docker command exec)
      4   option -h : help
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
            echo "The container $D_NAME is stopped; cannot execute a command"
            D_CMD=noop
            ;;
        running)
            echo Executing command on running container $D_NAME
            D_CMD=exec
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
        exec)
            DOCKER_CMD="docker $D_CMD -it $D_NAME $D_ECMD"
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
D_CMD=""
D_USER=$LOGNAME
D_NAME=""
# process options
while getopts ":d:u:n:h" opt; do
  case $opt in
    d) D_DRYRUN=y
    ;;
    n) D_NAME="$OPTARG"
    ;;
    u) D_USER="$OPTARG"
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
D_ECMD=$1
if [[ -z $1 ]]; then
    echo No command given
    exit 1;
fi
# container name
if [[ -z $D_NAME ]]; then
    D_NAME="rstudio-$D_USER"
fi

SetCmd
if [[ $D_CMD != "noop" ]]; then
    ExecuteCmd
fi
