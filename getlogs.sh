#!/bin/bash

# When running this script, make sure that the relevant workspaces for which logs are required are up and running 

DATETIME=`date '+%Y%m%d%H%M%S'`

LOGSDIR=dtslogs_$DATETIME
if [ -d "$LOGSDIR" ]; then
    printf '%s\n' "Removing Lock ($LOGSDIR)"
    rm -rf "$LOGSDIR"
fi
mkdir $LOGSDIR
# get all running docker container ids
containers=$(docker ps | awk '{if(NR>1) print $1}')
echo "Collecting logs from:"
# loop through all containers
for container in $containers
do
  image=$(docker inspect --format='{{.Config.Image}}' $container)
  name=$(docker ps --filter "id=$container" | awk '{if(NR>1) print $NF}')
  if [[ $image = "eclipse-che/"* || $image = "eclipse/che-server"* || $image = *"design-server/dts-server"* ]]; then
    mkdir ${LOGSDIR}/$name
    if [[ $image = *"_dev-machine" ]]; then
      docker cp ${container}:/root/che/ws-agent/logs ${LOGSDIR}/$name
      mkdir ${LOGSDIR}/${name}/IntegrationServer
      mkdir ${LOGSDIR}/${name}/IntegrationServer/instances
      mkdir ${LOGSDIR}/${name}/IntegrationServer/instances/default
      docker cp ${container}:/opt/softwareag/IntegrationServer/instances/logs ${LOGSDIR}/${name}/IntegrationServer/instances
      docker cp ${container}:/opt/softwareag/IntegrationServer/instances/default/logs ${LOGSDIR}/${name}/IntegrationServer/instances/default
      echo "Docker Container" ${container}":/opt/softwareag/IntegrationServer/instances/logs"
      echo "Docker Container" ${container}":/opt/softwareag/IntegrationServer/instances/default/logs"
    elif [[ $image = *"_db" ]]; then
      docker cp ${container}:/var/log/mysql.log ${LOGSDIR}/${name}
      docker cp ${container}:/var/log/mysql.err ${LOGSDIR}/${name}
      docker cp ${container}:/var/log/mysql ${LOGSDIR}/${name}
      echo "Docker Container "${container}":/var/log"
      echo "Docker Container "${container}":/var/log/mysql"
    elif [[ $name = "che" ]]; then
      docker cp ${container}:/logs ${LOGSDIR}/${name}
      echo "Docker Container "${container}":/logs"
      if [ -e ${HOME}/.che/softwareag/data/cli.log ]; then
        cp ${HOME}/.che/softwareag/data/cli.log ${LOGSDIR}/${name}
        echo "File "${HOME}"/.che/softwareag/data/cli.log"
      fi
      if [ -e ${HOME}/che_data/cli.log ]; then
        cp ${HOME}/che_data/cli.log ${LOGSDIR}/${name}
        echo "File "${HOME}"/che_data/cli.log"
      fi
    fi
  fi
done

command -v zip >/dev/null && {
  #Zip and remove the log directory
  zip -q -r ${LOGSDIR}.zip ${LOGSDIR}
  rm -R ${LOGSDIR}
  echo "DTS logs saved in "${LOGSDIR}".zip
} || {
  echo "zip utility not found"
  echo "DTS logs saved in folder" ${LOGSDIR}
}
