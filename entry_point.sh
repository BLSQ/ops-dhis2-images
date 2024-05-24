#!/bin/bash
if [ -z "$DHIS_GOOGLE_AUTH" ]; then 
     echo "DHIS_GOOGLE_AUTH var is blank or unset not creating google auth.json"; 
else 
     echo $DHIS_GOOGLE_AUTH | base64 --decode > dhis-google-auth.json; 
fi
export DHIS2_HOME=. && dockerize -template ./log4j.properties.tmpl:./log4j.properties -template ./dhis.conf.tmpl:./dhis.conf java $JAVA_OPTS -Dfile.encoding=UTF-8 -Dlog4j.configuration=file:/root/log4j.properties -Dlog4j.configurationFile=file:/root/log4j.properties -Djava.awt.headless=true -Dlog4j2.formatMsgNoLookups=true -cp ./:./webapp-runner.jar webapp.runner.launch.Main --expand-war-file true --port 8080 dhis.war -ArelaxedQueryChars='\ { } | [ ]'