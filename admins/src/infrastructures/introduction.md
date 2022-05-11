# Introduction
In Brane terminology, every domain is defined as an _infrastructure_, which is a single system which can take a job and run it. Because Brane orchestrates over multiple of them, it assumes that each such an infrastructure is located on different networks.

Thus, Brane has to know a few things about the infrastructure:
- The type of the infrastructure (local, Kubernetes, Slurm, etc)
- Where to reach the infrastructure (credentials, infrastructure address, etc)
- How the infrastructure can reach Brane (endpoints of various Brane services)

To do so, Brane defines two files to aid with this: `infra.yml` and `secrets.yml`.


## The `infra.yml` file
The `infra.yml` file, which is also called the Infrastructure file, is used to define each infrastructure that Brane orchestrates over.

To do this, there are several kinds of infrastructure that are supported:
- A `local` infrastructure kind, which schedules new jobs on the same Docker engine where Brane runs (only useable when the control plane is not deployed on a Kubernetes cluster).
- A `vm` infrastructure kind, which mounts a single node over SSH via the [Xenon](https://github.com/xenon-middleware/xenon) middleware. Then, every new job is ran on the node's Docker engine.
- A `kube` infrastructure kind, which launched new jobs on a Kubernetes cluster. This could be the same cluster as where Brane is running (if deployed on a cluster).
- A `slurm` infratsructure kind, which runs new jobs on a distributed compute infrastructure that uses Slurm as management software.

Each of these infrastructure kinds are treated in the next four chapters.


### YAML specification
As the extension suggests, the `infra.yml` file is written in the [YAML](https://yaml.org/) format.

At the toplevel, the `infra.yml` file requires the `locations` key. Then, every nested key defines a new infrastructure with the same name as that key.

Then, which keys are allowed for each infrastructure depends on the kind of infrastructure it represents. This is determined by a `kind` key, which must always be present.

For example, an `infra.yml` with two infrastructures `foo` and `bar` might look as follows:
```yaml
locations:
  # The "foo" infrastructure, which runs jobs on the local Docker daemon
  foo:
    kind: local
    ...

  # The "bar" infrastructure, which runs jobs on a Kubernetes cluster
  bar:
    kind: kube
    ...
```

Which fields are expected per infrastructure kind is also treated in the subsequent chapters.


## The `secrets.yml` file
Sometimes, an infrastructure might need sensitive information to connect to it (like credentials). However, ee don't want to write these in the `infra.yml` directly, as this prevents us from sharing it with others.

To solve this issue, Brane defines a `secrets.yml` file, which is the place to put these kind of sensitive credentials or other information. Then, in the main `infra.yml` file, you can make a reference to the secrets file and Brane will pull the required information from that file instead.


### YAML specification
The `secrets.yml` file is also written in YAML, and it simply defines a key-value mapping as its contents. This means that every toplevel key should map to a string or other value, which will then can then be referenced under that name in the `infra.yml` file.

Note, though, that _all contents should be encoded as base64_. This is done to be sure that any of your file's contents do not interfere with `secrets.yml` YAML.
> Note: this will likely change in the future. Be prepared to change your secrets.yml contents to non-Base64 soon :)

For example, if we want to define two secrets `foo` with `"A secret message!"` and `bar` with `"Another secret message!"`, `secrets.yml` looks as follows:
```yaml
# Stores the base64-encoded version of "A secret message!"
foo: QSBzZWNyZXQgbWVzc2FnZSE=

# Stores the base64-encoded version of "Another secret message!" but using YAML's alternative syntax
bar: |
  QW5vdGhlciBzZWNyZXQgbWVzc2FnZSE=
```

Once defined, you can reference the specific secret in the `infra.yml` file by writing `s$` and then the name of the key:
```yaml
locations:
  foo:
    ...
    credentials:
      mechanism: ssh-password
      username: user1
      # Uses secret 'foo'
      password: s$foo
    ...
```


## Next
In the [next four chapters](./local.md), we discuss each of the four infrastructure kinds that Brane currently supports. You can simply refer to the one which you plan to add.

If you're done defining frameworks, you can launch your framework with the defined infrastructures. To do so, go to the [Deployment](../installation/deployment.md) chapter.
