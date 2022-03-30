# Kubernetes
One of the scheduling systems that Brane supports is [Kubernetes](https://kubernetes.io).

Because Kubernetes supports remote access, Brane expects you to provide a Kubernetes configuration file which describes where, how and with what credentials / certificates to access your cluster. The framework will then use the [`kube`](https://crates.io/crates/kube)-crate to act as a client and connect to your cluster.

To configure your cluster for Brane access, we recommend you create a new namespace for Brane to use exclusively. You can then limit Brane access to your cluster by creating a service accounts that has full access, but only on that namespace.

A good tutorial for doing this can be found [here](https://computingforgeeks.com/restrict-kubernetes-service-account-users-to-a-namespace-with-rbac/).


## Adding the infrastructure
Once your cluster is prepared, Brane has to be configured to know of your infrastructure and to know how it can access it.

Do so, add a new infrastructure to your `infra.yml` file that has the `kube`-kind.

An infrastructure of the `kube`-kind supports the following fields:
- `address`: The address of your Kubernetes cluster. Note, however, that this field is ignored, as your Kubernetes config already contains this information.
- `callback_to`: The address and port (as `address:port`) of the Brane callback service location (The `brane-clb` container). This is the service that will receive status updates and result of jobs and pass them back to the control plane.
- `namespace`: The Kubernetes namespace to run the jobs in.
- `registry`: The address of the instance registry. This will almost always be the `address:port` of the registry belonging to the Brane instance.
- `credentials`: With the `config` mechanism, a path can be specified to the Kubernetes config that is used to login to your cluster. Other credential mechanism aren't supported for the Kubernetes cluster.
- `proxy_address` (optional): The address of a proxy to send all the job's communication through. This is particularly useful for use with the Bridging Functions.
- `mount_dfs` (optional): The address of a shared (JuiceFS) filesystem to mount for the jobs. This allows jobs to write intermediate results to that filesystem, which can be used by subsequent jobs.

For example, a `kube` infrastructure might look as follows:
```yaml
  ...

  example-infrstructure:
    kind: kube
    address: mycluster.com:6443
    callback_to: "http://control-plane.com:50052"
    namespace: brane
    registry: "control-plane.com:5000"
    credentials:
      mechanism: config
      path: ./kubernetes-config.yml

  ...
```

Once the infrastructure is added, it is important to restart the Brane instance so the file is re-distributed across all services.
