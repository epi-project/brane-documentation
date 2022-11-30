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

# Set the plugin as the default builder
docker buildx install

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

To do so, you should first install a couple of additional dependencies that are required when building the framework:
- Install [Rust](https://www.rust-lang.org)'s compiler and the associated [Cargo](https://crates.io/) package manager (the easiest is to install using [rustup](https://rustup.rs) (cross-platform))
  - If you use rustup, don't forget to logout and in again to refresh the PATH.
- On macOS:
  - Install XCode Command-Line Tools:
    ```bash
    # On macOS 10.9+ or higher, running any command part of the tools will prompt you to install them:
    git --version
    ```
  - Install [OpenSSL](https://www.openssl.org/), [pkg-config](https://www.freedesktop.org/wiki/Software/pkg-config/) (so the Rust packages find your OpenSSL installation) and [CMake](https://cmake.org/):
    ```zsh
    # We assume you already have Homebrew (https://brew.sh/) installed
    brew install pkg-config openssl cmake
    ```
  - Make sure that `pkg-config` is able to find the OpenSSL installation by running:
    ```zsh
    export PKG_CONFIG_PATH="/usr/local/opt/openssl@3/lib/pkgconfig"
    ```
    (Run this command every time you open a new terminal and want to compile Brane stuff. Alternatively, if you want it be permanent, add the command to your `~/.zshrc` file)
  
- On Ubuntu / Debian:
  - Install the build dependencies for Rust packages: [GCC](https://gcc.gnu.org/) (gcc and g++), [OpenSSL](https://www.openssl.org/) (headers only), [pkg-config](https://www.freedesktop.org/wiki/Software/pkg-config/), [make](https://www.gnu.org/software/make/) and [CMake](https://cmake.org/):
    ```bash
    sudo apt-get update && sudo apt-get install \
        gcc g++ \
        libssl-dev \
        pkg-config \
        make \
        cmake
    ```
  - To clone the repository, also install [git](https://git-scm.com/):
    ```bash
    sudo apt-get install git
    ```
- On Arch Linux:
  - Install the build dependencies for Rust packages: [GCC](https://gcc.gnu.org/), [OpenSSL](https://www.openssl.org/), [pkg-config](https://www.freedesktop.org/wiki/Software/pkg-config/), [make](https://www.gnu.org/software/make/) and [CMake](https://cmake.org/):
    ```bash
    sudo pacman -Syu gcc openssl pkg-config make cmake
    ```
  - To clone the repository, also install [git](https://git-scm.com/):
    ```bash
    sudo pacman -Syu git
    ```

With the dependencies installed, you may then clone the repository and build the Command-Line Interface:
```bash
# Clone the repo and CD into it
git clone https://github.com/epi-project/brane && cd brane

# Run the make script to build the CLI
chmod +x ./make.py
./make.py cli
```

> <img src="../assets/img/warning.png" alt="drawing" width="16" style="margin-top: 2px; margin-bottom: -2px"/> Note that compiling the CLI generates quite a large build cache (~2.4 GB). Be sure to have at least 7 GB available on your device before you start compiling to make sure your OS keeps functioning.

Once done (this may take some time), the resulting binary will be written to `./target/release/brane`. You can then copy the binary to `/usr/local/bin` to make it available in your PATH:
```bash
sudo cp ./target/release/brane /usr/local/bin/brane
```
Alternatively, you can also add the `./target/release` folder to your PATH instead (don't forget to prepend the path to the cloned repository, e.g., `/home/user/Downloads/brane/target/release`).


## Next
Now that you have the Brane CLI installed, we will give a brief tutorial on how to start writing packages in the [next chapter](./hello-world.md).

If you would like to know more about the different packages types that Brane supports, check the [Packages](../packages/introduction.md) series of chapters.
