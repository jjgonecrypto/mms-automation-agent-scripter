#!/usr/bin/env bash

# Script to download, configure and run the latest MMS Automation Agent
# Currently only supports OSX x64 environments
# Usage: <groupId> <apiKey> <baseUrl>

AGENT_ENVIRONMENT="osx_x86_64"
FILE_EXT="tar.gz"

mkdir -p ~/mms-agents/automation
pushd ~/mms-agents/automation

if [ "$1" != "restart" ]
then
	echo -e "\033[0;33mDownloading latest agent\033[0m"
	curl -OL http://mms.mongodb.com/download/agent/automation/mongodb-mms-automation-agent-latest.$AGENT_ENVIRONMENT.$FILE_EXT

	#assume tarball and explode into current direction
	echo -e "\033[0;33mExtracting\033[0m"
	tar -xzf ./mongodb-mms-automation-agent-latest.$AGENT_ENVIRONMENT.$FILE_EXT --strip-components 1

	#insert command line args into config file 
	echo -e "\033[0;33mSetting mmsGroupId to \033[0m$1"
	sed -i.bak -E "s/^mmsGroupId.+$/mmsGroupId=$1/" local.config
	echo -e "\033[0;33mSetting mmsApiKey to \033[0m$2"
	sed -i.bak -E "s/^mmsApiKey.+$/mmsApiKey=$2/" local.config
	echo -e "\033[0;33mSetting mmsBaseUrl to \033[0m$3"
	sed -i.bak -E "s/^mmsBaseUrl.+$/mmsBaseUrl=$(echo $3 | sed -E 's/\//\\\//g')/" local.config

fi

#kill old automation processes
echo -e "\033[0;33mKilling any old automation processes\033[0m"
pkill -f automation
pkill -f automation

#start automation agent
echo -e "\033[0;33mStarting agent\033[0m"
nohup ./mongodb-mms-automation-agent --config=./local.config >> /var/log/mongodb-mms-automation/automation-agent.log 2>&1 &
popd
