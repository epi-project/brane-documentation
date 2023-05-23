# The backend file
_<img src="../../assets/img/source.png" alt="source" width="16" style="margin-top: 3px; margin-bottom: -3px;"/> [`BackendFile`](https://wiki.enablingpersonalizedinterventions.nl/docs/brane_cfg/backend/struct.BackendFile.html) in [`brane_cfg/backend.rs`](https://wiki.enablingpersonalizedinterventions.nl/docs/src/brane_cfg/backend.rs.html)._

The backend file, or more commonly referenced as the `backend.yml` file, is a worker node configuration file that describes how to connect to the container execution backend. Its location is defined by the [`node.yml`](./node.md) file.

The [`branectl`](TODO) tool can generate this file for you, using the [`branectl generate backend`](TODO) subcommand. See the [chapter on installing a worker node](../../system-admins/installation/worker-node.md) for a realistic example.


## Toplevel layout

The `backend.yml` file is written in [YAML](https://yaml.org). It features only the following three toplevel fields:
- `method`: A map that defines the method of accessing the container execution backend. Can be one of the following options:
  - `!Local`: Connects to the Docker engine local to the node on which the worker node runs. This variant has the following two fields:
    - `path` _\[optional\]_: A string with the path to the Docker socket to connect to. If omitted, will default to `/var/docker/run.sock`.
    - `version` _\[optional\]_: A sequence of two numbers detailling the Docker client version to connect to. If omitted, will negotiate a client version on the fly.

  (_<img src="../../assets/img/source.png" alt="source" width="16" style="margin-top: 3px; margin-bottom: -3px;"/> The method map is defined as [`Credentials`](https://wiki.enablingpersonalizedinterventions.nl/docs/brane_cfg/backend/enum.Credentials.html) in [`brane_cfg/backend.rs`](https://wiki.enablingpersonalizedinterventions.nl/docs/src/brane_cfg/backend.rs.html)._)
- `capabilities` _\[optional\]_: A sequence of strings, each of which defines a capability of the computing backend. Currently supported capabilities are defined [below](#capabilities). If omitted, no capabilities are enabled.
- `hash_containers` _\[optional\]_: A boolean that defines whether to hash containers, enabling [container policies](../../policy-experts/policy-file.md#container-policies) in the [`policies.yml`](../../policy-experts/policy-file.md) file. It may give a massive performance boost when using many different larger containers (100MB+), although the hashes are cached as long as the containers are cached. If omitted, will default to 'true'.

A few example `backend.yml` files:
```yaml
# Defines the simplest possible file, which is a local file with default options
method: !Local
```
```yaml
# Defines a local file that has a different Docker socket path
method: !Local
  path: /home/amy/my-own-docker.sock
```
```yaml
# Defines a default local backend that supports CUDA containers and explicitly hashes all containers
capabilities:
- cuda_gpu
method: !Local
hash_containers: true
```

> <img src="../../assets/img/warning.png" alt="warning" width="16" style="margin-top: 3px; margin-bottom: -3px;"/> In older versions of BRANE (<= 2.0.0), the tagged enum representation (e.g., `!Local`) was not yet supported. Instead, use the additional `kind`-field to distinguish. For example:
> ```yaml
> # This is the same as the first example
> method:
>   kind: local
> ```
> ```yaml
> # This is the same as the second example
> method:
>   kind: local
>   path: /home/amy/my-own-docker.sock
> ```
> ...


## Capabilities
The following capabilities can be used in the `backend.yml` file:
- `cuda_gpu`: States that the compute backend can provide a CUDA accelerator to containers who ask for that. See the [`requirements`](TODO)-field in the user's [`container.yml`](TODO) file.
