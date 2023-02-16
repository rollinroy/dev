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
    This script manages access to the rstudio container (which is based on the R and Bioinformatics images).  The different command options (-c option) include run, exec, commit, terminate or restart.

    The input options are:
      1   option -c : docker command - run, exec, commit, terminate or restart. 'run' runs the rstudio container in the background (if the container is stopped, then it starts the container); 'exec' executes a command in the running container (and runs the container in the background if not already running); 'commit' updates changes in the container to the docker image; terminate stops and deletes the container; Restart updates the docker image, stops/deletes the container, and runs a new container in the background and interactively)
      2   option -v : additional volume(s) to map; semicolon delimited (/Users/<user> is always mapped)
      4   option -i : name of docker image (default: r-4.2.2)
      5   option -w : work directory to start in (default: /Users/<user>)
      7   option -d : dry run and don't execute command (default: execute command)
      8   option -n : container name (default: name of docker image)
      9   option -t : docker image tag; mostly for commit (default: latest))
      10  option -r : docker repository (default: none)
      11  option -e : exec command (default: /bin/bash)
EOF
}
# get work directory to user (D_USER)
function GetUserWorkDir() {
    WF_FNAME=personal_workfolders.cfg
    SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
    WF_FILE=$SCRIPT_DIR/$WF_FNAME
    # read the workfolder cfg file
    if [[ -f $WF_FILE ]]; then
        while IFS= read -ra line
        do
          if [[ ! -z $line ]]; then
              read -ra lineArray <<< "$line"
              if [[ ${lineArray[0]} == $D_USER ]]; then
                  D_WORK=${lineArray[1]}/$D_USER
                  echo "Work directory in container is $D_WORK"
                  break
              fi
          fi
        done < "$WF_FILE"
        if [[ -z $D_WORK ]];then
            echo "$D_WORK not found in $WF_FILE; can't set startup work folder"
            exit 1
        fi
    else
        echo "Workfile config file ($WF_FILE) not found; can't set startup work folder"
        exit 1
    fi
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
            echo Attaching to a running container $D_NAME
            D_CMD=attach
            ;;
        nocontainer)
            echo No container and running the docker image $D_IMAGE
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
# execute restart (multiple docker commands)
function ExecuteRestart(){
    # get docker state
    DockerState
    # we only care if the container is running or stopped
    if [[ $D_STATE == "running" || $D_STATE == "stopped" ]]; then
        # commit, terminate and run
        D_CMD="commit"
        echo ">>> Commit container to image ..."
        ExecuteCmd
        echo ">>> Delete container ..."
        D_CMD="terminate"
        ExecuteCmd
        echo ">>> Create a new container and attach ..."
        D_CMD="run"
        ExecuteCmd
    else
        echo "Nothing to restart. Container is not running nor stopped."
    fi
}
# execute the docker command
function ExecuteCmd() {
    # for run command only
    if [[ $D_CMD == "run" ]]; then
        # docker work option
        if [[ -z $D_WORK ]]; then
            GetUserWorkDir
        fi
        # standard work folders to map
        S_VOLS="/work_research:/work_cbio:/work_flow"
        S_VOLSMAP=""
        IFS=":" read -ra volarray <<< "$S_VOLS"
        for vol in "${volarray[@]}";
        do
    #        echo avol = $vol
            S_VOLSMAP+="-v $vol:$vol "
        done
        # process vols (-v option)
        D_VOLSMAP=""
        if [[ ! -z $D_VOLS ]]; then
            IFS=":" read -ra volarray <<< "$D_VOLS"
            for vol in "${volarray[@]}";
            do
        #        echo avol = $vol
                D_VOLSMAP+="-v $vol:$vol "
            done
        #    echo vols map = $D_VOLSMAP
        fi
    fi
    # run the cmd; handle cmd "reset"
    case $D_CMD in
        run)
            DOCKER_CMD="docker $D_CMD -it $S_VOLSMAP -v /home/$D_USER:/home_ro/$D_USER:ro $D_VOLSMAP $D_POPT -w $D_WORK -u $D_USER --name $D_NAME --hostname $D_HOSTNAME -e USER=$D_USER -e SHELL=bash $D_IMAGE /bin/bash --login"
            echo $DOCKER_CMD
            if [[ "$D_DRYRUN" != "y" ]]; then
               trap '' ERR
               eval "$DOCKER_CMD"
            fi
            ;;
        terminate)
            DockerState
            if [[ $D_STATE == "running" ]]; then
                DOCKER_CMD="docker stop $D_NAME && docker rm $D_NAME"
            elif [[ $D_STATE == "stopped" ]]; then
                DOCKER_CMD="docker rm $D_NAME"
            else
                DOCKER_CMD="echo nothing to terminate"
                D_STATE="empty"
            fi
            echo $DOCKER_CMD
            if [[ $D_STATE != "empty" ]]; then
                if [[ "$D_DRYRUN" != "y" ]]; then
                    read -p "Terminate container $D_NAME. Are you sure (maybe commit first) [Yy]? " -n 1 -r
                    echo    # (optional) move to a new line
                    if [[ $REPLY =~ ^[Yy]$ ]]; then
                       eval "$DOCKER_CMD"
                    fi
                fi
            fi
            ;;
        start)
            DOCKER_CMD="docker start -a -i $D_NAME"
            echo $DOCKER_CMD
            if [[ "$D_DRYRUN" != "y" ]]; then
               trap '' ERR
               eval "$DOCKER_CMD"
            fi
            ;;
        attach)
            DOCKER_CMD="docker attach $D_NAME"
            echo $DOCKER_CMD
            if [[ "$D_DRYRUN" != "y" ]]; then
               trap '' ERR
               eval "$DOCKER_CMD"
            fi
            ;;
        commit)
            DOCKER_CMD="docker commit $D_NAME $D_IMAGE:$D_TAG"
            echo $DOCKER_CMD
            if [[ "$D_DRYRUN" != "y" ]]; then
               eval "$DOCKER_CMD"
            fi
            ;;
        running)
            docker ps --filter "name=$D_NAME"
            ;;
        stopped)
            docker ps -a --filter "name=$D_NAME"
            ;;
        images)
            docker images $D_IMAGE
            ;;
        *)
            echo "Invalid command $D_CMD" >&2
            exit 1
    esac
}
# input arguments and options
D_CMD=""
D_USER=$LOGNAME
D_DRYRUN=n
D_ROOT_VOL=/WorkSSD
D_VOLS=""
D_IMAGE=""
D_WORK=""
D_NAME=""
D_TAG=latest
D_REPOSITORY=m2gen
D_HOSTNAME=""
# process options
while getopts ":v:i:w:c:n:t:r:hdx" opt; do
  case $opt in
    v) D_VOLS="$OPTARG"
    ;;
    i) D_IMAGE="$OPTARG"
    ;;
    w) D_WORK="$OPTARG"
    ;;
    c) D_CMD="$OPTARG"
    ;;
    d) D_DRYRUN=y
    ;;
    n) D_NAME="$OPTARG"
    ;;
    t) D_TAG="$OPTARG"
    ;;
    r) D_REPOSITORY="$OPTARG"
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
# get the assigned port number for user
if [[ -z $D_PORT ]]; then
    GetUserPort
fi

# docker image
if [[ -z $D_IMAGE ]]; then
    D_IMAGE=$D_REPOSITORY/bioinformatics-4.2.1-$D_USER
fi
# container name (not including repository)
if [[ -z $D_NAME ]]; then
    IFS="/" read -ra imageparts <<< "$D_IMAGE"
    if [[ ${#imageparts[@]} > 1 ]]; then
        D_NAME=${imageparts[1]}
    else
        D_NAME=$D_IMAGE
    fi
fi

if [[ $D_CMD == "restart" ]]; then
    ExecuteRestart
else
    if [[ -z $D_CMD ]]; then
        SetCmd
    fi
    ExecuteCmd
fi
