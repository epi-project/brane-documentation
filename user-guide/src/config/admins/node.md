# The node file
_<img src="../../assets/img/source.png" alt="source" width="16" style="margin-top: 3px; margin-bottom: -3px;"/> [`NodeConfig`](https://wiki.enablingpersonalizedinterventions.nl/docs/brane_cfg/node/struct.NodeConfig.html) in [`brane_cfg/node.rs`](https://wiki.enablingpersonalizedinterventions.nl/docs/src/brane_cfg/node.rs.html)._

The node file, or more commonly referenced as the `node.yml` file, is a central-, worker- and proxy node configuration file that describes the environment in which the node should run. Most notably, it defines the type of node, where any BRANE software (`branectl`, services) may find other configuration files and which ports to use for all of the services.

The [`branectl`](TODO) tool can generate this file for you, using the [`branectl generate node`](TODO) subcommand. See the [chapter on installing a control node](../../system-admins/installation/control-node.md) for a realistic example.


## Toplevel layout

The `node.yml` file is written in [YAML](https://yaml.org). It defines only two toplevel fields:
- `hostnames`: A map of strings to other strings, which maps hostnames to IP addresses. This is used to work around the issue that certificates cannot be issued for raw IP addresses alone, and need a hostname instead. The hostnames can be defined in this map to make them available to all the services running in this node. For more information, see the [chapter on installing a control node](../../system-admins/installation/control-node.md#generating-configuration) (at the end).
- `node`: A map that has multiple variants based on the specific node configuration. These are all treated below in their own sections.

An example of just the toplevel fields would be:
```yaml
# We don't define any hostnames
hostnames: {}
node: ...
  ...
```
```yaml
# This example allows us to use `amy-worker-node.com` on any of the services to refer to `4.3.2.1`
hostnames:
  amy-worker-node.com: 4.3.2.1
node: ...
  ...
```

Because there are quite a lot of nested fields, we will discuss the various variants of the `node`-map in subsequent sections.

### Central nodes
_<img src="../../assets/img/source.png" alt="source" width="16" style="margin-top: 3px; margin-bottom: -3px;"/> [`CentralConfig`](https://wiki.enablingpersonalizedinterventions.nl/docs/brane_cfg/node/struct.CentralConfig.html) in [`brane_cfg/node.rs`](https://wiki.enablingpersonalizedinterventions.nl/docs/src/brane_cfg/node.rs.html)._

The first variant of the `node`-map is the `!central` variant, which defines a central node. There are two fields in this map:
- `paths`: A map that defines all paths relevant to the central node. Specifically, it maps a string identifier to a string path. The following identifiers are defined:
  - `certs`: The path to the directory with certificate authority files for the worker nodes in the instance. See the [chapter on installing a control node](../../system-admins/installation/control-node.md#adding-certificates) for more information.
  - `packages`: The path to the directory where uploaded packages will be stored. This should be a persistent directory, or at the very least exactly as persistent as the storage of the instance's Scylla database.
  - `infra`: The path to the [`infra.yml`](./infra.md) configuration file.
  - `proxy`: The path to the [`proxy.yml`](./proxy.md) configuration file.

  > <img src="../../assets/img/warning.png" alt="warning" width="16" style="margin-top: 3px; margin-bottom: -3px;"/> Note that all paths defined in the `node.yml` file _must_ be absolute paths, since they are mounted as Docker volumes.

- `services`: A map that defines the service containers in the central node and how they are reachable. It is a map of a service identifier to one of four possible maps: a [kafka service](#kafka-services), [private service](#private-services), a [public service](#public-services) or a [variable service](#variable-services). Each of these are explained at the [end of the chapter](#service-maps).  
  The following identifiers are available:
  - `api` _(or `registry`)_: Defines the `brane-api` container as a [public service](#public-services).
  - `drv` _(or `driver`)_: Defines the `brane-drv` container as a [public service](#public-services).
  - `plr` _(or `planner`)_: Defines the `brane-plr` container as a [kafka service](#kafka-services).
  - `prx` _(or `proxy`)_: Defines the `brane-prx` container as a [variable service](#variable-services).
  - `aux_scylla` _(or `scylla`)_: Defines the `aux-scylla` container as a [private service](#private-services).
  - `aux_kafka` _(or `kafka`)_: Defines the `aux-kafka` container as a [private service](#private-services).
  - `aux_zookeeper` _(or `zookeeper`)_: Defines the `aux-zookeeper` container as a [private service](#private-services).

An example illustrating just the central node:
```yaml
...

node: !central
  paths:
    # Note all paths are full, absolute paths
    certs: /home/amy/config/certs
    packages: /home/amy/packages
    infra: /home/amy/config/infra.yml
    proxy: /home/amy/config/proxy.yml

  services:
    api:
      ...
    drv:
      ...
    # (We can also use the aliases, if we like)
    planner:
      ...
    proxy: ...
      ...

    aux_scylla:
      ...
    aux_kafka:
      ...
    zookeeper:
      ...
```

### Worker nodes
_<img src="../../assets/img/source.png" alt="source" width="16" style="margin-top: 3px; margin-bottom: -3px;"/> [`WorkerConfig`](https://wiki.enablingpersonalizedinterventions.nl/docs/brane_cfg/node/struct.WorkerConfig.html) in [`brane_cfg/node.rs`](https://wiki.enablingpersonalizedinterventions.nl/docs/src/brane_cfg/node.rs.html)._

The second variant of the `node`-map is the `!worker` variant, which defines a worker node. There are three fields in this map:
- `name` _(or `location_id`)_: A string that contains the identifier used to recognize this worker node throughout the system.
- `paths`: A map that defines all paths relevant to the central node. Specifically, it maps a string identifier to a string path. The following identifiers are defined:
  - `certs`: The path to the directory with certificate authority files for the worker nodes in the instance. See the [chapter on installing a control node](../../system-admins/installation/control-node.md#adding-certificates) for more information.
  - `packages`: The path to the directory where uploaded packages will be stored. This should be a persistent directory, or at the very least exactly as persistent as the storage of the instance's Scylla database.
  - `backend`: The path to the [`backend.yml`](./backend.md) configuration file.
  - `policies`: The path to the [`policies.yml`](../../policy-experts/policy-file.md) configuration file.
  - `proxy`: The path to the [`proxy.yml`](./proxy.md) configuration file.
  - `data`: The path to the directory where datasets may be defined that are available on this node. See [`data.yml`](../users/data.md) for more information.
  - `results`: The path to a directory where intermediate results are stored that are created on this node. It does not have to be persistent per sé, although the services will assume they are persistent for the duration of a workflow execution.
  - `temp_data`: The path to a directory where datasets are stored that are downloaded from other nodes. It does not have to be a persistent folder.
  - `temp_results`:  The path to a directory where intermediate results are stored that are downloaded from other nodes. It does not have to be a persistent folder.

  > <img src="../../assets/img/warning.png" alt="warning" width="16" style="margin-top: 3px; margin-bottom: -3px;"/> Note that all paths defined in the `node.yml` file _must_ be absolute paths, since they are mounted as Docker volumes.
- `services`: A map that defines the service containers in the central node and how they are reachable. It is a map of a service identifier to one of two possible maps: a [public service](#public-services) or a [variable service](#variable-services). Each of these are explained at the [end of the chapter](#service-maps).  
  The following identifiers are available:
  - `reg` _(or `registry`)_: Defines the `brane-reg` container as a [public service](#public-services).
  - `job` _(or `delegate`)_: Defines the `brane-job` container as a [public service](#public-services).
  - `chk` _(or `checker`)_: Defines the `brane-chk` container as a [public service](#public-services).
  - `prx` _(or `proxy`)_: Defines the `brane-prx` container as a [variable service](#variable-services).

An example illustrating just the worker node:
```yaml
...

node: !worker
  paths:
    # Note all paths are full, absolute paths
    certs: /home/amy/config/certs
    packages: /home/amy/packages
    backend: /home/amy/config/backend.yml
    policies: /home/amy/config/policies.yml
    proxy: /home/amy/config/proxy.yml
    data: /home/amy/data
    results: /home/amy/results
    temp_data: /tmp/data
    temp_results: /tmp/results

  services:
    reg:
      ...
    job:
      ...
    # (We can also use the aliases, if we like)
    checker:
      ...
    proxy: ...
      ...
```


### Proxy nodes
_<img src="../../assets/img/source.png" alt="source" width="16" style="margin-top: 3px; margin-bottom: -3px;"/> [`ProxyConfig`](https://wiki.enablingpersonalizedinterventions.nl/docs/brane_cfg/node/struct.ProxyConfig.html) in [`brane_cfg/node.rs`](https://wiki.enablingpersonalizedinterventions.nl/docs/src/brane_cfg/node.rs.html)._

The third variant of the `node`-map is the `!proxy` variant, which defines a proxy node. There are two fields in this map:
- `paths`: A map that defines all paths relevant to the proxy node. Specifically, it maps a string identifier to a string path. The following identifiers are defined:
  - `certs`: The path to the directory with certificate authority files for the worker nodes in the instance. See the [chapter on installing a control node](../../system-admins/installation/control-node.md#adding-certificates) for more information.
  - `proxy`: The path to the [`proxy.yml`](./proxy.md) configuration file.

  > <img src="../../assets/img/warning.png" alt="warning" width="16" style="margin-top: 3px; margin-bottom: -3px;"/> Note that all paths defined in the `node.yml` file _must_ be absolute paths, since they are mounted as Docker volumes.
- `services`: A map that defines the service containers in the proxy node and how they are reachable. It is a map of a service identifier to a [variable service](#variable-services). This is explained at the [end of the chapter](#service-maps).  
  The following identifiers are available:
  - `prx` _(or `proxy`)_: Defines the `brane-prx` container as a [public service](#public-services) (note: this is different from the other node types).

An example illustrating just the worker node:
```yaml
...

node: !worker
  paths:
    # Note all paths are full, absolute paths
    certs: /home/amy/config/certs
    proxy: /home/amy/config/proxy.yml

  services:
    prx:
      ...
```


## Service maps
Through the various `node` variants, a few types of service maps appear. In this section, we will define their layouts.

### Kafka services
_<img src="../../assets/img/source.png" alt="source" width="16" style="margin-top: 3px; margin-bottom: -3px;"/> [`KafkaService`](https://wiki.enablingpersonalizedinterventions.nl/docs/brane_cfg/node/struct.KafkaService.html) in [`brane_cfg/node.rs`](https://wiki.enablingpersonalizedinterventions.nl/docs/src/brane_cfg/node.rs.html)._

A kafka service represents a service that is not directly reachable via network messages, but instead only on a Kafka event channel. Currently, the only service that is accessible this way is the planner service (`brane-plr`) on the central node.

Kafka services have three fields:
- `name`: A string with the name of the Docker container. This can be anything, but by convention, this is `brane-` followed by the ID of the service (e.g., `brane-prx` or `brane-api`). On worker nodes, this may optionally be suffixed by the name of the worker (e.g., `brane-reg-bob`), and on proxy nodes, this may be suffixed by `proxy` (e.g., `brane-prx-proxy`). Finally, third-party services are often named `aux-` and then the service ID instead or `brane-` (e.g., `aux-scylla`).
- `cmd`: A string name of the Kafka event channel to send command events on. Put differently, defines a channel where the service in question is listening on and other services may push events to.
- `res`: A string name of the Kafka event channel to listen for results on. Put differently, defines a channel where any other service is listening on and the service in question can push events to.

An example showing a Kafka service:
```yaml
...

node: !central
  # The type of service is hardcoded for every node, so no need for the tags (e.g., `!kafka`)
  plr:
    name: brane-plr
    cmd: plr-cmd
    res: plr-res

  ...
```

### Private services
_<img src="../../assets/img/source.png" alt="source" width="16" style="margin-top: 3px; margin-bottom: -3px;"/> [`PrivateService`](https://wiki.enablingpersonalizedinterventions.nl/docs/brane_cfg/node/struct.PrivateService.html) in [`brane_cfg/node.rs`](https://wiki.enablingpersonalizedinterventions.nl/docs/src/brane_cfg/node.rs.html)._

A private service represents a service that is only accessible for other BRANE services, but not from outside of the Docker network. A few examples of such services are `aux-scylla` or `aux-kafka`.

Private services have three fields:
- `name`: A string with the name of the Docker container. This can be anything, but by convention, this is `brane-` followed by the ID of the service (e.g., `brane-prx` or `brane-api`). On worker nodes, this may optionally be suffixed by the name of the worker (e.g., `brane-reg-bob`), and on proxy nodes, this may be suffixed by `proxy` (e.g., `brane-prx-proxy`). Finally, third-party services are often named `aux-` and then the service ID instead or `brane-` (e.g., `aux-scylla`).
- `address`: A string with the address that other services running on this node can use to reach this service. Because this only applies to services in the same Docker network, you can use Docker DNS names (e.g., you can use `aux-scylla` as a hostname to refer a container with the same name).
- `bind`: A string with the socket address (and port) that the service should launch as. The port should match the one given in `address`.

An example showing a private service:
```yaml
...

node: !central
  # The type of service is hardcoded for every node, so no need for the tags (e.g., `!kafka`)
  aux_scylla:
    name: aux-scylla
    # The Scylla images launches of 9042 by default, so might as well use that
    address: aux-scylla:9042
    # Accepts any connection
    bind: 0.0.0.0:9042

  ...
```

> <img src="../../assets/img/warning.png" alt="warning" width="16" style="margin-top: 3px; margin-bottom: -3px;"/> Note that providing `127.0.0.1` as a bind address will not work, since the `127.0.0.1` refers to the _container_ and not the host. Thus, using that address will make the service inaccessible for everyone.

### Public services
_<img src="../../assets/img/source.png" alt="source" width="16" style="margin-top: 3px; margin-bottom: -3px;"/> [`PublicService`](https://wiki.enablingpersonalizedinterventions.nl/docs/brane_cfg/node/struct.PublicService.html) in [`brane_cfg/node.rs`](https://wiki.enablingpersonalizedinterventions.nl/docs/src/brane_cfg/node.rs.html)._

A public service represents a service that is accessible for other BRANE services and from outside of the Docker network. A few examples of such services are `brane-drv` or `brane-reg`.

Private services have three fields:
- `name`: A string with the name of the Docker container. This can be anything, but by convention, this is `brane-` followed by the ID of the service (e.g., `brane-prx` or `brane-api`). On worker nodes, this may optionally be suffixed by the name of the worker (e.g., `brane-reg-bob`), and on proxy nodes, this may be suffixed by `proxy` (e.g., `brane-prx-proxy`). Finally, third-party services are often named `aux-` and then the service ID instead or `brane-` (e.g., `aux-scylla`).
- `address`: A string with the address that other services running on this node can use to reach this service. Because this only applies to services in the same Docker network, you can use Docker DNS names (e.g., you can use `brane-drv` as a hostname to refer a container with the same name).
- `bind`: A string with the socket address (and port) that the service should launch as. The port should match the one given in `address`.
- `external_address`: A string with an address that services running on other nodes can use to reach this service. Specifically, this is the address that the node will send to other nodes as a kind of calling card, i.e., an address where they can be reached.
  > <img src="../../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px;"/> Because this is just an advertised address, this address can be used to connect through a gateway (or proxy node) that then redirects the traffic to the correct machine and port.

An example showing a public service:
```yaml
...

node: !central
  # The type of service is hardcoded for every node, so no need for the tags (e.g., `!kafka`)
  api:
    name: brane-api
    address: http://brane-api:50051
    # Accepts any connection
    bind: 0.0.0.0:50051
    # In this example, we are running on node `amy` living at `amy-central-node.com`
    external_address: http://amy-central-node.com:50051

  ...
```

> <img src="../../assets/img/warning.png" alt="warning" width="16" style="margin-top: 3px; margin-bottom: -3px;"/> Note that providing `127.0.0.1` as a bind address will not work, since the `127.0.0.1` refers to the _container_ and not the host. Thus, using that address will make the service inaccessible for everyone.

### Variable services
_<img src="../../assets/img/source.png" alt="source" width="16" style="margin-top: 3px; margin-bottom: -3px;"/> [`PrivateOrExternalService`](https://wiki.enablingpersonalizedinterventions.nl/docs/brane_cfg/node/enum.PrivateOrExternalService.html) in [`brane_cfg/node.rs`](https://wiki.enablingpersonalizedinterventions.nl/docs/src/brane_cfg/node.rs.html)._

A variable service is one where a choice can be made between two different kinds of services. Specifically, one can choose to either host a [private service](#private-services), or something called an external service, which defines a service hosted on another node or machine. This is currently only used by the `brane-prx` service in `central` or `worker` nodes, to support optionally outsourcing the proxy service to a dedicated node.

Subsequently, there are two variants of this type of service:
- `!private`: Defines a private service map that describes how to host the service. This is exactly identical to the [private service](#private-services) other than the tag.
- `!external`: Defines an externally running service. It has one field only:
  - `address`: A string with the address where all the other services on this node should send their traffic to.

  (_<img src="../../assets/img/source.png" alt="source" width="16" style="margin-top: 3px; margin-bottom: -3px;"/> The external map variant is defined as [`ExternalService`](https://wiki.enablingpersonalizedinterventions.nl/docs/brane_cfg/node/struct.ExternalService.html) in [`brane_cfg/node.rs`](https://wiki.enablingpersonalizedinterventions.nl/docs/src/brane_cfg/node.rs.html)._)

A few examples of variable services:
```yaml
# Example that show the private variant of the variable service.

...

node: !worker
  # Note that this is just a private service
  prx: !private
    name: brane-prx
    address: brane-prx:50050
    bind: 0.0.0.0:50050

  ...
```
```yaml
# Example that show the external variant of the variable service

...

node: !worker
  # We refer to a node living at the host `amy-proxy-node.com`
  prx: !external
    address: amy-proxy-node.com:50050

  ...
```


## Full examples
Finally, we show a few full examples of `node.yml` files.

```yaml
# Shows a full central node
hostnames: {}
node: !central
  paths:
    # Note all paths are full, absolute paths
    certs: /home/amy/config/certs
    packages: /home/amy/packages
    infra: /home/amy/config/infra.yml
    proxy: /home/amy/config/proxy.yml

  services:
    api:
      name: brane-api
      address: http://brane-api:50051
      # Accepts any connection
      bind: 0.0.0.0:50051
      # In this example, we are running on node `amy` living at `amy-central-node.com`
      external_address: http://amy-central-node.com:50051
    drv:
      name: brane-drv
      address: http://brane-drv:50053
      bind: 0.0.0.0:50053
      external_address: http://amy-central-node.com:50053
    # (We can also use the aliases, if we like)
    planner:
      name: brane-plr
      cmd: plr-cmd
      res: plr-res
    # (Shows the private variant of the proxy service)
    proxy: !private
      name: brane-prx
      address: brane-prx:50050
      bind: 0.0.0.0:50050

    aux_scylla:
      name: aux-scylla
      address: aux-scylla:9042
      bind: 0.0.0.0:9042
    aux_kafka:
      name: aux-kafka
      address: brane-prx:9092
      bind: 0.0.0.0:9092
    zookeeper:
      name: aux-zookeeper
      address: aux-zookeeper:65535
      bind: 0.0.0.0:65535
```

```yaml
# Shows a full worker node, with a hostname mapping for `amy-worker-node.com`
hostnames:
  amy-worker-node.com: 4.3.2.1
node: !worker
  paths:
    # Note all paths are full, absolute paths
    certs: /home/amy/config/certs
    packages: /home/amy/packages
    backend: /home/amy/config/backend.yml
    policies: /home/amy/config/policies.yml
    proxy: /home/amy/config/proxy.yml
    data: /home/amy/data
    results: /home/amy/results
    temp_data: /tmp/data
    temp_results: /tmp/results

  services:
    reg:
      name: brane-reg-amy
      address: http://brane-reg:50051
      bind: 0.0.0.0:50051
      external_address: http://amy-worker-node.com:50051
    job:
      name: brane-job-amy
      address: http://brane-job:50052
      bind: 0.0.0.0:50052
      external_address: http://amy-worker-node.com:50052
    # (We can also use the aliases, if we like)
    checker:
      name: brane-chk-amy
      address: http://brane-chk:50053
      bind: 0.0.0.0:50053
      external_address: http://amy-worker-node.com:50053
    # (Shows the external variant of the proxy service)
    proxy: !external
      address: amy-proxy-node.com:50050
```

```yaml
# Shows a full proxy node
hostnames: {}
node: !proxy
  paths:
    # Note all paths are full, absolute paths
    certs: /home/amy/config/certs
    proxy: /home/amy/config/proxy.yml

  services:
    # The proxy node uses a hardcoded public service
    proxy: !external
      name: brane-prx-proxy
      address: http://brane-prx:50050
      bind: 0.0.0.0:50050
      external_address: http://amy-proxy-node.com:50050
```
