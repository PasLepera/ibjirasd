#!/bin/bash
set -xeo pipefail

if [ -n "${CATALINA_CONNECTOR_PROXYNAME}" ]; then
  xmlstarlet ed -P -S -L --insert "//Connector[not(@proxyName)]" --type attr -n proxyName --value "${CATALINA_CONNECTOR_PROXYNAME}" ${JIRA_INSTALL}/conf/server.xml
fi

if [ -n "${CATALINA_CONNECTOR_PROXYPORT}" ]; then
  xmlstarlet ed -P -S -L --insert "//Connector[not(@proxyPort)]" --type attr -n proxyPort --value "${CATALINA_CONNECTOR_PROXYPORT}" ${JIRA_INSTALL}/conf/server.xml
fi

if [ -n "${CATALINA_CONNECTOR_SCHEME}" ]; then
  xmlstarlet ed -P -S -L --insert "//Connector[not(@scheme)]" --type attr -n scheme --value "${CATALINA_CONNECTOR_SCHEME}" ${JIRA_INSTALL}/conf/server.xml
fi

if [ -n "${CATALINA_CONNECTOR_SECURE}" ]; then
  xmlstarlet ed -P -S -L --insert "//Connector[not(@secure)]" --type attr -n secure --value "${CATALINA_CONNECTOR_SECURE}" ${JIRA_INSTALL}/conf/server.xml
fi

if [ -n "${JVM_MINIMUM_MEMORY}" ]; then
  sed -i 's/^JVM_MINIMUM_MEMORY=.*/JVM_MINIMUM_MEMORY="'${JVM_MINIMUM_MEMORY}'"/g' ${JIRA_INSTALL}/bin/setenv.sh
fi

if [ -n "${JVM_MAXIMUM_MEMORY}" ]; then
  sed -i 's/^JVM_MAXIMUM_MEMORY=.*/JVM_MAXIMUM_MEMORY="'${JVM_MAXIMUM_MEMORY}'"/g' ${JIRA_INSTALL}/bin/setenv.sh
fi

if [ -n "${JVM_SUPPORT_RECOMMENDED_ARGS}" ]; then
  sed -i 's/^JVM_SUPPORT_RECOMMENDED_ARGS=.*/JVM_SUPPORT_RECOMMENDED_ARGS="'${JVM_SUPPORT_RECOMMENDED_ARGS}'"/g' ${JIRA_INSTALL}/bin/setenv.sh
fi

if [ -n "${CATALINA_OPTS}" ]; then
  sed -i 's/\(CATALINA_OPTS.*\).$/\1 '"${CATALINA_OPTS}"'"/g' ${JIRA_INSTALL}/bin/setenv.sh
fi

# Start JIRA as the correct user
if [ "${UID}" -eq 0 ]; then
    echo "User is currently root. Will change directory ownership to ${JIRA_USER}:${JIRA_GROUP}, then downgrade permission to ${JIRA_USER}"
    PERMISSIONS_SIGNATURE=$(stat -c "%u:%U:%a" "${JIRA_HOME}")
    EXPECTED_PERMISSIONS=$(id -u ${JIRA_USER}):${JIRA_GROUP}:700
    if [ "${PERMISSIONS_SIGNATURE}" != "${EXPECTED_PERMISSIONS}" ]; then
        chmod -R 700 "${JIRA_HOME}" &&
        chown -R "${JIRA_USER}:${JIRA_GROUP}" "${JIRA_HOME}"
    fi
    # Now drop privileges
    exec sudo -E -u "${JIRA_USER}" -- "$@"
else
    exec "$@"
fi
