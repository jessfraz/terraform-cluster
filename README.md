# azure-terraform-cluster

Scripts to create a minimal mesos or nomad cluster on Azure using terraform.

**Table of Contents**


* [Overview](README.md#overview)
   * [Mesos](README.md#mesos)
   * [Nomad](README.md#nomad)
* [Using the Makefile](README.md#using-the-makefile)
   * [Spinning up a cluster](README.md#spinning-up-a-cluster)
* [Azure credentials setup](README.md#azure-credentials-setup)
   * [Creating a service principal](README.md#creating-a-service-principal)

## Overview

This creates `3` master and `${variable}` agents in a mesos or nomad cluster.

It also creates a "jumpbox" or ["bastion host"](https://en.wikipedia.org/wiki/Bastion_host)
since all the masters and agents are not publicly accessible.

The base image for all the virtual machines 
is [CoreOS Container Linux](https://coreos.com/os/docs/latest/).

The cloud-config.yml files defines the servers running on each of the hosts.
The hosts are designed to be super minimal.

### Mesos

On the **bastion server** we run:

- [Mesos Marathon](https://mesosphere.github.io/marathon/)

On the **masters** we run:

- Mesos Master
- Zookeeper


On the **agents** we run:

- Mesos Agent

### Nomad

On the **bastion server** we run:

- _nothing_

On the **masters** we run:

- Consul
- Nomad Server

On the **agents** we run:

- Nomad Agent

## Using the `Makefile`

You will need to set the following environment variables:

- `AZURE_CLIENT_ID`
- `AZURE_CLIENT_SECRET`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`

See [creating a service principal](#creating-a-service-principal) on how to get
these values.

```console
$ make help
mesos-apply                    Run terraform apply for mesos.
mesos-destroy                  Run terraform destroy for mesos.
nomad-apply                    Run terraform apply for nomad.
nomad-destroy                  Run terraform destroy for nomad.
shellcheck                     Run shellcheck on all scripts in the repository.
test                           Runs all the tests.
update-terraform               Update terraform binary locally from the docker container.
update                         Run all update targets.
```

### Spinning up a cluster

This is as simple as:

```console
$ AZURE_CLIENT_ID=0000 AZURE_CLIENT_SECRET=0000 AZURE_TENANT_ID=0000 AZURE_SUBSCRIPTION_ID=0000 \
    make az-apply
```

## Azure credentials setup

You need a service principal in order to use the `Makefile`.

### Creating a service principal

```console
$ az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/SUBSCRIPTION_ID"
```

The command will output the following:

```json
{
    "appId": "00000000-0000-0000-0000-000000000000",
    "displayName": "azure-cli-2017-06-05-10-41-15",
    "name": "http://azure-cli-2017-06-05-10-41-15",
    "password": "0000-0000-0000-0000-000000000000",
    "tenant": "00000000-0000-0000-0000-000000000000"
}
```

These values map to the `Makefile` variables like so:

- `appId` is the `AZURE_CLIENT_ID` defined above
- `password` is the `AZURE_CLIENT_SECRET` defined above
- `tenant` is the `AZURE_TENANT_ID` defined above

**Reference docs:**

- `terraform` docs on setting up authentication:
[here](https://www.terraform.io/docs/providers/azurerm/authenticating_via_service_principal.html).

