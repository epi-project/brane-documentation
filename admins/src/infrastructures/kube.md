# The `kube` infrastructure
With the `kube` infrastructure kind, Brane will attempt to connect to a (remote) Kubernetes cluster to run its jobs on.

This connection will be performed using the [Kubernetes Open API](https://kubernetes.io/docs/concepts/overview/kubernetes-api/), which means that any authentication is performed by providing a Kubernetes config file (more about that in the [deployment](../installation/deployment.md) chapter).

To define a `kube` infrastructure, one has to tell Brane where its services may be found and where it may find the cluster. Additionally, a Kubernetes config is given that contains the credentials to connect to the cluster with and any necessary certificates.


## YAML specification
The following fields are required for the `kube` infrastructure kind:
- `address`: The address where to reach the node where we want to reach jobs on. Will be used from within containers, so don't use `localhost`.
- `callback_to`: The endpoint of the Brane callback service, which handles events coming from package containers. Note that this address is accessed from inside containers, which means that you _can_ use Kubernetes network DNS names (like `brane-clb.brane-control.svc.cluster.local`), but _cannot_ use `localhost` (as that would reference the container instead of the node).
- `registry`: The endpoint of the Docker registry which stores the package images. In contrast to the `callback_to` field, this address is called from the Docker daemon _outside_ of any containers. This means you _can_ use `localhost`, but you _cannot_ use any of the Docker network DNS names (like `brane-aux-registry`).
- `namespace`: The name of the Kubernetes namespace. Any name is allowed, as long as the namespace exists and (ideally) is not used by other services.
- `credentials`: A field describing the credentials for this infrastructure kind. For the `kube` kind, this can only be with the `config` mechanism, which takes a Kubernetes file. Note that this file has to be encoded as Base64.
  > <img src="../assets/img/info.png" alt="drawing" width="16" style="margin-top: 3px; margin-bottom: -3px"/> This requirement will probably be lifted soon. For now, though, you should make sure that your file is encoded (and only once; don't re-encode it if you store it in `secrets.yml`).
  An example of such a credential:
  ```yaml
  credentials:
    mechanism: config
    # We will parse the config from the secrets.yml file
    file: s$k8s-config
  ```

Then, there are also a few optional fields:
- `mount_dfs`: If given, then it makes a distributed JuiceFS filesystem available for the packages running on this infrastructure. The value of this field is the endpoint where the DFS may be reached (as a `redis://<address>` URL). Note that this address is used from within the cluster, so don't use `localhost`.

Finally, there is also a to-be-used field that is accepted by the parser but not yet used by the code:
- `proxy_address`: The address of the Bridging Function Chain to route all data through. Will be used by Brane to provide configurable network security and policy enforcement.

With all of those in mind, an example of a typical `local` infrastructure looks as follows:
```yaml
locations:
  # The name of the Kubernetes infrastructure
  kube:
    # It's a Kubernetes cluster
    kind: kube

    # The endpoint of the remote cluster. Replace this with the relevant address.
    # Note: is relative to containers (so localhost won't work!!)
    address: job_cluster.com:6443

    # The namespace where brane jobs will be ran.
    # Needn't be the same as any other namespace, but should exist on the cluster and be accessible by the account used by Brane.
    namespace: brane

    # The endpoint of the Docker registry. Replace with the address of the node (or cluster) where the control plane is running.
    # Note: is relative to containers (so localhost won't work!!)
    registry: "control_node.com:50050"

    # The endpoint of the brane-clb service. This address should point to the node (or cluster) where the control plane is running.
    # Note: is relative to containers (so localhost won't work!!)
    callback_to: "http://control_node.com:50052"

    # The endpoint for the distributed filesystem mount. This address should point to the node (or cluster) where the control plane is running.
    # Note: is relative to containers (so localhost won't work!!)
    mount_dfs: "redis://control_node.com"

    # Provides the credentials for accessing the cluster.
    # The credentials are provided using a Kubernetes config. Check this (https://computingforgeeks.com/restrict-kubernetes-service-account-users-to-a-namespace-with-rbac/) tutorial to see how to setup one that only accesses a particular namespace.
    credentials:
      mechanism: config
      # Note: this refers to an entry in `secrets.yml` called 'k8s-config'. You should add the generated config there (since it contains sensitive tokens and certificates).
      # Also note: the secrets file only accepts base64-encoded stuff, so be sure to encode it like that first.
      file: s$k8s-config
```
By pure chance, this is the 'quick start' file when deploying Brane as a distributed deployment. Remember to change the empty address placeholders in the file before using it.

It may be found under `contrib/config/infra-kube.yml`.
