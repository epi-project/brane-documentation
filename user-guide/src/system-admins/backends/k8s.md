# Kubernetes infrastructures
One of the supported infrastructure types that Brane may orchestrate over is [Kubernetes](https://kubernetes.io).

Brane is essentially build around containers, each of which represents a package with pieces of code that may be orchestrated in a workflow. Thus, connecting Brane to a system like Kubernetes is an easy choice, and requires preparation from the perspective of the system engineer in charge of the cluster.

Essentially, all that has to be done is provide Brane with the proper credentials to connect to the cluster, and prepare a separate namespace.

> <img src="../assets/img/info.png" alt="drawing" width="16" style="margin-top: 3px; margin-bottom: -3px"/> For now, Brane containers do not yet need any additional support beyond access to a network so they may reach the Brane control plane. Any distibuted file systems are implemented in the container as a [Redis](https://redis.io/) networked filesystem.


## Prepare the cluster
First, you should create a namespace for Brane to run in. While you can also technically let it run in the `default` namespace, to avoid any naming conflicts we highly recommend to create a namespace. For example, run:
```bash
kubectl create namespace brane
```
to create a namespace called `brane`.

Then, the second step is to provide Brane with a Kubernetes config file that contains the cluster location and credentials to login.

Because providing the administrator config is very bad practise, it's better to create a new account that only has access to Brane's dedicated namespace. To do so, follow the steps detailled in [this](https://computingforgeeks.com/restrict-kubernetes-service-account-users-to-a-namespace-with-rbac/) tutorial.

That said, any configuration file would do, as long as Brane can launch Jobs and PODs in the namespace where it is supposed to run.


## Information requirements
To add your infrastructure to the Brane instance, the control plane will require the following information:
- The address of your Kubernetes control plane (with port)
- A configuration file with the proper tokens and certificates so Brane may access its namespace

And that's it. Because Brane simply submits contains to the cluster, everything else is already supported by a standard Kubernetes installation.
