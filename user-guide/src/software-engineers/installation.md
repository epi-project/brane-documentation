# Installation
To develop Brane packages, you will need three components:
- The **Brane Command-Line Interface** (Brane CLI), which you use to package your code and publish it to an instance
- A Docker engine, which is used to build the package containers by the Brane CLI
- Support for your language of choice

The third component, the language support, is hard to generalize as it will depend on the language you choose. However, there is an import difference in setup between [interpreted languages and compiled languages](https://www.freecodecamp.org/news/compiled-versus-interpreted-languages/).

For interpreted languages, (such as [Python](https://www.python.org/)), you should setup your machine in such a way that it is able to run the scripts locally (for development purposes). Additionally, you should make sure that you have some way of installing the interpreter (and any dependencies) on Ubuntu (since the Brane containers are based on that OS).

For compiled languages (such as [Rust](https://www.rust-lang.org/)), you should prepare your machine to not only develop but also compile the language for use in an Ubuntu container. Then, you should only package the resulting binaries so that the package container remains as lightweight as possible.

The other two prerequisites will be discussed below.


## The Docker engine
First, you should install [Docker](https://docker.com) on the machine that you will use for development. Brane will use this to build the containers, since Docker features an excellent build system. However, Brane also requires you to have the [BuildKit plugin](https://docs.docker.com/buildx/working-with-buildx/) installed on top of the normal Docker build system.

To install Docker, refer to their official documentation ([macOS](https://docs.docker.com/desktop/mac/install/), [Ubuntu](https://docs.docker.com/engine/install/ubuntu/), [Debian](https://docs.docker.com/engine/install/debian/) or [Arch Linux](https://wiki.archlinux.org/title/docker)). Note that, if you install Docker on Linux, you should make sure that you can execute Docker commands without sudo (see [here](https://docs.docker.com/engine/install/linux-postinstall/), first section) Then, you should install the Buildkit plugin by running the following commands:
```bash
# Clone the repo, CD into it and install the plugin (check https://github.com/docker/buildx for alternative methods if that fails)
git clone https://github.com/docker/buildx.git && cd buildx
make install

# Switch to the buildx driver
docker buildx create --use
```


## The Brane CLI
With Docker installed, you may then install the Brane Command-Line Interface.

You can either download the binary directly from the repository, or build the tool from scratch. The first method should be preferred in most cases, which the latter is only required if you require a non-released version or run Brane on non-x86_64 hardware.

> <img src="../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> Note that you probably already installed the Brane Command-Line Interface if you've installed a node on your local machine (follow [this](TODO) guide, for example).


### Downloading the binary
To download the Brane CLI binary, use the following commands:
```bash
# For Linux
sudo wget -O /usr/local/bin/brane https://github.com/epi-project/brane/releases/latest/download/brane-linux-x86_64

# For macOS (Intel)
sudo wget -O /usr/local/bin/brane https://github.com/epi-project/brane/releases/latest/download/brane-darwin-x86_64

# For macOS (M1/M2)
sudo wget -O /usr/local/bin/brane https://github.com/epi-project/brane/releases/latest/download/brane-darwin-aarch64
```
These commands download the latest Brane CLI binary for your OS, and store them in `/usr/local/bin` (which is why the command requires `sudo`). You may install the binary anywhere you like, but don't forget to add the binary to your PATH if you choose a location that is not part of it already.


### Compiling the binary
You may also compile the binary from source if you need the cutting-edge latest version or are running a system that doesn't have any default binary available.

To compile the binary, refer to the [compilation instructions](/specification/development/compilation.html) over at the [Brane: A Specification](/specification)-book for instructions.


## Next
Now that you have the Brane CLI installed, we will give a brief tutorial on how to start writing packages in the [next chapter](./hello-world.md).

If you would like to know more about the different packages types that Brane supports, check the [Packages](../packages/introduction.md) series of chapters.
