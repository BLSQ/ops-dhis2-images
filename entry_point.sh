#!/bin/bash
if [ -z "$DHIS_GOOGLE_AUTH" ]; then 
     echo "DHIS_GOOGLE_AUTH var is blank or unset not creating google auth.json"; 
else 
     echo $DHIS_GOOGLE_AUTH | base64 --decode > dhis-google-auth.json; 
fi

export DHIS2_HOME="/opt/dhis2"

java $JAVA_OPTS -Dfile.encoding=UTF-8 -Djava.awt.headless=true -Dlog4j2.formatMsgNoLookups=true -cp $DHIS2_HOME/webapp-runner.jar webapp.runner.launch.Main --expand-war-file true --port 8080 dhis.war -ArelaxedQueryChars='\ { } | [ ]'