# The `local` infrastructure
The `local` infrastructure kind is the simplest infrastructure kind that Brane supports.

In this infrastructure, Brane just schedules jobs on the local Docker daemon where it is also running. This, of course, implies that Brane has to run in a local Docker engine too; this means that this infrastructure kind cannot be used when the control plane is deployed on a Kubernetes cluster.

Broadly, the `local` infrastructure only needs to know the location of some Brane services and the Docker network name. The Brane infrastructure knows the rest, because it's running locally anyway.


## YAML specification
The following fields are required in a `local` infrastructure:
- `callback_to`: The endpoint of the Brane callback service, which handles events coming from package containers. Note that this address is accessed from inside containers, which means that you _can_ access Docker network DNS names (like `brane-clb`), but _cannot_ use `localhost` (as that would reference the container instead of the node).
- `network`: The name of the Docker network to create for all Brane job containers. Is used to both shield access to Brane to non-related containers and to have Docker generate hostnames for each container. It can be anything, as long as it equals the name of the network defined in `docker-compose-brn.yml`.
- `registry`: The endpoint of the Docker registry which stores the package images. In contrast to the `callback_to` field, this address is called from the Docker daemon _outside_ of any containers. This means you _can_ use `localhost`, but you _cannot_ use any of the Docker network DNS names (like `brane-aux-registry`).

Aside from that, there is also one optional fields:
- `mount_dfs`: If given, then it makes a distributed JuiceFS filesystem available for the packages running on this infrastructure. The value of this field is the endpoint where the DFS may be reached (as a `redis://<address>` URL). Note that this address is used from within containers, so don't use `localhost`.

Finally, there is also a to-be-used field that is accepted by the parser but not yet used by the code:
- `proxy_address`: The address of the Bridging Function Chain to route all data through. Will be used by Brane to provide configurable network security and policy enforcement.

With all of those in mind, an example of a typical `local` infrastructure looks as follows:
```bash
locations:
  # The name of the local infrastructure
  local:
    # It's a local (i.e., same-as-the-control-plane Docker engine)
    kind: local

    # The name of the Docker network for Brane. This shields it from other containers and provides hostnames. Make sure it equals the value in docker-compose-brn.yml.
    network: brane

    # The endpoint of the Docker registry. You'll likely won't have to change this.
    registry: "localhost:50050"

    # The endpoint of the brane-clb service. By default, routes within the same Docker network.
    # Note: is relative to containers (so localhost won't work!!)
    callback_to: "http://brane-clb:50052"

    # The endpoint for the distributed filesystem mount. By default, routes within the same Docker network.
    mount_dfs: "redis://aux-redis"
```
By coincidence, this is the 'quick start' file when deploying Brane as a local deployment. Because it mostly relies on container networking and localhost, you will likely not need to change it from it's default provided properties.

It may be found under `contrib/config/infra-local.yml`.
