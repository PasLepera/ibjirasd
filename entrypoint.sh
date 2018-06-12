#!/bin/bash
set -e

chown -R "$JIRA_USER":"$JIRA_USER" "$JIRA_HOME"

exec "$@"
