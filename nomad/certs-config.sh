#!/bin/bash
set -e
set -o pipefail

# Make sure we have a certdir.
# This is filled by the Makefile.
if [[ -z "$CERTDIR" ]]; then
	echo "Set the CERTDIR env var."
	exit 1
fi

# Make sure we have the tmpdir set as well.
# This is filled by the Makefile.
if [[ -z "$NOMAD_TMPDIR" ]]; then
	echo "Set the NOMAD_TMPDIR env var."
	exit 1
fi

# Chown the certs since docker will own them as root.
sudo chown -R "${USER}:${USER}" "$CERTDIR"

# Create variables to hold base64+gzip encoded values of the files.
CONSUL_CA=$(gzip "${CERTDIR}/consul-ca.pem" | base64 -w0)

CONSUL_SERVER_KEY=$(sudo gzip -c "${CERTDIR}/consul-server-key.pem" | base64 -w0)
CONSUL_SERVER_CERT=$(gzip -c "${CERTDIR}/consul-server.pem" | base64 -w0)

CONSUL_CLI_KEY=$(sudo gzip -c "${CERTDIR}/consul-cli-key.pem" | base64 -w0)
CONSUL_CLI_CERT=$(gzip -c "${CERTDIR}/consul-cli.pem" | base64 -w0)

# Add the certs to the bastion config.
cat <<-EOF >> "${NOMAD_TMPDIR}/cloud-config-bastion.yml"
- path: "/etc/consul/certs/ca.pem"
  permissions: "0644"
  owner: "root"
  encoding: "gzip+base64"
  content: |
    ${CONSUL_CA}
- path: "/etc/consul/certs/cli-key.pem"
  permissions: "0644"
  owner: "root"
  encoding: "gzip+base64"
  content: |
    ${CONSUL_CLI_KEY}
- path: "/etc/consul/certs/cli.pem"
  permissions: "0644"
  owner: "root"
  encoding: "gzip+base64"
  content: |
    ${CONSUL_CLI_CERT}
EOF

# Add the certs to the master config.
cat <<-EOF >> "${NOMAD_TMPDIR}/cloud-config-master.yml"
- path: "/etc/consul/certs/ca.pem"
  permissions: "0644"
  owner: "root"
  encoding: "gzip+base64"
  content: |
    ${CONSUL_CA}
- path: "/etc/consul/certs/cli-key.pem"
  permissions: "0644"
  owner: "root"
  encoding: "gzip+base64"
  content: |
    ${CONSUL_CLI_KEY}
- path: "/etc/consul/certs/cli.pem"
  permissions: "0644"
  owner: "root"
  encoding: "gzip+base64"
  content: |
    ${CONSUL_CLI_CERT}
- path: "/etc/consul/certs/server-key.pem"
  permissions: "0644"
  owner: "root"
  encoding: "gzip+base64"
  content: |
    ${CONSUL_SERVER_KEY}
- path: "/etc/consul/certs/server.pem"
  permissions: "0644"
  owner: "root"
  encoding: "gzip+base64"
  content: |
    ${CONSUL_SERVER_CERT}
EOF

# Add the certs to the agent config.
cat <<-EOF >> "${NOMAD_TMPDIR}/cloud-config-agent.yml"
- path: "/etc/consul/certs/ca.pem"
  permissions: "0644"
  owner: "root"
  encoding: "gzip+base64"
  content: |
    ${CONSUL_CA}
- path: "/etc/consul/certs/cli-key.pem"
  permissions: "0644"
  owner: "root"
  encoding: "gzip+base64"
  content: |
    ${CONSUL_CLI_KEY}
- path: "/etc/consul/certs/cli.pem"
  permissions: "0644"
  owner: "root"
  encoding: "gzip+base64"
  content: |
    ${CONSUL_CLI_CERT}
EOF
