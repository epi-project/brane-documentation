# Control node
Before you follow the steps in this chapter, we assume you have installed the required [dependencies](./dependencies.md) and installed [`branectl`](./branectl.md), as discussed in the previous two chapters.

If you did, then you are ready to install the control node. This chapter will explain you how to do that. Just like with `branectl`, there are two ways of obtaining them: downloading them from the [repository](https://github.com/epi-project/brane) or building them yourself.

> <img src="../../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> In the future, a third option might be to download the standard images from [DockerHub](https://hub.docker.com/). However, due to the experimental nature of the framework, the images are not yet published. Instead, rely on `branectl` to make the process easy for you.


## Downloading prebuilt images
The recommended way to download the Brane images is to use the `make.py` script provided in the source code of the project.

The easiest way to do so is to clone the repository as a whole (especially if you plan to compile the images yourself anyway):
```bash
# Will clone to './brane'
git clone https://github.com/epi-project/brane
```

Otherwise, you should navigate to the GitHub repository manually (<https://github.com/epi-project/brane>) and download the following files:
- `make.py`: The build script itself.
- `docker-compose-central.yml`: The Docker Compose file that defines the services and how they relate to each other.
```bash

```


## Compiling the images
The other way to obtain the images is to compile them yourself.

Make sure that you have installed the additional [compilation dependencies](./dependencies.md#compilation-dependencies) before continuing (and make sure you match the mode you choose below).

There are two modes of compilation:
- In _release_ mode, you will compile the framework directly in the containers that will be using it. This is the recommended method in most cases.
- In _debug_ or _development_ mode, you will compile the framework with debug symbols, additional debug prints and outside of a container which optimizes repeated recompilation. Additionally, it also statically links GLIBC so the resulting binaries are very portable. This method should only be preferred if you are actively developing the framework.

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

The `make.py` script will handle the rest, and generate the 
