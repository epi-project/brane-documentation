# Control node
Before you follow the steps in this chapter, we assume you have installed the required [dependencies](./dependencies.md) and installed [`branectl`](./branectl.md), as discussed in the previous two chapters.

If you did, then you are ready to install the control node. This chapter will explain you how to do that.


## Obtaining images
Just as with `branectl` itself, there are two ways of obtaining the Docker images and related resources: downloading them from the repository or compiling them. Note, however, that multiple files should be downloaded; and to aid with this, the `branectl` executable can be used to automate the downloading process for you.

> <img src="../../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> In the future, a third option might be to download the standard images from [DockerHub](https://hub.docker.com/). However, due to the experimental nature of the framework, the images are not yet published. Instead, rely on `branectl` to make the process easy for you.


### Downloading prebuilt images
The recommended way to download the Brane images is to use `branectl`.

For the central node, there are at least two things you have to download:
- The docker-compose file, which will later be used by `branectl` to start and stop the Brane service images; and
- The Brane service images, which `branectl` will later import in the local Docker daemon for running

In addition, if you will be installing the framework on a device where there is extremely limited or restricted internet connectivity, you also want to download:
- Auxillary service images, which `branectl` will later import in the local Docker daemon to provide third-party services used by the framework ([ScyllaDB](https://www.scylladb.com/) and [Kafka](https://kafka.apache.org/) ([zookeeper](https://kafka.apache.org/quickstart))).

`branectl` can download these for you. Run the following two commands:
```bash
# Download the config(s)
branectl download config
# Download the images
branectl download services central --fix-dirs
```

If you're preparing for an offline install, then also run:
```bash
branectl download services auxillary --fix-dirs
```

Once these complete successfully, you should have the images and other files for starting the control node.

> <img src="../../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> By default, `branectl` will download the version for which it was compiled. However, you can change this with the `--version` option:
> ```bash
> # You should change this on all download commands
> branectl download config --version 1.0.0
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
Once you have downloaded the images, it is time to setup the configuration files that determines the type of node and its properties.

For a control node, this means generating the following files:
- A node file (`node.yml`), which will contain the node-specific configuration like service names, ports, file locations, etc.; and
- An infrastructure file (`infra.yml`), which will determine the worker nodes available in the instance.

Both of these can be generated with `branectl` for convenience.

To do so, first generate the `infra.yml` file. Note that, by default, `branectl` assumes a particular file structure in the configuration files; this hiearchy can be seen in 

You can generate both of these using `branectl`. Be aware, however, that by default, the configuration files have to be in a particular structure:
```
<node dir>
├ config
│ ├ certs
│ │ └ <domain certs>
│ └ infra.yml
└ node.yml
```

However, if you generate the `infra.yml` file first and then 
