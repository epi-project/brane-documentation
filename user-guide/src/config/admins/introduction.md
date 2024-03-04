# Configuration files for administrators
In this chapter, you can find an overview of the configuration files for administrators.

There are also a few configuration files not mentioned here, which are user-facing. You can find them in [these chapters](../users/introduction.md) instead. Or check the sidebar on the left.

The configuration files for administrators are sorted by node type. The files are referenced by their canonical name.


## Control node
- [`infra.yml`](./infra.md): A **YAML** file that defines the worker nodes in the instance represented by the control node.
- [`proxy.yml`](./proxy.md): A **YAML** file that defines the proxy settings for outgoing node traffic. Can also be found on the [worker](#worker-node) and [proxy](#proxy-node) nodes.
- [`node.yml`](./node.md): A **YAML** file that defines the environment settings for this node, such as paths of the directories and the other configuration files, ports, hostnames, etc. Can also be found on the [worker](#worker-node) and [proxy](#proxy-node) nodes.


## Worker node
- [`backend.yml`](./backend.md): A **YAML** file that defines how the worker node connects to the container execution backend. Currently, only a local Docker backend is supported, with a Kubernetes backend in development.
- [`policies.yml`](../../policy-experts/policy-file.md): A **YAML** file that defines any access control rules for which containers may be executed, and which datasets may be downloaded by whom. For more information, see the [chapters for policy experts](../../policy-experts/introduction.md).
- [`data.yml`](../users/data.md): A **YAML** file that defines the layout of a dataset that is published on a worker node. Is the same file as used by [users](../users/introduction.md).
- [`proxy.yml`](./proxy.md): A **YAML** file that defines the proxy settings for outgoing node traffic. Can also be found on the [central](#central-node) and [proxy](#proxy-node) nodes.
- [`node.yml`](./node.md): A **YAML** file that defines the environment settings for this node, such as paths of the directories and the other configuration files, ports, hostnames, etc. Can also be found on the [central](#central-node) and [proxy](#proxy-node) nodes.


## Proxy node
- [`proxy.yml`](./proxy.md): A **YAML** file that defines the proxy settings for outgoing node traffic. Can also be found on the [central](#central-node) and [worker](#worker-node) nodes.
- [`node.yml`](./node.md): A **YAML** file that defines the environment settings for this node, such as paths of the directories and the other configuration files, ports, hostnames, etc. Can also be found on the [central](#central-node) and [worker](#worker-node) nodes.
