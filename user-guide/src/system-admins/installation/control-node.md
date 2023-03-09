# Control node
Before you follow the steps in this chapter, we assume you have installed the required [dependencies](./dependencies.md) and installed [`branectl`](./branectl.md), as discussed in the previous two chapters.

If you did, then you are ready to install the control node. This chapter will explain you how to do that.


## Obtaining images
Just as with `branectl` itself, there are two ways of obtaining the Docker images and related resources: downloading them from the repository or compiling them. Note, however, that multiple files should be downloaded; and to aid with this, the `branectl` executable can be used to automate the downloading process for you.

> <img src="../../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> In the future, a third option might be to download the standard images from [DockerHub](https://hub.docker.com/). However, due to the experimental nature of the framework, the images are not yet published. Instead, rely on `branectl` to make the process easy for you.


### Downloading prebuilt images
The recommended way to download the Brane images is to use `branectl`. These will download the images to `.tar` files, which can be send around at your leisure; and, if you will be deploying the framework on a device where internet is limited or restricted, you can also use it to download Brane's auxillary images ([ScyllaDB](https://www.scylladb.com/) and [Kafka](https://kafka.apache.org/) ([zookeeper](https://kafka.apache.org/quickstart))).

Run the following command to download the Brane services themselves:
```bash
# Download the images
branectl download services central -f
```

And to download the auxillary images (run in addition to the previous command):
```bash
branectl download services auxillary -f
```
(the `-f` will automatically create missing directories for the target output path)

Once these complete successfully, you should have the images for the control node in the directory `target/release`. While this path may be changed, it is recommended to stick to the default to make the commands in subsequent sections easier.

> <img src="../../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> By default, `branectl` will download the version for which it was compiled. However, you can change this with the `--version` option:
> ```bash
> # You should change this on all download commands
> branectl download services central --version 1.0.0
> ```
> 
> Note, however, that not every Brane version may have the same services or the same method of downloading, and so this option may fail. Download the `branectl` for the desired version instead for a more reliable experience.


### Compiling the images
The other way to obtain the images is to compile them yourself.

Make sure that you have installed the additional [compilation dependencies](./dependencies.md#compilation-dependencies) before continuing (and make sure you match the mode you choose below).

There are two modes of compilation:
- In _release_ mode, you will compile the framework directly in the containers that will be using it. This is the recommended method in most cases.
- In _debug_ or _development_ mode, you will compile the framework with debug symbols, additional debug prints and outside of a container which optimizes repeated recompilation. Additionally, it also statically links GLIBC so the resulting binaries are very portable. This method should only be preferred if you are actively developing the framework.

> <img src="../../assets/img/warning.png" alt="warning" width="16" style="margin-top: 3px; margin-bottom: -3px"/> Before you consider installing in debug mode, be aware that the resulting images will be very large (due to the debug symbols and the statically linked GLIBC). Moreover, the build cache kept in between builds is also _huge_. Make sure you have enough space on your machine available (~10GB) before continuing, and regularly clean the cache yourself to avoid it growing boundlessly.

Regardless of which one you choose, though, clone the repository first:
```bash
# Will clone to './brane'
git clone https://github.com/epi-project/brane
```

Navigate to the source directory, and then use the `make.py` script to compile `branectl`:
```bash
# Run the compilation in release mode
cd ./brane && ./make.py instance

# Run the compilation in debug mode (note the '--dev')
cd ./brane && ./make.py instance --dev
```

The `make.py` script will handle the rest, compiling the Docker images to the `target/release` directory for release mode, and `target/debug` for the debug mode.


## Generating configuration
Once you have downloaded the images, it is time to setup the configuration files for the node. These files determine the type of node, as well as any of the node's properties and network specifications.

For a control node, this means generating the following files:
- A node file (`node.yml`), which will contain the node-specific configuration like service names, ports, file locations, etc.; and
- An infrastructure file (`infra.yml`), which will determine the worker nodes available in the instance.

Both of these can be generated with `branectl` for convenience.

To do so, first generate the `infra.yml` file. This can be done using the following command:
```bash
branectl generate infra <ID>:<ADDR> ...
```
Here, multiple `<ID>:<ADDR>` pairs can be given, one per worker node that is available to the instance. In such a pair, the `<ID>` is the location ID of that domain (which must be the same as indicated in that node; see the chapter for [setting up worker nodes](./worker-node.md)), and the `<ADDR>` is the address (IP or hostname) where that domain is available.

For example, suppose that we want to instantiate a central node for a Brane instance with two worker nodes: one called `amy`, at `amy-worker-node.com`, and one called `bob`, at `1.2.3.4`. We would generate an `infra.yml` as follows:
```bash
branectl generate infra -f -p ./config/infra.yml amy:amy-worker-node.com bob:1.2.3.4
```

> <img src="../../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> While the `-f` flag (fix missing directories) and the `-p` option (path of generated file) are not required, you will typically use these to make your life easier down the road. See the `branectl generate node` command below to find out why.

Running this command will generate the file `./config/infra.yml` for you, with default settings for each domain. If you want to change these, you can simply use more options and flags in the tool itself (see the [`branectl` documentation](TODO) or the builtin `branectl generate infra --help`), or change the file manually (see the [`infra.yml` documentation](TODO)).

Then we will generate the final file, the `node.yml` file. This file is done last, because it itself defines where the node services and the `branectl` tool may find any of the others.

When generating this file, it is possible to manually specify where to find each of those files. However, in practise, it is more convenient to make sure that the files are at the default locations that the tools expects. The following tree structure displays the default locations for the configuration of a central node:
```
<current dir>
├ config
│ ├ certs
│ │ └ <domain certs>
│ └ infra.yml
└ node.yml
```

The `config/certs` directory will be used to store the certificates for each of the domains; we will do that in the [following section](#adding-certificates).

Assuming that you have the infrastructure file stored as `config/infra.yml`, the following command can be used to create a `node.yml` for a central node:
```bash
branectl generate node -f central <HOSTNAME>
```

Here, `<HOSTNAME>` is the address where any worker node may reach the central node. Only the hostname will suffice (e.g., `some-domain.com`), but any scheme or path you supply will be automatically stripped away.

The `-f` flag will make sure that any of the missing directories (e.g., `config/certs`) will be generated automatically.

Once again, you can change many of the properties in the `node.yml` file by specifying additional command-line options (see the [`branectl` documentation](TODO) or the builtin `branectl generate node --help`) or by changing the file manually (see the [`node.yml` documentation](TODO)).

> <img src="../../assets/img/warning.png" alt="warning" width="16" style="margin-top: 3px; margin-bottom: -3px"/> Due to a  [bug](https://github.com/epi-project/brane/issues/27) in one of the framework's dependencies, it cannot handle certificates on IP addresses. To workaround this issue, the `-H` option is provided; it can be used to specify a certain hostname/IP mapping for this node only. Example:
> ```bash
> # We can address '1.2.3.4' with 'bob-domain' now
> branectl generate node -f -H bob-domain:1.2.3.4 central
> ```
> Note that this is local to this domain only; you have to specify this on other nodes as well.


## Adding certificates
Before the framework can be fully used, the central node will need the public certificates of the worker nodes to be able to verify their identity during connection. Since we assume Brane may be running in a decentralized and shielded environment, the easiest is to add the domain's certificates to the `config/certs` directory.

To do so, [obtain the public certificate](./worker-node.md#generating-certificates) of each of the workers in your instance. Then, navigate to the `config/certs` directory (or wherever you pointed it to in `node.yml`), and do the following for each certificate:
1. Create a directory with that domain's name (for the example above, you would create a directory named `amy` for that domain)
2. Move the certificate to that folder and call it `ca.pem`.

At runtime, the Brane services will look for the peer domain's identity by looking up the folder with their name in it. Thus, make sure that every worker in your system has a name that you filesystem can represent.


## Launching the instance
Finally, now that you have the images and the configuration files, it's time to start the instance.

We assume that you have installed your images to `target/release`. If you have built your images in development mode, however, they will be in `target/debug`; see the box below for the command then.

This can be done with one `branectl` command:
```bash
branectl start central
```

This will launch the services in the local Docker daemon, which completes the setup!

> <img src="../../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> The command above assumes default locations for the images (`./target/release`) and for the `node.yml` file (`./node.yml`). If you use non-default locations, however, you can use the following flags:
> - Use `-n` or `--node` to specify another location for the `node.yml` file:
>   ```bash
>   branectl -n <PATH TO NODE YML> start central
>   ```
>   It will define the rest of the configuration locations.
> - If you have installed the images to `./target/debug` instead of `./target/release`, you can use the quick option `--mode` to change the folders. Specifically:
>   ```bash
>   branectl start --mode debug central
>   ```
> - Otherwise, you can also specify the location of each image individually. This must be done for each of the three auxillary images if you use the downloaded version. To see how, refer to the [`branectl` documentation](TODO) or the builtin `branectl --help`.

> <img src="../../assets/img/warning.png" alt="warning" width="16" style="margin-top: 3px; margin-bottom: -3px"/> Note that the underlying Scylla database might need a minute to come online, even though its container already reports ready. Thus, before you can use your instance, wait until `docker ps` shows all Brane containers running (in particular the `brane-api` service will crash until the Scylla service is done). You can use `watch docker ps` if you don't want to re-call the command yourself.


## Next
Congratulations, you have configured and setup a Brane control node!

Depending on which domains you are in charge of, you may also have to setup one or more worker nodes. This is discussed in the [next chapter](./worker-node.md). Note, though, that it is written to be used on its own, so parts of it overlap with this chapter.

Otherwise, you can move on to other work! If you want to test your instance like a normal user, you can go to the documentation for [Software Engineers](../../software-engineers/introduction.md) or [Scientists](../../scientists/introduction.md).
