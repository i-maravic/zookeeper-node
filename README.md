# zookeeper_node

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with zookeeper_node](#setup)
    * [What zookeeper_node affects](#what-zookeeper_node-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with zookeeper_node](#beginning-with-zookeeper_node)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

Puppet provider to manage nodes on Zookeeper server.

## Module Description

Module supports creation and deletion of Zookeeper nodes.
It also supports data management on them.

It auto requires all the parent nodes of the Zookeeper node that it manages.

It doesn't do recursive creation of nodes, ie. like 'mkdir -p'.
Zookeeper node must not have any children so it can be deleted.

## Setup

### What zookeeper_node affects

* Zookeeper nodes on Zookeeper cluster

### Setup Requirements

Pluginsync should be enabled for this module to be used.
This module requires 'zookeeper' gem to be installed.
Gem is automatically installed by `zookeeper_node` defined resource type.

### Beginning with zookeeper_node

Simple example how to manage Node on Zookeeper cluster

```puppet
  zookeeper_node { "/zookeeper_node":
    ensure  => present,
    server  => 'zookeeper.awesome.com',
    port    => 2181,
    data    => 'some data',
  }
```

## Usage

### Defined Resource Type: `zookeeper_node`

Defined resource type which wraps `zookeeper_node_t` and installs 'zookeeper' gem
to manage Zookeeper node on Zookeeper cluster.

**Parameters within `zookeeper_node`:**

####`ensure`

Defines if the `zookeeper_node` should be 'present' or 'absent'. Defaults to 'present'.

####`path`

Path to manage on Zookeeper cluster. Needs to be absolute path. Must not end with /.
It defaults to resource title.

####`data`

Data to be stored on path on Zookeeper cluster.

####`server`

Zookeeper server to connect to. Defaults to localhost.

####`port`

Zookeeper port to connect to. Defaults to 2181.

### Type: `zookeeper_node_t`

Base type to manage Zookeeper node on Zookeeper cluster.

**Parameters within `zookeeper_node_t`:**

####`path`

Path to manage on Zookeeper cluster. Needs to be absolute path. Must not end with /.
It defaults to namevar.

####`data`

Data to be stored on path on Zookeeper cluster.

####`server`

Zookeeper server to connect to. Defaults to localhost.

####`port`

Zookeeper port to connect to. Defaults to 2181.

## Reference

### Defined Resource Types

* `zookeeper_node`: Manages Zookeeper node on Zookeeper cluster.
It's installing zookeeper gem automatically so the `zookeeper_node_t`
could be applied.

### Defined Types

* `zookeeper_node_t`: Base type to manage Zookeeper node on Zookeeper cluster.
Can be used independently of `zookeeper_node`. It requires 'zookeeper' gem to be
installed so it would work.

### Defined Classes

* `zookeeper_node::dependencies`: Ensures 'zookeeper' gem to be of the latest version.
It's included from `zookeeper_node` defined resource type.

## Limitations

Zookeeper ACL management isn't supported at the moment

## Development

Pull Requests on [GitHub](https://github.com/i-maravic/zookeeper-node) are welcome.
