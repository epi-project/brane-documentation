# Localized installation
In this chapter, we will describe how to setup a Brane instance on a single machine. This means that we will prepare the machine in question to run the entire control plane of the cluster in [Docker](https://docker.com), after which it may still connect to remote sites to implement the orchestration.

That said, by default, we will only define the same machine as the available domain by default. This means that this is the perfect mode to experiment or 

There are two options to install the framework locally: downloading the binaries and images from the github and registry, or build the images from source.


## Prerequisites
Regardless of how you install the framework, though, there are a couple of runtime dependencies on which the Brane framework needs:
- Install Docker ([macOS](https://docs.docker.com/desktop/mac/install/), [Ubuntu](https://docs.docker.com/engine/install/ubuntu/), [Debian](https://docs.docker.com/engine/install/debian/) or [Arch Linux](https://wiki.archlinux.org/title/docker)).
    - On Linux, don't forget to make sure you can run [`docker` commands without sudo](https://docs.docker.com/engine/install/linux-postinstall/) (first section).
- On all platforms, install the [BuildKit plugin](https://docs.docker.com/buildx/working-with-buildx/) for Docker (or install straight from the [repository](https://github.com/docker/buildx).).  
  If you done so, you should set the plugin as default and switch to the plugin driver:
  ```bash
  # Set the plugin as the default builder
  docker buildx install
  
  # Switch to the buildx driver
  docker buildx create --use
  ```
- Install [Docker compose](https://docs.docker.com/compose/):
   - macOS: Docker compose is already installed if you installed Docker Desktop.
   - Ubuntu/Debian:
     ```bash
     # Download the binary to /usr/local/bin/docker-compose
     sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

     # Make it executable
     sudo chmod +x /usr/local/bin/docker-compose
     ```
   - Arch Linux:
     ```bash
     sudo pacman -Syu docker-compose
     ```



## Using pre-compiled binaries
> Unfortunately, the images are not yet uploaded to a public repository, and so you cannot use this method yet. Instead, proceed with the [Compilation from source](#Compilation-from-source) method to obtain the binaries and the images.


## Compilation from source
Alternatively, if you need the absolutely cutting-edge latest version or are running a non-default architecture or OS, you may want to compile the framework from source.

> Note: compiling the framework entirely from source generates quite a large build cache (~2.4 GB). Be sure to have at least 7 GB available on your device before you start compiling to make sure your OS keeps functioning.

Before you can begin compilation, you first have install a few extra dependencies:
- Install [Rust](https://www.rust-lang.org)'s compiler and the associated [Cargo](https://crates.io/) package manager (the easiest is to install using [rustup](https://rustup.rs) (cross-platform))
  - If you use rustup, don't forget to logout and in again to refresh the PATH.
- On macOS:
  - Install XCode Command-Line Tools:
    ```bash
    # On macOS 10.9+ or higher, running any command part of the tools will prompt you to install them:
    git --version
    ```
- On Ubuntu / Debian:
  - To build the CLI, install the build dependencies for Rust packages: [GCC](https://gcc.gnu.org/) (gcc and g++), [OpenSSL](https://www.openssl.org/) (headers only), [pkg-config](https://www.freedesktop.org/wiki/Software/pkg-config/), [make](https://www.gnu.org/software/make/) and [CMake](https://cmake.org/):
    ```bash
    sudo apt-get update && sudo apt-get install \
        gcc g++ \
        libssl-dev \
        pkg-config \
        make \
        cmake
    ```
  - To build `branelet`, also install [musl](https://www.musl-libc.org/)-toolchain:
    ```bash
    sudo apt-get install musl-tools
    ```
     - Musl does not contain a C++-compiler by default. However, this can be fixed by simply adding a softlink to the GCC g++ compiler:
       ```bash
       # We place it in /usr/local/bin, but anything in PATH should do
       sudo ln -s /bin/g++ /usr/local/bin/musl-g++
       ```
  - To clone the repository from the CLI, also install [git](https://git-scm.com/):
    ```bash
    sudo apt-get install git
    ```
- On Arch Linux:
  - To build the CLI, install the build dependencies for Rust packages: [GCC](https://gcc.gnu.org/), [OpenSSL](https://www.openssl.org/), [pkg-config](https://www.freedesktop.org/wiki/Software/pkg-config/), [make](https://www.gnu.org/software/make/) and [CMake](https://cmake.org/):
    ```bash
    sudo pacman -Syu gcc openssl pkg-config make cmake
    ```
  - To build `branelet`, also install the [musl](https://www.musl-libc.org/)-toolchain:
    ```bash
    sudo pacman -Syu musl
    ```
     - Musl does not contain a C++-compiler by default. However, this can be fixed by simply adding a softlink to the GCC g++ compiler:
       ```bash
       # We place it in /usr/local/bin, but anything in PATH should do
       sudo ln -s /bin/g++ /usr/local/bin/musl-g++
       ```
  - To clone the repository from the CLI, also install [git](https://git-scm.com/):
    ```bash
    sudo pacman -Syu git
    ```

To compile the framework, first you have to clone it from the [repository](https://github.com/epi-project/brane). If you have git installed, use:
```bash
git clone https://github.com/epi-project.brane.git
cd brane
```
Once you're inside the repository's root directory, you may use the `make.sh` build script to build the required components.

A typical Brane installation should at least require the command-line tool `brane` and the Brane instance itself (six Docker images + auxillary services). You can compile these with:
```bash
# Make sure the script has execution rights
chmod +x ./make.sh

# Compile the command-line tool to ./target/release/brane
./make.sh cli

# Compile the instance binaries in their own images
./make.sh instance
```

If you're building from source because you want the latest version that is not yet released, you will also have to build your own `branelet` executable:
```bash
# Compile the 'branelet' executable, which is used as a delagate in package containers
./make.sh branelet
```
Don't forget to provide it with `--init <path_to_executable>` whenever running `brane build`.


### Quicker instance compilation
If you're building the framework only once, it's worth the wait to compile the instance completely in their own images (which is the standard way of compilation).

However, if you're expecting to build the framework repeatedly, it's incredibly time-consuming to rebuild the framework from scratch on every code change. Additionally, building in-container is very slow on macOS due to the virtualized Docker runtime.

To work around this, you can also compile a 'development' instance (`dev` for short) that compiles it in debug mode and that cross-compiles the framework for a container rather than compiling it inside a container. Note, though, that this will generate a _lot_ bigger images, so you should only do this if you are really re-building often.

To compile for development, run the following command:
```bash
# Instead of './make.sh instance':
./make.sh instance --dev
```
Make sure that you have the dependencies to compile `branelet` installed before compiling the instance this way.

> Note: installing the instance this way results in an _even larger_ build cache (~4.1 GB) and in larger images. To this end, make sure you have at least 10 GB available before compiling.


## Launching the local instance
Once you have downloaded the binaries or compiled the framework from source, you can launch the location installation in your local Docker engine by running:
```bash
./make.sh start-instance
```
This will start the required Brane services. Note, though, that even if the command returns, the framework will not be usable; this is due to slow loading times for the Scylla database once the container is up-and-running.

To know when the framework is ready, run:
```bash
watch 'docker ps | grep -i brane-'
```
and wait until all services are up and running (i.e., none is 'Restarting').

You can stop all services again by running:
```bash
./make.sh stop-instance
```


### Launching the development instance
If you've compiled the framework with the development instance (i.e., used `./make.sh instance-dev`), you have to launch the framework with another command to launch the instance because of different image names:
```bash
./make.sh start-instance-dev
```
Similarly, to stop the framework again, you should run:
```bash
./make.sh stop-instance-dev
```


## Next steps
Once the framework is running, the main entrypoint (`brane-drv`) is available under `http://127.0.0.1:50053`. Because it should behave like a normal instance, you may follow the [Brane: The User Guide](/user-guide) book as normal to interact with it.

In this book, we will continue in the [subsequent chapter](./remote-access.md) to describe how to prepare your cluster and node to run jobs on remote domains.
