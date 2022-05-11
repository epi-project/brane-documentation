# The `vm` infrastructure
The `vm` infrastructure is the simplest off-site infrastructure that Brane supports.

In this infrastructure kind, it connects to a node that has a running Docker engine, and will deploy any jobs scheduled on this infrastructure as containers on that node.

The connection is made via SSH, but run through [Xenon](https://github.com/xenon-middleware/xenon) middleware to unify its connection with other types of infrastructures.

To define a `vm` infrastructure, one has to tell Brane where its services may be found and where it may find the remote node. Additionally, either an SSH username/password or an SSH key needs to be given.


## YAML specification
The following fields are required for the `vm` infrastructure kind:
- `address`: The address where to reach the node where we want to reach jobs on. Will be used from within containers, so don't use `localhost`.
- `callback_to`: The endpoint of the Brane callback service, which handles events coming from package containers. Note that this address is accessed from inside containers, which means that you _can_ access Docker network DNS names (like `brane-clb`), but _cannot_ use `localhost` (as that would reference the container instead of the node).
- `registry`: The endpoint of the Docker registry which stores the package images. In contrast to the `callback_to` field, this address is called from the Docker daemon _outside_ of any containers. This means you _can_ use `localhost`, but you _cannot_ use any of the Docker network DNS names (like `brane-aux-registry`).
