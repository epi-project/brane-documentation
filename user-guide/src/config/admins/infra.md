# The infrastructure file
_<img src="../../assets/img/source.png" alt="source" width="16" style="margin-top: 3px; margin-bottom: -3px;"/> [`InfraFile`](/docs/brane_cfg/infra/struct.InfraFile.html) in [`brane_cfg/infra.rs`](/docs/src/brane_cfg/infra.rs.html)._

The infrastructure file, or more commonly referenced as the `infra.yml` file, is a control node configuration file that is used to define the worker nodes part of a particular BRANE instance. Its location is defined by the [`node.yml`](./node.md) file.

The [`branectl`](TODO) tool can generate this file for you, using the [`branectl generate infra`](TODO) subcommand. See the [chapter on installing a control node](../../system-admins/installation/control-node.md) for a realistic example.


## Toplevel layout

The `infra.yml` file is written in [YAML](https://yaml.org). It features only the following toplevel field:
- `locations`: A map that details the nodes present in the instance. It maps from strings, representing the node identifiers, to another map with three fields:
  - `name`: Defines a human-friendly name for the node. This is only used on the control node, and only to make some logging messages nicer; there are therefor no constraints on this name.
  - `delegate`: The address of the delegate service (i.e., `brane-job`) on the target worker node. Must be given using a scheme (either `http` or `grpc`), an IP address or hostname and a port.
  - `registry`: The address of the local registry service (i.e., `brane-reg`) on the target worker node. Must be given using a scheme (`https`), an IP address or hostname and a port.

For example, the following defines an `infra.yml` file for two workers, `amy` at `amy-worker-node.com` and `bob` at `192.0.2.2`:
```yaml
locations:
  # Amy's node
  amy:
    name: Amy's Worker Node
    delegate: grpc://amy-worker-node.com:50052
    registry: https://amy-worker-node.com:50051

  # Bob's node
  bob:
    name: Bob's Worker Node
    delegate: http://192.0.2.2:1234
    registry: https://192.0.2.2:1235
```
