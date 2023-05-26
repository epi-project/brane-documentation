# The proxy file
_<img src="../../assets/img/source.png" alt="source" width="16" style="margin-top: 3px; margin-bottom: -3px;"/> [`ProxyConfig`](https://wiki.enablingpersonalizedinterventions.nl/docs/brane_cfg/proxy/struct.ProxyConfig.html) in [`brane_cfg/proxy.rs`](https://wiki.enablingpersonalizedinterventions.nl/docs/src/brane_cfg/proxy.rs.html)._

The proxy file, or more commonly referenced as the `proxy.yml` file, is a central-, worker- and proxy node configuration file that describes how to deal with outgoing connections out of the node. For more information, see the documentation for the [`brane-prx`](https://wiki.enablingpersonalizedinterventions.nl/docs/brane_prx/index.html) service. Its location is defined by the [`node.yml`](./node.md) file.

The [`branectl`](TODO) tool can generate this file for you, using the [`branectl generate proxy`](TODO) subcommand. See the [chapter on installing a control node](../../system-admins/installation/control-node.md) for a realistic example.


## Toplevel layout

The `proxy.yml` file is written in [YAML](https://yaml.org). It features only the following three toplevel fields:
- `outgoing_range`: A map that defines the range of ports that can be allocated when other BRANE services request new outgoing connections. This port should be sufficiently large to support at least two connections to every worker node that this node will talk to (which, in the case of a central node('s proxy node), is all worker nodes). The map has the following two fields:
  - `start`: A positive number indicating the start port (inclusive).
  - `end`: A positive number indicating the end port (inclusive).
- `incoming`: A map that maps incoming ports to BRANE service addresses for incoming connections. Specifically, every key is a number indicating the port that can be connected to, where the connection will then be forwarded to the address specified in the value. Must be given using a scheme, an IP address or hostname and a port.
- `forward` _\[optional\]_: A map that carries any configuration for forwarding traffic through a sockx proxy. Specifically, it is a map with the following fields:
  - `address`: The address to forward the traffic to. Must be given using a scheme (either `socks5` or `socks6`), an IP address or hostname and a port.
  - `protocol`: The protocol to use for forwarding traffic. Can be either `socks5` or `socks6` to use the [SOCKS](https://en.wikipedia.org/wiki/SOCKS) protocol version 5 or 6, respectively.

The following examples are examples of valid `proxy.yml` files:
```yaml
# This is a minimal example, supporting up to ~50 worker nodes
outgoing_range:
  start: 4200
  end: 4299
incoming: {}
```
```yaml
# A more elaborate example mapping a few incoming ports as well
outgoing_range:
  start: 4200
  end: 4299
incoming:
  5200: http://brane-api:50051
  5201: grpc://brane-drv:50053
```
```yaml
# An example where we route some network traffic
outgoing_range:
  start: 4200
  end: 4299
incoming: {}
forward:
  address: socks5://socks-proxy.net:1234
  protocol: socks5
```

> <img src="../../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px;"/> The `protocol`-field in the `forward`-map may become obsolete in future versions of BRANE if we apply stricter code restrictions on the protocol used in the `address`-field. You can ease the transition already by being careful which protocol to use.
