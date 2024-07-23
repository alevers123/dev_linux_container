#!/bin/bash

#######################################################################################################
# MIT License (MIT)
# Copyright 2024 alevers123
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
# associated documentation files (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge, publish, distribute,
# sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or
# substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
# NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
# OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#######################################################################################################

create_image() {
   image_name=${1,,}_image
   build_directory=$2
   docker build --progress=plain --build-arg="uid=$uid" --build-arg="gid=$gid" --build-arg="uname=$uname" -t $image_name $build_directory
}

recreate_home() {
   home_dir=${1,,}_home
   rm -R -f ~/$home_dir
   mkdir ~/$home_dir
}

setup_tools() {
   image_name=${1,,}_image
   home_dir=/home/${uname}/${1,,}_home
   scriptdir=$2
   dev_home=/home/$uname
   docker run -v "$home_dir:$dev_home" -v "$scriptdir:/opt/scripts" --rm --entrypoint /bin/sh $image_name /opt/scripts/setup.sh
}

create_container() {
   image_name=${1,,}_image
   dev_home=/home/$uname
   home_dir=/home/${uname}/${1,,}_home
   hostname=${1^^}_CONT
   cont_name=${1,,}_cont
   docker container create -v "$home_dir:$dev_home" -it --hostname=$hostname --name=$cont_name $image_name
}

recreate_image() {
   delete_image $1
   create_image $1 $2
}

delete_image() {
   image_name=${1,,}_image
   docker rm $(docker ps -a -q --filter "ancestor=$image_name")
   docker image rm $image_name
}

container_start() {
   cont_name=${1,,}_cont
   docker container start -i $cont_name
}

usage () {
   echo '
USAGE

-r | --recreate-home: Recreates home folder. Note all settings there will be lost.
-i | --create-image: Creates a new docker image for a dev container
-t | --tools-setup: Sets up the tools for the dev container
-n | --recreate-image: Recreates an docker image 
-c | --create-container: Creates a container for the image
-s | --start-container: Starts up a container
-d | --delete: Delete the docker image and attached containers
-D | --docker-file directory: Provide the Dockercontainer to be build
-T | --tools-directory directroy: Provide the directory to the tools directory, setup script is named setup sh
-h | --help: Show this help file
'
}

TEMP=$(getopt -o "r,i,t,c,s,n,d,h,D:,T:" --long "create-image,recreate-home,tools-setup,create-container,start-container,recreate_image,delete-image,help,docker-file,tools-directory" -n "$0" -- "$@")

[ $? -eq 0 ] || { 
    echo "Incorrect options provided"
    exit 1
}

opts=0
docker_file=/usr/local/share/dockerfiles/devcontainer
tools_directory=/usr/local/share/dockerfiles/devcontainer/InitScripts
uid=$(id -u)
gid=$(id -g)
uname=$(whoami)

eval set -- $TEMP

while true; do
   case $1 in
      '-r' | '--recreate-home')
	opts=$((opts+1))
	shift
	continue
	;;
	'-i' | '--create-image')
	opts=$((opts+2))
	shift
	continue
	;;	
        '-t' | '--tools-setup')
	opts=$((opts+4))
	shift
	continue
	;;
        '-n' | '--recreate-image')
	opts=$((opts+16))
	shift
	continue
	;;
	'-c' | '--create-container')
	opts=$((opts+8))
	shift
	continue
	;;	
	'-d' | '--delete-image')
	opts=$((opts+32))
	shift
	continue
	;;
	'-s' | '--start-container')
	opts=$((opts+64))
	shift
	continue
	;;
	'-D' | '--docker-file')	
	docker_file=$2
	shift 2
	continue
	;;
	'-T' | '--tools-directory')
	tools_directory=$2
	shift 2
	continue
	;;
	'-h' | '--help') 
	usage
	exit 1
	;;
	'--')
	shift
	break
	;;
esac
done

if [ -z "$1" ]; then
	usage
	exit -1
fi

dev_container_name=$1
shift

if [ -n "$1" ]; then
	usage
	exit -1
fi

for x in {0..6..1}
do
	case $(($opts & 1<<$x)) in
	1)
	echo "Recreating the home directory"
	recreate_home $dev_container_name
	continue
	;;
	2)
	if [ -f "${docker_file}/Dockerfile" ]; then
	   echo "Creating image for the docker file"
	   create_image $dev_container_name $docker_file	
	else
	   echo "Dockerfile in directory does not exist"
	fi
	continue
	;;
	4)
	if [ -d "$tools_directory" ]; then
	   echo "Tools will be setup in home folder"
	   setup_tools $dev_container_name $tools_directory
	else
	   echo "Tools directory does not exists. Please provide a correct directory."
	   exit -1
	fi
	continue
	;;
	8)
	echo "Creating container"
	create_container $dev_container_name
	continue
	;;
	16)
	
	if [ -f "${docker_file}/Dockerfile" ]; then
	   echo "Recreating Image"
	   recreate_image $dev_container_name $docker_file
	else
	   echo "Dockerfile in directory does not exist"
	fi
	continue
	;;
	32)
	   echo "Docker image will be removed"
	   delete_image $dev_container_name
	   continue
	;;
	64)
	   echo "Docker image will be started"
	   container_start $dev_container_name
	   continue
	;;
	esac
done

exit 1
