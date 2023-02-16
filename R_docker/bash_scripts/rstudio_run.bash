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
    This script runs in the background the rstudio docker image. Syntax:
        rstudio_run [options]

    The input options are:
      1   option -v : additional volume(s) to map; semicolon delimited (/Volumes/WorkSSD is always mapped to /WorkSSD)
      2   option -i : name of docker image (default: rstudio-4.2.2)
      3   option -w : work directory to start in (default: /home/royboy)
      4   option -H : host directory to map to containers home directory (default:/Volumes/WorkSSD/R_Work)
      6   option -p : exposed port(s)for rstudio mapped to 8686 within container (default: 8788)
      7   option -d : dry run and don't execute command (default: execute command)
      8   option -n : container name (default: rstudio-<user>)
      9   option -t : docker image tag (default: latest))
      10  option -r : docker repository (default: none)
      11  option -u : user name (default: LOGNAME environment variable)
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
            # container doesn't exist; check if image exist
            docker images| grep -q $D_IMAGE
            if [[ $? -eq 0 ]]; then
                D_STATE="nocontainer"
            else
                D_STATE="noimage"
            fi
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
            echo Starting the stopped container $D_NAME
            D_CMD=start
            ;;
        running)
            echo The container $D_NAME is already running
            D_CMD=noop
            ;;
        nocontainer)
            echo "The container $D_NAME is not running; running the docker image $D_IMAGE"
            D_CMD=run
            ;;
        noimage)
            echo Docker image $D_IMAGE does not exist
            exit 1
            ;;
        *)
            echo Invalid docker state: $D_STATE
            exit 1
            ;;
    esac
}
# execute the docker command
function ExecuteCmd() {
    # run the cmd; handle cmd "reset"
    case $D_CMD in
        run)
            # docker work option
            if [[ -z $D_WORK ]]; then
                D_WORK="/home/$D_USER"
            fi
            # map host home to container's home
            D_HOMEMAP="-v $D_HOSTHOME:/home/$D_USER"
            # standard work folders to map
            S_VOLS="/Volumes/WorkSSD:/WorkSSD"
            S_VOLSMAP="-v $S_VOLS"
            # option vols (-v option)
            D_VOLSMAP=""
            if [[ ! -z $D_VOLS ]]; then
                IFS=":" read -ra volarray <<< "$D_VOLS"
                for vol in "${volarray[@]}";
                do
                    D_VOLSMAP+="-v $vol:$vol "
                done
            #    echo vols map = $D_VOLSMAP
            fi
            # rstudio port
            D_POPT="-p $D_PORT:8787"
            DOCKER_CMD="docker $D_CMD -t -d $S_VOLSMAP $D_VOLSMAP $D_HOMEMAP $D_POPT -w $D_WORK --name $D_NAME --hostname $D_HOSTNAME -e USER=$D_USER -e SHELL=bash $D_IMAGE"
            echo $DOCKER_CMD
            if [[ "$D_DRYRUN" != "y" ]]; then
               trap '' ERR
               eval "$DOCKER_CMD"
            fi
            ;;
        start)
            DOCKER_CMD="docker start $D_NAME"
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
D_PORT="8788"
D_DRYRUN=n
D_VOLS=""
D_IMAGE="rstudio-4.2.2"
D_WORK=""
D_HOSTHOME="/Volumes/WorkSSD/R_Work"
D_NAME=""
D_TAG=latest
D_REPOSITORY=""
D_HOSTNAME=""
D_EXEC="/bin/bash"
# process options
while getopts ":v:i:w:n:t:r:e:u:p:H:hd" opt; do
  case $opt in
    v) D_VOLS="$OPTARG"
    ;;
    i) D_IMAGE="$OPTARG"
    ;;
    w) D_WORK="$OPTARG"
    ;;
    H) D_HOSTHOME="$OPTARG"
    ;;
    d) D_DRYRUN=y
    ;;
    n) D_NAME="$OPTARG"
    ;;
    t) D_TAG="$OPTARG"
    ;;
    r) D_REPOSITORY="$OPTARG"
    ;;
    u) D_USER="$OPTARG"
    ;;
    e) D_EXEC="$OPTARG"
    ;;
    p) D_PORT="$OPTARG"
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

#  case $OPTARG in
#    -*) echo "Option $opt needs a valid argument"
#    exit 1
#    ;;
#  esac
done
# make sure there's nothing else
shift $((OPTIND -1))
if [[ ! -z $1 ]]; then
    echo Unsupported arguments given: $1
    exit 1;
fi
# set the host name hardcoded for docker-<user>
D_HOSTNAME=docker-$D_USER

# docker image
if [[ -z $D_IMAGE ]]; then
    D_IMAGE=$(D_REPOSITORY)rstudio-4.2.2
fi
# container name
if [[ -z $D_NAME ]]; then
    D_NAME="rstudio-$D_USER"
fi

SetCmd
if [[ $D_CMD == "noop" ]]; then
    echo ">>> rstudio is already running"
else
    ExecuteCmd
fi
