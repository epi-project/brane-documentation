# The node config file
The node config file (also sometimes referred to as a `node.yml` file) is the main file that defines properties about a node.

It has a close relationship with the [Brane CTL tool](../tools/branectl.md), which can be used to generate it or modify it. Moreover, the file is also used by it to discover the services and the paths they use.

For the services in a node itself, the node config file defines where other services live and how to reach them, as well as paths for files that the services may wish to persistently store. Additionally, it also defines ports and serving addresses for services that are externally available.

In the remainder of this chapter, we will examine all of the possible options configurable with the `node.yml` file. As the name suggests, it is a [YAML](https://yaml.org/) file, and we will thus use YAML types to describe the fields.


## Toplevel
A node config file can be used to describe both control nodes and worker nodes, which means that there are effectively "two versions" of the same file.

First, we will describe the toplevel fields that are always present:

| Field name | Field type       | Required | Description |
|------------|------------------|----------|-------------|
| `proxy`    | String (address) | No       | If given, defines the address (as an `<address>:<port>` pair) of a proxy to route the _control_ traffic that is emitted by this node through. Note that this is different from the BFC's that data transfers are routed through; those are determined on a per-call basis. |
| `node`     | Dictionary       | Yes      | Determines any type-specific configuration options. See below. |

In the next sections we will define the fields for each of the two types of nodes.


## Control node
For a control node, the following fields can be found nested in the `node` dictionary:

| Field name | Field type   | Required | Description |
|------------|--------------|----------|-------------|
| `kind`     | String (set) | Yes      | The kind of the node. Can be either `control` (to get this variant) or `worker` (to get the variant in the [next section](#worker-node)). |
| `paths`    | Dictionary   | Yes      | Contains paths that are used by the various services. See [below](#control-node-paths). |
| `ports`    | Dictionary   | Yes      | Contains the serving addresses & ports for the externally reachable services. See [below](#control-node-ports). |
| `services` | Dictionary   | Yes      | Defines how other services may reach internally-reachable services. See [below](#control-node-services). |
| `topics`   | Dictionary   | Yes      | Defines the Kafka topics used by services internally on the control node. See [below](#control-node-topics). |


### Control node paths
The `paths` dictionary defines paths used by the control node. They are configurable by the following settings:

| Field name | Field type    | Default                | Required | Description |
|------------|---------------|------------------------|----------|-------------|
| `infra`    | String (path) | `./config/infra.yml`   | Yes      | The path to the [`infra.yml`](./infra.md) file that defines all nodes in the instance. |
| `secrets`  | String (path) | `./config/secrets.yml` | Yes      | The path to the [`secrets.yml`](./secrets.md) file that defines secrets used in the [`infra.yml`](./infra.md) file. |
| `certs`    | String (path) | `./config/certs`       | Yes      | The path to the folder with certificate files used by the central node to access client nodes. This should be a folder with nested directories, each of which has a location ID in the instance as its name. In it should be a `ca.pem` file, which is the certificate with which that domain's server certificate is signed. |
| `packages` | String (path) | `./packages`           | Yes      | The path to the folder where package images will be stored when a client uploads them. It is recommended to make it persistent, because the API service will expect any entry in its internal database to have a valid image file on disk matches with it. |

Note that any relative paths are relative to the `node.yml` file itself.

### Control node ports
The `ports` dictionary defines which addresses externally reachable services will host on. They are defined for the following services:

| Field name | Alternative name | Field type              | Default         | Required | Description |
|------------|------------------|-------------------------|-----------------|----------|-------------|
| `api`      | `registry`       | String (socket address) | `0.0.0.0:50051` | Yes      | The address on which the API service will be hosted. |
| `drv`      | `driver`         | String (socket address) | `0.0.0.0:50053` | Yes      | The address on which the driver service will be hosted. |

Note that the addresses must be _socket_ addresses, i.e., they cannot contain hostname (only IPv4 or IPv6 values).

### Control node services
The `services` dictionary defines how to reach services that are not externally available. They are defined for the following services:

| Field name | Alternative name | Field type                  | Default                  | Required | Description |
|------------|------------------|-----------------------------|--------------------------|----------|-------------|
| `brokers`  | `kafka_brokers`  | List of strings (addresses) | `[ "aux-kafka:9092" ]`   | Yes      | The address on which Kafka may be reached. |
| `api`      | `registry`       | String (address)            | `http://brane-api:50051` | Yes      | The address on which the global registry service may be reached by control-node local services. |

Note that Docker service names may be used in these addresses (as seen in the default values), since they are only reachable on the Docker network.

### Control node topics
Finally, the `topics` dictionary defines Kafka topics used by various services in the node. The following fields are defined:

| Field name        | Used by                         | Field type | Default   | Required | Description |
|-------------------|---------------------------------|------------|-----------|----------|-------------|
| `planner_command` | driver service, planner service | String     | `plr-cmd` | Yes      | The topic on which new planning requests can be send. The driver service emits, and the planner service receives. |
| `planner_results` | planner service, driver service | String     | `plr-res` | Yes      | The topic on which results of planning requests are posted by the planner. It is the driver service that consumes them. |



## Worker node
For a worker node, the following fields can be found nested in the `node` dictionary:

| Field name    | Alternative name | Field type   | Required | Description |
|---------------|------------------|--------------|----------|-------------|
| `kind`        |                  | String (set) | Yes      | The kind of the node. Can be either `control` (to get the variant in the [previous section](#control-node)) or `worker` (to get the variant in this section). |
| `location_id` | `id`             | String       | Yes      | The location ID of this node. |
| `paths`       |                  | Dictionary   | Yes      | Contains paths that are used by the various services. See [below](#worker-node-paths). |
| `ports`       |                  | Dictionary   | Yes      | Contains the serving addresses & ports for the externally reachable services. See [below](#worker-node-ports). |
| `services`    |                  | Dictionary   | Yes      | Defines how other services may reach internally-reachable services. See [below](#worker-node-services). |


### Worker node paths
The `paths` dictionary defines paths used by the worker node. They are configurable by the following settings:

| Field name     | Field type    | Default                | Required | Description |
|----------------|---------------|------------------------|----------|-------------|
| `creds`        | String (path) | `./config/creds.yml`   | Yes      | The path to the [`creds.yml`](./creds.md) file that defines how to connect to the actual backend engine that will execute jobs. |
| `certs`        | String (path) | `./config/certs`       | Yes      | The path to the folder with certificate files used by the worker node to access other nodes. See below for how this directory should be structured. |
| `packages`     | String (path) | `./packages`           | Yes      | The path to the folder where package images will be stored when a the domain downloads them. Does not have to be persistent, although it helps because the system will not redownload them every time. |
| `data`         | String (path) | `./data`               | Yes      | The path to the folder where the data that this domain has access to will be stored. It should contain nested directories, one per dataset, with [`data.yml`](TODO) files in those to define the dataset. Note that this directory will be a mix of user-provided datasets and those produced by workflows. |
| `results`      | String (path) | `./results`            | Yes      | The path to the folder where temporary results will be stored. Does not have to be persistent beyond the execution of a single workflow. |
| `temp_data`    | String (path) | `/tmp/data`            | Yes      | The path to the folder where datasets downloaded from other domains will temporarily be stored during execution. Does not have be persistentent beyond the execution of a single task. |
| `temp_results` | String (path) | `/tmp/results`         | Yes      | The path to the folder where intermediate results downloaded from other domains will temporarily be stored during execution. Does not have be persistentent beyond the execution of a single task. |

Note that any relative paths are relative to the `node.yml` file itself.

The `certs` directory has be structured in a specific way. Concretely, the following files and directories have to be available:
  - A `ca.pem` file, which is the root certificate for this domain.
  - A `ca-key.pem` file, which is the private key matching the `ca.pem` certificate.
  - A `server.pem` file, which is the server certificate used by this domain. It has to be signed with `ca.pem`.
  - A `server-key.pem` file, which is the private key matching the `server.pem` certificate.
  - Several nested, each of which has a location ID of a location that this domain may access as its name. In it should be:
    - A `ca.pem` file, which is the certificate with which that domain's server certificate is signed
    - A `client-id.pem` file that contains a client certificate/key pair signed by that domain.

### Worker node ports
The `ports` dictionary defines which addresses externally reachable services will host on. They are defined for the following services:

| Field name | Alternative name | Field type              | Default         | Required | Description |
|------------|------------------|-------------------------|-----------------|----------|-------------|
| `reg`      | `registry`       | String (socket address) | `0.0.0.0:50051` | Yes      | The address on which the local registry service will be hosted. |
| `job`      | `delegate`       | String (socket address) | `0.0.0.0:50052` | Yes      | The address on which the local delegate service will be hosted. |

Note that the addresses must be _socket_ addresses, i.e., they cannot contain hostname (only IPv4 or IPv6 values).

### Worker node services
The `services` dictionary defines how to reach services that are accessed internally. They are defined for the following services:

| Field name | Alternative name | Field type       | Default                  | Required | Description |
|------------|------------------|------------------|--------------------------|----------|-------------|
| `reg`      | `registry`       | String (address) | `http://brane-reg:50051` | Yes      | The address on which the local registry service may be reached by local services. |
| `chk`      | `checker`        | String (address) | `http://brane-chk:50053` | Yes      | The address on which the local checker service may be reached. |

Note that Docker service names may be used in these addresses (as seen in the default values), since they are only reachable on the Docker network.



## Example
To illustrate all of the above, we will give the default `node.yml` file as generated by [`branectl`](../tools/branectl.md).

```yaml

---
# The central config
proxy: ~
node:
  kind: central
  paths:
    infra: "./config/infra.yml"
    secrets: "./config/secrets.yml"
    certs: "./config/certs"
    packages: "./packages"
  ports:
    api: "0.0.0.0:50051"
    drv: "0.0.0.0:50053"
  services:
    brokers:
    - "aux-kafka:9092"
    api: "http://brane-api:50051"
  topics:
    planner_command: plr-cmd
    planner_results: plr-res

---
# The worker config
# For illustrative purposes, this one has a proxy defined
proxy: "https://example_proxy.com:5000"
node:
  kind: worker
  location_id: example_location
  paths:
    creds: "./config/creds.yml"
    certs: "./config/certs"
    packages: "./packages"
    data: "./data"
    results: "./results"
    temp_data: /tmp/data
    temp_results: /tmp/results
  ports:
    reg: "0.0.0.0:50051"
    job: "0.0.0.0:50052"
  services:
    reg: "http://brane-reg:50051"
    chk: "http://brane-chk:50053"
```
