# Local installation
In this chapter, we discuss how to install the Brane framework on one node only. This does not mean that no other nodes may be used while executing workflows; it simply means that the control functionality of the framework runs on a single node, which makes the installation process a bit easier.


## Preparation
The framework is build and tested to run on Unix-like systems (Linux, macOS). Windows is not supported, so it is probably easiest to install a virtual machine or to install the [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/install).

With access to a supported operating system, prepare the system by installing Brane's runtime dependencies:
 - Install [Docker](https://docker.com) on your machine (tutorials for [Ubuntu](https://docs.docker.com/engine/install/ubuntu/), [Debian](https://docs.docker.com/engine/install/debian/) (has different repository & keys) or [macOS](https://docs.docker.com/desktop/mac/install/))
    - On Linux, make sure to setup Docker for use without `sudo` access ([tutorial](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user))
 - Install the [Buildx plugin](https://github.com/docker/buildx) for Docker (see their README):
    ```bash
    # Clone and install the buildx plugin 
    git clone https://github.com/docker/buildx.git && cd buildx
    make install

    # Don't forget to also set 'docker build' as an alias to 'docker buildx'
    docker buildx install
    ```
 - 


## Installation
Now that the dependencies are installed, we can install the framework by download pre-compiled binaries.

> Unfortunately, we don't have a git repository with pre-compiled binaries yet; for now, [build the binaries from source first](./build-from-source.md) (as indicated as alternative path in the how-to)

Get the precompiled binaries together with the relevant Dockerfiles (or follow the [building from source](./build-from-source.md)-chapter):
```bash
wget https://<URL>/brane-instance.tar.gz
tar -xvzf ./brane-instance.tar.gz
cd brane-instance
```
