# Control node
Before you follow the steps in this chapter, we assume you have installed the required [dependencies](./dependencies.md) and installed [`branectl`](./branectl.md), as discussed in the previous two chapters.

If you did, then you are ready to install the control node. This chapter will explain you how to do that.


## Obtaining images
Just as with `branectl` itself, there are two ways of obtaining the Docker images and related resources: downloading them from the repository or compiling them. Note, however, that multiple files should be downloaded; and to aid with this, the `branectl` executable can be used to automate the downloading process for you.

> <img src="../../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> In the future, a third option might be to download the standard images from [DockerHub](https://hub.docker.com/). However, due to the experimental nature of the framework, the images are not yet published. Instead, rely on `branectl` to make the process easy for you.


### Downloading prebuilt images
The recommended way to download the Brane images is to use `branectl`. These will download the images to `.tar` files, which can be send around at your leisure; and, if you will be deploying the framework on a device where internet is limited or restricted, you can also use it to download Brane's auxillary images ([ScyllaDB](https://www.scylladb.com/)).

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
The other way to obtain the images is to compile them yourself. If you want to do so, refer to the [compilation instructions](/specification/development/compilation.html) over at the [Brane: A Specification](/specification)-book for instructions.


## Generating configuration
Once you have downloaded the images, it is time to setup the configuration files for the node. These files determine the type of node, as well as any of the node's properties and network specifications.

For a control node, this means generating the following files:
- An infrastructure file (`infra.yml`), which will determine the worker nodes available in the instance;
- A proxy file (`proxy.yml`), which describes if any proxying should occur and how; and
- A node file (`node.yml`), which will contain the node-specific configuration like service names, ports, file locations, etc.

All of these can be generated with `branectl` for convenience.

First, we generate the `infra.yml` file. This can be done using the following command:
```bash
branectl generate infra <ID>:<ADDR> ...
```
Here, multiple `<ID>:<ADDR>` pairs can be given, one per worker node that is available to the instance. In such a pair, the `<ID>` is the location ID of that domain (which must be the same as indicated in that node; see the chapter for [setting up worker nodes](./worker-node.md)), and the `<ADDR>` is the address (IP or hostname) where that domain is available.

For example, suppose that we want to instantiate a central node for a Brane instance with two worker nodes: one called `amy`, at `amy-worker-node.com`, and one called `bob`, at `1.2.3.4`. We would generate an `infra.yml` as follows:
```bash
branectl generate infra -f -p ./config/infra.yml amy:amy-worker-node.com bob:1.2.3.4
```

Running this command will generate the file `./config/infra.yml` for you, with default settings for each domain. If you want to change these, you can simply use more options and flags in the tool itself (see the [`branectl` documentation](../../config/admins/backend.md) or the builtin `branectl generate infra --help`), or change the file manually (see the [`infra.yml` documentation](../../config/admins/infra.md)).

> <img src="../../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> While the `-f` flag (fix missing directories) and the `-p` option (path of generated file) are not required, you will typically use these to make your life easier down the road. See the `branectl generate node` command below to find out why.

Next, we will generate the `proxy.yml` file. Typically, this configuration can be left to the default settings, and so the following command will do the trick in most situations:
```bash
branectl generate proxy -f -p ./config/proxy.yml
```

A `proxy.yml` file should be available in `./config/proxy.yml` after running this command.

The contents of this file will typically only differ if you have advanced networking requirements. If so, consult the [`branectl` documentation](TODO) or the builtin `branectl generate proxy --help`, or the [`proxy.yml` documentation](../../config/admins/proxy.md).

> <img src="../../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> This file may be skipped if you are setting up an external proxy node for this node. See the [chapter on proxy nodes](./proxy-node.md) for more information.

Then we will generate the final file, the `node.yml` file. This file is done last, because it itself defines where the BRANE software may find any of the other configuration files.

When generating this file, it is possible to manually specify where to find each of those files. However, in practise, it is more convenient to make sure that the files are at the default locations that the tools expects. The following tree structure displays the default locations for the configuration of a central node:
```
<current dir>
├ config
│ ├ certs
│ │ └ <domain certs>
│ ├ infra.yml
│ └ proxy.yml
└ node.yml
```

The `config/certs` directory will be used to store the certificates for each of the domains; we will do that in the [following section](#adding-certificates).

Assuming that you have the files stored as above, the following command can be used to create a `node.yml` for a central node:
```bash
branectl generate node -f central <HOSTNAME>
```

Here, `<HOSTNAME>` is the address where any worker node may reach the central node. Only the hostname will suffice (e.g., `some-domain.com`), but any scheme or path you supply will be automatically stripped away.

The `-f` flag will make sure that any of the missing directories (e.g., `config/certs`) will be generated automatically.

Once again, you can change many of the properties in the `node.yml` file by specifying additional command-line options (see the [`branectl` documentation](TODO) or the builtin `branectl generate node --help`) or by changing the file manually (see the [`node.yml` documentation](../../config/admins/node.md)).

> <img src="../../assets/img/warning.png" alt="warning" width="16" style="margin-top: 3px; margin-bottom: -3px"/> Due to a  [bug](https://github.com/epi-project/brane/issues/27) in one of the framework's dependencies, it cannot handle certificates on IP addresses. To workaround this issue, the `-H` option is provided; it can be used to specify a certain hostname/IP mapping for this node only. Example:
> ```bash
> # We can address '1.2.3.4' with 'bob-domain' now
> branectl generate node -f -H bob-domain:1.2.3.4 central central-domain.com
> ```
> Note that this is local to this domain only; you have to specify this on other nodes as well. For more information, see the [`node.yml` documentation](../../config/admins/node.md).
> > <img src="../../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> Since the above is highly localized, it can be abused to do node-specific routing, by assigning the same hostname to different IPs on different machines. Definitely entering "hacky" territory here, though...


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
> - If you have installed all images to another folder than `./target/release` (e.g., `./target/debug`), you can use the quick option `--image-dir` to change the folders. Specifically:
>   ```bash
>   branectl start --image-dir "./target/debug" central
>   ```
> - If you want to use pre-downloaded image for the auxillary services (`aux-scylla`) that are in the same folder as the one indicated by `--image-dir`, you can specify `--local-aux` to use the folder version instead:
>   ```bash
>   branectl start central --local-aux
>   ```
> - You can also specify the location of each image individually. To see how, refer to the [`branectl` documentation](TODO) or the builtin `branectl start --help`.

> <img src="../../assets/img/warning.png" alt="warning" width="16" style="margin-top: 3px; margin-bottom: -3px"/> Note that the Scylla database this command launches might need a minute to come online, even though its container already reports ready. Thus, before you can use your instance, wait until `docker ps` shows all Brane containers running (in particular the `brane-api` service will crash until the Scylla service is done). You can use `watch docker ps` if you don't want to re-call the command yourself.


## Next
Congratulations, you have configured and setup a Brane control node!

Depending on which domains you are in charge of, you may also have to setup one or more [worker nodes](./worker-node.md) or [proxy nodes](./proxy-node.md). Note, though, that these are written to be used on their own, so parts of it overlap with this chapter.

Otherwise, you can move on to other work! If you want to test your instance like a normal user, you can go to the documentation for [Software Engineers](../../software-engineers/introduction.md) or [Scientists](../../scientists/introduction.md).
