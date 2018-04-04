# Design Time Server Utilities

This repository contains various utilities to assist with managing and diagnosing your Design Time Server environment.

## Log Extraction Utility - getlogs.sh

This shell script will harvest all of the log files mentioned below from the Design Time Server docker containers as well as the cli.log from the $HOME/.che/softwareag/data directory into a .zip file.  The zip file will contain a folder for each workspace machine and a folder for the Che primary server.  To run it, Che and the workspaces must be up and running.

```
./getlogs.sh
```

The output from this command will be a zip file in the format dtslogs_YYMMDDhhmmss.zip

where

* YY = year
* MM = month
* DD = dat
* hh = hours
* mm = minutes
* ss = seconds

### DTS Data Logs

Within $HOME/.che/softwareag/data/instance/logs, there are Che Server logs (current and archives) and Keycloak logs.  The Che Server logs provide information about the Workspace Master detailing workspace access. $HOME/.che/softwareag/data contains cli.log which has information about Che bootstrapping, starting and stopping the various docker containers, etc.

### DTS Container Logs

When Che is running, the docker containers contain log files.  There will be a container for the Che primary server as well as a separate container for each workspace machine.  The Che primary server logs are identical to those in the DTS Data Logs above except that there is no cli.log.  In addition, there will be docker containers for each workspace machine.  The container logs are described below:

#### Che Primary Server

The docker container for the Che primary server has logs within the top level folder /logs.  These consist of server current and archives as well as Keycloak logs.  The docker image name for the Che primary server container will look like: eclipse/che-server:6.3.0.

#### Che Dev Machine

There can be one or more Che Dev Machine containers (one for each Integration Server Workspace).  Workspace Agent logs reside within the folder: /root/che/ws-agent/logs.  This folder contains archive as well as current logs from the Tomcat server (catalina.log) and host access.  Integration Server logs can be found within the folders: /opt/softwareag/IntegrationServer/instances/logs and /opt/softwareag/IntegrationServer/instances/default/logs.  The docker image name for the Che Dev Machine containers will look like: eclipse-che/{WORKSPACE_ID}_null_che_dev-machine.

#### Che DB

There can be one or more Che DB containers (one for each Integration Server Workspace which contains an external database).  MySql logs can be found within the /var/log as mysql.log and mysql.err.  There is also a mysql folder within /var/log.  The docker image name for the Che DB containers will look like: eclipse-che/{WORKSPACE_ID}_null_che_db.
