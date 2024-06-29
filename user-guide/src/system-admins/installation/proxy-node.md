# Proxy node
Before you follow the steps in this chapter, we assume you have installed the required [dependencies](./dependencies.md) and installed [`branectl`](./branectl.md), as discussed in the previous two chapters.

If you did, then you are ready to install a proxy node. This chapter will explain you how to do that.


## Obtaining images
Just as with `branectl` itself, there are two ways of obtaining the Docker images: downloading them from the repository or compiling them. Note, however, that multiple files should be downloaded; and to aid with this, the `branectl` executable can be used to automate the downloading process for you.

> <img src="../../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> In the future, a third option might be to download the standard images from [DockerHub](https://hub.docker.com/). However, due to the experimental nature of the framework, the images are not yet published. Instead, rely on `branectl` to make the process easy for you.


### Downloading prebuilt images
The recommended way to download the Brane images is to use `branectl`. These will download the images to `.tar` files, which can be send around at your leisure.

Run the following command to download the Brane service images for a worker node:
```bash
# Download the images
branectl download services proxy -f
```
(the `-f` will automatically create missing directories for the target output path)

Once these complete successfully, you should have the images for the worker node in the directory `target/release`. While this path may be changed, it is recommended to stick to the default to make the commands in subsequent sections easier.

> <img src="../../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> By default, `branectl` will download the version for which it was compiled. However, you can change this with the `--version` option:
> ```bash
> branectl download services proxy -f --version 1.0.0
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
cd ./brane && ./make.py proxy-instance

# Run the compilation in debug mode (note the '--dev')
cd ./brane && ./make.py proxy-instance --dev
```

The `make.py` script will handle the rest, compiling the Docker images to the `target/release` directory for release mode, and `target/debug` for the debug mode.


## Generating configuration
Once you have downloaded the images, it is time to setup the configuration files for the node. These files determine the type of node, as well as any of the node's properties and network specifications.

For a worker node, this means generating the following files:
- A proxy file (`proxy.yml`), which describes if any proxying should occur and how; and
- A node file (`node.yml`), which will contain the node-specific configuration like service names, ports, file locations, etc.

All of these can be generated with `branectl` for convenience.

We first generate the `proxy.yml` file. Typically, these can be left to the default settings, and so the following command will do the trick in most situations:
```bash
branectl generate proxy -f -p ./config/proxy.yml
```

A `proxy.yml` file should be available in `./config/proxy.yml` after running this command.

The contents of this file will typically only differ if you have advanced networking requirements. If so, consult the [`branectl` documentation](TODO) or the builtin `branectl generate proxy --help`, or the [`proxy.yml` documentation](../../config/admins/proxy.md).

> <img src="../../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> While the `-f` flag (`--fix-dirs`, fix missing directories) and the `-p` option (`--path`, path of generated file) are not required, you will typically use these to make your life easier down the road. See the `branectl generate node` command below to find out why.

Then we will generate the `node.yml` file. This file is done last, because it itself defines where Brane software may find any of the others.

When generating this file, it is possible to manually specify where to find each of those files. However, in practise, it is more convenient to make sure that the files are at the default locations that the tools expects. The following tree structure displays the default locations for the configuration of a proxy node:
```
<current dir>
├ config
│ ├ certs
│ │ └ <domain certs>
│ └ proxy.yml
└ node.yml
```

The `config/certs` directory will be used to store the certificates for this proxy node and any node it wants to download data from. We will do that in the [following section](#generating-certificates).

Assuming that you have the other configuration files stored at their default locations, the following command can be used to create a `node.yml` for a proxy node:
```bash
branectl generate node -f proxy <HOSTNAME>
```

Here, the `<HOSTNAME>` is the address where any other node may reach the proxy node. Only the hostname will suffice (e.g., `some-domain.com`), but any scheme or path you supply will be automatically stripped away.

The `-f` flag will make sure that any of the missing directories (e.g., `config/certs`) will be generated automatically.

For example, we can generate a `node.yml` file for a proxy found at `192.0.2.2`:
```bash
branectl generate node -f proxy 192.0.2.2
```

Once again, you can change many of the properties in the `node.yml` file by specifying additional command-line options (see the [`branectl` documentation](TODO) or the builtin `branectl generate node --help`) or by changing the file manually (see the [`node.yml` documentation](../../config/admins/node.md)).

> <img src="../../assets/img/warning.png" alt="warning" width="16" style="margin-top: 3px; margin-bottom: -3px"/> Due to a  [bug](https://github.com/epi-project/brane/issues/27) in one of the framework's dependencies, it cannot handle certificates on IP addresses. To workaround this issue, the `-H` option is provided; it can be used to specify a certain hostname/IP mapping for this node only. Example:
> ```bash
> # We can address '192.0.2.2' with 'some-domain' now
> branectl generate node -f -H some-domain:192.0.2.2 proxy bob-domain.com
> ```
> Note that this is local to this domain only; you have to specify this on other nodes as well. For more information, see the [`node.yml` documentation](../../config/admins/node.md).


## Generating certificates
In contrast to setting up a control node, a proxy node will have to strongly identify itself to prove to other nodes who it is. This is relevant, because worker nodes may want to download data from one another through their proxy nodes; and if this dataset is private, then the other domains likely won't share it unless they know who they are talking to.

In Brane, the identity of domains is proven by the use of [X.509 certificates](https://en.wikipedia.org/wiki/X.509). Thus, before you can start your proxy node, we will have to generate some certificates.


### Server-side certificates
Every proxy node is required to have at least a certificate authority (CA) certificate and a server certificate. The first is used as the "authority" of the domain, which is used to sign other certificates such that the proxy can see that it has been signed by itself in the past. The latter, in contrast, is used to provide the identity of the proxy in case it plays the role of a server (some other domain connects to us and requests a dataset).

Once again, we can use the power of `branectl` to generate both of these certificates for us. Use the following command to generate both a certificate autority and server certificate:
```bash
branectl generate certs -f -p ./config/certs server <LOCATION_ID> -H <HOSTNAME>
```
where `<LOCATION_ID>` is the identifier of the proxy node (the one configured in the `node.yml` file), and `<HOSTNAME>` is the hostname that other domains can connect to this domain to.

You can omit the `-H <HOSTNAME>` flag to default the hostname to be the same as the `<LOCATION_ID>`. This is useful where you've given manual host mappings when generating the `node.yml` file (i.e., the `-H` option there).

For example, to generate certificates for the domain `amy` that lives at `amy-proxy-node.com`:
```bash
branectl generate certs -f -p ./config/certs server amy -H amy-proxy-node.com
```
This should generate multiple files in the `./config/certs` directory, chief of which are `ca.pem` and `server.pem`.

> <img src="../../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> Certificate generation is done using [cfssl](https://github.com/cloudflare/cfssl), which is dynamically downloaded by `branectl`. The checksum of the downloaded file is asserted, and if you ever see a checksum-related error, then you might be dealing with a fake binary that is being downloaded under a real address. In that case, tread with care.

When the certificates are generated, be sure to share `ca.pem` with the central node. If you are also adminstrating that node, see [here](./control-node.md#adding-certificates) for instructions on what to do with it.


### Client-side certificates
The previous certificates only authenticate a server to a client; not the other way around. That is where the client certificates come into play.

The power of client certificates come from the fact that they are signed using the certificate authority of the domain to which they want to authenticate. In other words, the domain has to "approve" that a certain user exists by creating a certificate for them, and then sending it over.

Note, however, that currently, Brane does not use any hostnames or IPs embedded in the client certificate. This means that anyone with the client certificate can obtain access to the domain as if they were the user for which it was issued. Treat the certificates with care, and be sure that the client is also careful with the certificate.

> <img src="../../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> If a certificate is leaked or compromised, don't worry; the certificate only proves the identity of a user. What kind of rights that user has can be separately determined (see the chapter series for [policy experts](../../policy-experts/introduction.md)), and so you can simply withdraw any rights that user has when it happens.

To generate a client certificate, its easiest to navigate to the `./config/certs` directory where you generate the server certificates. Then, you can run:
```bash
branectl generate certs client <LOCATION_ID> -H <HOSTNAME> -f -p ./client-certs
```
Note, that the `<LOCATION_ID>` is now the ID of the proxy _for which you are generating_ the certificate, and `<HOSTNAME>` is their address. Similarly to server certificates, you can omit `-H <HOSTNAME>` to default to the `<LOCATION_ID>`.

> <img src="../../assets/img/warning.png" alt="warning" width="16" style="margin-top: 3px; margin-bottom: -3px"/> Note the `-f` and `-p` options. These are optional, and work together to redirect the output of the commands to a nested folder called `client-certs`. This is however very recommendable, since running this command without that flag in the server certificates folder will accidentally clear the `ca.pem` file, rendering the rest of the certificates useless.

For example, contuining the example in the previous subsection, we now generate a client certificate for `bob` at `bobs-emporium.com`:
```bash
branectl generate certs client bob -H 192.0.2.2
```

Once the client certificates are generated, you can share the `ca.pem` and `client-id.pem` files with the client who intends to connect to this node.


### Adding client certificates of other domains
If your proxy node needs to download data from other nodes, you will have to add the client certificates they generated to your configuration.

The procedure to do so is identical as for central nodes. For every pair of a `ca.pem` and `client-id.pem` certificates you want to:
1. Create a directory with that domain's name in the `certs` directory (for the example, you would create a directory named `certs/amy` for a domain named `amy`)
2. Move the certificates to that folder.

At runtime, whenever your proxy node will need to download a dataset from another node, it will read the certificates in that node's folder if they exist to authenticate itself.


## Launching the instance
Finally, now that you have the images and the configuration files, it's time to start the instance.

We assume that you have installed your images to `target/release`. If you have built your images in development mode, however, they will be in `target/debug`; see the box below for the command then.

This can be done with one `branectl` command:
```bash
branectl start proxy
```

This will launch the services in the local Docker daemon, which completes the setup!

> <img src="../../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> The command above assumes default locations for the images (`./target/release`) and for the `node.yml` file (`./node.yml`). If you use non-default locations, however, you can use the following flags:
> - Use `-n` or `--node` to specify another location for the `node.yml` file:
>   ```bash
>   branectl -n <PATH TO NODE YML> start proxy
>   ```
>   It will define the rest of the configuration locations.
> - If you have installed all images to another folder than `./target/release` (e.g., `./target/debug`), you can use the quick option `--image-dir` to change the folders. Specifically:
>   ```bash
>   branectl start --image-dir "./target/debug" proxy
>   ```
> - You can also specify the location of each image individually. To see how, refer to the [`branectl` documentation](TODO) or the builtin `branectl start --help`.


## Next
Congratulations, you have configured and setup a Brane proxy node!

If you are in charge of more proxy nodes, you can repeat the steps in this chapter to add more. If you are also charged with setting up a control node or worker node, you can check the [control node chapter](./control-node.md) or the [worker node chapter](./worker-node.md), respectively, for node specific instructions.

Otherwise, you can move on to other work! If you want to test your node like a normal user, you can go to the documentation for [Software Engineers](../../software-engineers/introduction.md) or [Scientists](../../scientists/introduction.md).
