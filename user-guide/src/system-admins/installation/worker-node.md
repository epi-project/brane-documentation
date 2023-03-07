# Worker node
Before you follow the steps in this chapter, we assume you have installed the required [dependencies](./dependencies.md) and installed [`branectl`](./branectl.md), as discussed in the previous two chapters.

If you did, then you are ready to install a worker node. This chapter will explain you how to do that.


## Obtaining images
Just as with `branectl` itself, there are two ways of obtaining the Docker images: downloading them from the repository or compiling them. Note, however, that multiple files should be downloaded; and to aid with this, the `branectl` executable can be used to automate the downloading process for you.

> <img src="../../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> In the future, a third option might be to download the standard images from [DockerHub](https://hub.docker.com/). However, due to the experimental nature of the framework, the images are not yet published. Instead, rely on `branectl` to make the process easy for you.


### Downloading prebuilt images
The recommended way to download the Brane images is to use `branectl`. These will download the images to `.tar` files, which can be send around at your leisure.

Run the following command to download the Brane service images for a worker node:
```bash
# Download the images
branectl download services worker -f
```
(the `-f` will automatically create missing directories for the target output path)

Once these complete successfully, you should have the images for the worker node in the directory `target/release`. While this path may be changed, it is recommended to stick to the default to make the commands in subsequent sections easier.

> <img src="../../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> By default, `branectl` will download the version for which it was compiled. However, you can change this with the `--version` option:
> ```bash
> branectl download services worker -f --version 1.0.0
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
cd ./brane && ./make.py worker-instance

# Run the compilation in debug mode (note the '--dev')
cd ./brane && ./make.py worker-instance --dev
```

The `make.py` script will handle the rest, compiling the Docker images to the `target/release` directory for release mode, and `target/debug` for the debug mode.


## Generating configuration
Once you have downloaded the images, it is time to setup the configuration files for the node. These files determine the type of node, as well as any of the node's properties and network specifications.

For a worker node, this means generating the following files:
- A node file (`node.yml`), which will contain the node-specific configuration like service names, ports, file locations, etc.;
- A backend file (`backend.yml`), which will define how the worker node connects to which backend that will actually execute the tasks; and
- A policy file (`policies.yml`), which will define which datasets may be shared with who and which containers may be executed.

All three of these can be generated with `branectl` for convenience.

> <img src="../../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> The `policies.yml` file is temporary. As soon as a more complex Checker-service is added to the framework, it will deal with policies instead of the simple rule-based file we have now. Most certainly, it will have its own, more complex way of being configured.

To do so, we will first generate a `backend.yml` file. This will define how the worker node can connect to the infrastructure that will actually execute incoming containers. Multiple backend types are possible (see the [series of chapters on it](../backends/introduction.md)), but by default, the configuration assumes that work will be executed on the local machine's Docker daemon.

Thus, to generate such a `backend.yml` file, you can use the following command:
```bash
branectl generate backend -f -p ./config/backend.yml local
```

> <img src="../../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> While the `-f` flag (`--fix-dirs`, fix missing directories) and the `-p` option (`--path`, path of generated file) are not required, you will typically use these to make your life easier down the road. See the `branectl generate node` command below to find out why.

Running this command will generate the file `./config/backend.yml` for you, with default settings for how to connect to the local daemon. If you want to change these, you can simply use more options and flags in the tool itself (see the [`branectl` documentation](TODO) or the builtin `branectl generate backend --help`), or change the file manually (see the [`backend.yml` documentation](TODO)).

Then, we will generate the `policies.yml` file. This is done with a similar command:
```bash
branectl generate policy -f -p ./config/policies.yml
```
Note that the default policy file denies all dataset requests and incoming tasks. It is thus very recommended to manually add some rules yourself; see the [`policies.yml` documentation](TODO).

> <img src="../../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> You can also specify `-a` or `--allow-all` to generate a file that, by default, will allow everything instead of denying it. However, note that doing so is strongly discouraged in production environments; only do so in testing environments.

Next up, it is time to generate the `node.yml` file. We do this file last, because it defines where to find all of the other files can be found. While you can manually specify where each file can be found when generating the `node.yml`, you can generally make your life easier by providing them at the default locations. For the central node, the default locations are according to the following file structure:
```
<current dir>
├ config
│ ├ certs
│ │ └ <domain certs>
│ └ infra.yml
└ node.yml
```

You already generated the `infra.yml` file, and the `node.yml` file is the file we will generate next. The `config/certs` directory will be used to store the certificates for each of the domains; we will do that in the [following section](#TODO).

Assuming that you have the infrastructure file stored as `config/infra.yml`, the following command can be used to create a `node.yml` for a central node:
```bash
branectl generate node -f central
```

Here, the `-f` flag will make sure that any of the missing directories (e.g., `config/certs`) will be generated automatically.

Once again, you can change many of the properties in the `node.yml` file by specifying additional command-line options (see the [`branectl` documentation](TODO) or the builtin `branectl generate infra --help`) or by changing the file manually (see the [`node.yml` documentation](TODO)).

> <img src="../../assets/img/warning.png" alt="warning" width="16" style="margin-top: 3px; margin-bottom: -3px"/> Due to a  [bug](https://github.com/epi-project/brane/issues/27) in one of the framework's dependencies, it cannot handle certificates on IP addresses. To workaround this issue, the `-H` option is provided; it can be used to specify a certain hostname/IP mapping for this node only. Example:
> ```bash
> # We can address '1.2.3.4' with 'bob-domain' now
> branectl generate node -f -H bob-domain:1.2.3.4 central
> ```
> Note that this is local to this domain only; you have to specify this on other nodes as well.


## Generating certificates
