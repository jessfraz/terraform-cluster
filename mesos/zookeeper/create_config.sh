#!/bin/bash
set -e
set -o pipefail
set -x

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# Create a new copy of the file.
mkdir -p /opt/zookeeper/conf
rm -f /opt/zookeeper/conf/zoo.cfg
cp "${DIR}/zoo.cfg" /opt/zookeeper/conf/zoo.cfg
sed -i "s/\//" /opt/zookeeper/conf/zoo.cfg

# Add the hosts.
if [ -n "${ZOOKEEPER_HOSTS+1}" ]; then
	IFS=',' read -r -a zhosts <<< "$ZOOKEEPER_HOSTS"
	for index in "${!zhosts[@]}"; do
		echo "server.$((index+1))=${zhosts[index]}"  >> /opt/zookeeper/conf/zoo.cfg
	done
fi

# Add the ID.
mkdir -p /var/lib/zookeeper
if [ -n "${ZOOKEEPER_ID+1}" ]; then
	echo "$ZOOKEEPER_ID" > /var/lib/zookeeper/myid
else
	for index in "${!zhosts[@]}"; do
		if [[ "${zhosts[index]}" =~ $LOCAL_ZK_IP ]]; then
			echo "$((index+1))" > /var/lib/zookeeper/myid
		fi
	done
fi
set +x
