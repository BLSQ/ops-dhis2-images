#!/bin/bash

echo "
 ____  _     ____   ___            ____  _   _ ___ ____ ____  
| __ )| |   / ___| / _ \          |  _ \| | | |_ _/ ___|___ \ 
|  _ \| |   \___ \| | | |  _____  | | | | |_| || |\___ \ __) |
| |_) | |___ ___) | |_| | |_____| | |_| |  _  || | ___) / __/ 
|____/|_____|____/ \__\_\         |____/|_| |_|___|____/_____|                                                         

Bluesquare DHIS2 Container
Running as $(whoami)
$(date)
--------------------------------
"

if [ -z "$DHIS_GOOGLE_AUTH" ]; then 
     echo "DHIS_GOOGLE_AUTH var is blank or unset not creating google auth.json"; 
else 
     echo $DHIS_GOOGLE_AUTH | base64 --decode > dhis-google-auth.json; 
fi

if [ ! -z "$KUBERNETES_SERVICE_HOST" ]; then
    echo "Running in Kubernetes"
    export DHIS2_HOME="/opt/dhis2"
    java $JAVA_OPTS -Dfile.encoding=UTF-8 -Djava.awt.headless=true -Dlog4j2.formatMsgNoLookups=true -cp $DHIS2_HOME/webapp-runner.jar webapp.runner.launch.Main --expand-war-file true --port 8080 dhis.war -ArelaxedQueryChars='\ { } | [ ]'
else
    echo "Not running in Kubernetes"
    export DHIS2_HOME="$(pwd)" && dockerize -template ./log4j.properties.tmpl:./log4j.properties -template ./dhis.conf.tmpl:./dhis.conf java $JAVA_OPTS -Dfile.encoding=UTF-8 -Dlog4j.configuration=file:$DHIS2_HOME/log4j.properties -Dlog4j.configurationFile=file:$DHIS2_HOME/log4j.properties -Djava.awt.headless=true -Dlog4j2.formatMsgNoLookups=true -cp ./:./webapp-runner.jar webapp.runner.launch.Main --expand-war-file true --port 8080 dhis.war -ArelaxedQueryChars='\ { } | [ ]'
fi