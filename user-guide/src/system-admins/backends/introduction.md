# Brane compute backends
In principle, Brane is agnostic to the type of backend that actually runs the containers scheduled by Brane and accepted by domains.
There are two obvious choices that are currently implemented: [Docker](https://docker.com), which runs containers on a single machine (usually the machine where the Brane worker is running); and [Kubernetes](https://kubernetes.io), which runs containers on a distributed cluster.

> <img src="../../assets/img/warning.png" alt="warning" width="16" style="margin-top: 3px; margin-bottom: -3px"/> Sadly, the Kubernetes backend has been broken since Brane version 1.0.0. A fix is being implemented, but needs some more fundamental changes to the framework to not need a hacky solution (e.g., [token transfers](https://wiki.enablingpersonalizedinterventions.nl/specification/future/introduction.html)).

The next chapters contain more details on each of the backends:
1. The [local](./local.md)-backend; and
2. The [Kubernetes](./k8s.md)-backend.
