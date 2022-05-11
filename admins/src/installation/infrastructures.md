# Defining infrastructures
To run any kind of job, Brane needs are least one compute domain to run them on. In Brane terminology, each such a domain is called an _infrastructure_, which is essentially what Brane orchestrates over.


## Quick start
If you're eager to begin, we provide two files that are pre-prepared to configure a simple infrastructure for testing or development purposes:
- `contrib/config/infra-local.yml`: This file defines a [`local`](../infrastructures/local.md) infrastructure to run jobs on. It shouldn't need any adaptation, but can just be copy/pasted to the `config` directory in the repository root. Note, though, that this infrastructure kind will not work if you deploy Brane on a distributed Kubernetes cluster (see the [next chapter](./deployment.md)).
- `contrib/config/infra-kube.yml`: This defines a [`kube`](../infrastructures/kube.md) infrastructure to run jobs on. This is most convenient to use as a quick-start if you're deploying Brane on a distributed Kubernetes cluster, because you may then use that same cluster to run jobs on.
  > <img src="../assets/img/info.png" alt="drawing" width="16" style="margin-top: 3px; margin-bottom: -3px"/> This file _does_ require some adaption to your specific Kubernetes cluster. Its comments should be enough, but you can check the dedicated [documentation page](../infrastructures/kube.md) for more information.


## Other infrastructures
If you want to better understand what you're implementing, or if you want to implement other infrastructure kinds, take a look at the [dedicated series of chapters](../infrastructures/introduction.md) on this topic.

Once you have your infrastructure(s) defined, you can move to the [next chapter](./deployment.md) to deploy the instance.
