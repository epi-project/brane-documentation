# Get binaries
The first step is to either download or compile the framework to run.

Usually, downloading the framework is the quickest and best choice. However, if you're running Docker on a non-x86_64 system, require special features, need an unreleased version or develop the framework yourself, it's necessary to compile it instead.

However, before we describe either method, we will first run through a few runtime dependencies that are always necessary.


## Prerequisites
Regardless of how you install the framework, there are a couple of runtime dependencies which the Brane framework needs:
- Install Docker ([macOS](https://docs.docker.com/desktop/mac/install/), [Ubuntu](https://docs.docker.com/engine/install/ubuntu/), [Debian](https://docs.docker.com/engine/install/debian/) or [Arch Linux](https://wiki.archlinux.org/title/docker)).
    - On Linux, don't forget to make sure you can run [`docker` commands without sudo](https://docs.docker.com/engine/install/linux-postinstall/) (first section).
- On all platforms, install the [BuildKit plugin](https://docs.docker.com/buildx/working-with-buildx/) for Docker:
  ```bash
  # Clone the repo, CD into it and install the plugin (check https://github.com/docker/buildx for alternative methods if that fails)
  git clone https://github.com/docker/buildx.git && cd buildx
  make install

  # Set the plugin as the default builder
  docker buildx install
  
  # Switch to the buildx driver
  docker buildx create --use
  ```
- Install [Docker compose](https://docs.docker.com/compose/):
   - macOS: Docker compose is already installed if you installed Docker Desktop.
   - Ubuntu/Debian:

     Installing via apt-get is quite error-prone, and seems to mess up your system. Additionally, this version does not support all features Brane requires, so instead download the recommended binary:
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


## Downloading binaries
Downloading and then using the binaries may be done automatically by the `./make.sh` script.

There are three types of binaries that are available:
- The Command-Line Interface (CLI), which is the `brane` executable. This will only be executed on your local machine.
- The Brane Instance binaries (of which there are multiple), which represent the server part of Brane. These will likely be deployed on a remote server.
- The Branelet executable, which lives inside of the package containers. This will be executed on a Brane instance (i.e., a remote server).

The branelet executable will automatically be downloaded by the CLI if needed, and so you don't have to download it yourself.

The CLI and instance may be downloaded using the following commands:
```bash
# Make sure it's executable
chmod +x ./make.sh

# Download the CLI binary
./make.sh cli --precompiled

# Download the instance binaries
./make.sh instance --precompiled
```
The `brane` CLI will be available under `target/release/brane`, and the instance binaries will be downloaded to `.container-bins/`.

You can then run the instance using:
```bash
./make.sh start-instance --precompiled
```
Note that, if the binaries are missing, `start-instance` will automatically attempt to download them (similar to compilation). Thus, you can use the `--precompiled` option at the `start-instance` to download different architectures or use existing binaries instead (see the two subsections below).


### Using existing binaries
Alternatively, you can also use binaries that are compiled somewhere else by suppling their paths to the `--precompiled` option:
```bash
# Use the CLI binary at the given path
./make.sh cli --precompiled ./path/to/brane/cli/file

# Use the instance binaries in the given folder
./make.sh instance --precompiled ./path/to/brane/instance/dir
```
This is particularly useful if you first build the instance images on another server, and then extract them using:
```bash
./make.sh extract-binaries
```
which will place them under `.container-bins` in the repository root. You can then send these over to some other server, and build the images with the precompiled binaries using the commands listed above.


### Downloading binaries for another architecture
You can also choose to download binaries for different architectures using the `--arch` flag:
```bash
# Download the CLI binary for x86_64 Intel / AMD processors
./make.sh cli --precompiled --arch x86_64

# Download the instance binaries for Apple Silicon
./make.sh instance --precompiled --arch aarch64
```

You can then use the `start-instance` command with `--precompiled` flag to start the instance. Don't forget to pass the correct architecture as well:
```bash
# If you've downloaded x86_64 instance binaries:
./make.sh start-instance --precompiled --arch x86_64
```
If you omit this, the image architecture will always be the same as your host architecture (so if the binaries differ, this will prevent them from being run).


## Compiling from source
If you need the absolutely cutting-edge latest version or are running a non-default architecture or OS, you may want to compile the framework from source.

> <img src="../assets/img/warning.png" alt="drawing" width="16" style="margin-top: 2px; margin-bottom: -2px"/> Compiling the framework entirely from source generates quite a large build cache (~2.4 GB). Be sure to have at least 7 GB available on your device before you start compiling to make sure your OS keeps functioning.

Before you can begin compilation, you first have install a few extra dependencies:
- Install [Rust](https://www.rust-lang.org)'s compiler and the associated [Cargo](https://crates.io/) package manager (the easiest is to install using [rustup](https://rustup.rs) (cross-platform))
  - If you use rustup, don't forget to logout and in again to refresh the PATH.
- On macOS (Intel):
  - Install XCode Command-Line Tools:
    ```zsh
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
  - To build `branelet`, also install cross-compilers for Linux:
    ```zsh
    # We assume you already have Homebrew (https://brew.sh/) installed
    brew install SergioBenitez/osxct/x86_64-unknown-linux-gnu

    # Make symlinks so that Rust may find them
    sudo ln -s /usr/local/opt/musl-cross/bin/x86_64-linux-musl-gcc /usr/local/bin/musl-gcc
    sudo ln -s /usr/local/opt/musl-cross/bin/x86_64-linux-musl-g++ /usr/local/bin/musl-g++
    ```
    Additionally, you also have to edit `.cargo/config.toml` and uncomment the top three lines:
    ```toml
    # Use the appropriate linker
    [target.x86_64-unknown-linux-musl]
    linker = "musl-gcc"
    ```
- On macOS (Apple Silicon):
  - Install XCode Command-Line Tools:
    ```zsh
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
    # Note that the path is different than from the intel macs!
    export PKG_CONFIG_PATH="/opt/homebrew/openssl@3/lib/pkgconfig"
    ```
    (Run this command every time you open a new terminal and want to compile Brane stuff. Alternatively, if you want it be permanent, add the command to your `~/.zshrc` file)
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
  - To clone the repository, also install [git](https://git-scm.com/):
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
  - To clone the repository, also install [git](https://git-scm.com/):
    ```bash
    sudo pacman -Syu git
    ```

To compile the framework, clone it from the [repository](https://github.com/epi-project/brane). If you have git installed, use:
```bash
git clone https://github.com/epi-project/brane.git
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

# Note: on macOS with Apple Silicon, you should build branelet in a container:
./make.sh branelet --containerized
```
Don't forget to provide it with `--init <path_to_executable>` whenever running `brane build`.


### Quicker instance compilation
If you're building the framework only once, it's worth the wait to compile the instance completely in their own images (which is the standard way of compilation).

However, if you're expecting to build the framework repeatedly, it's incredibly time-consuming to rebuild the framework from scratch on every code change. Additionally, building in-container may be very slow on macOS due to the virtualized Docker runtime.

To work around this, you can also compile a 'development' instance (`dev` for short) that compiles it in debug mode and that cross-compiles the framework for a container rather than compiling it inside a container. Note, though, that this will generate a _lot_ bigger images, so you should only do this if you are really re-building often.

To compile for development, run the following command:
```bash
# Instead of './make.sh instance':
./make.sh instance --dev
```
Make sure that you have the dependencies to compile `branelet` installed before compiling the instance this way.

> <img src="../assets/img/warning.png" alt="warning" width="16" style="margin-top: 2px; margin-bottom: -2px"/> Installing the instance this way results in an _even larger_ build cache (~4.1 GB) and in larger images. To this end, make sure you have at least 10 GB available before compiling.


### Compiling for other architectures
In case the part of brane that you're compiling will run on another architecture than yours (for example, someone in the system uses an M1 mac), you may have to compile the appropriate parts of the framework for that architecture.

Currently, only the instance and branelet are supported, because they run in containers (which removes the complexity of worrying about another type of OS than linux). To do so, install the [qemu-user-static](https://github.com/multiarch/qemu-user-static) BuildKit driver, which utilized the [QEMU emulator](https://www.qemu.org/) to run containers with other architectures:
```bash
# Commands from https://stackoverflow.com/a/60667468
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
docker buildx rm builder
docker buildx create --name builder --driver docker-container --use
```
However, because [non-x86_64 hosts aren't supported by this driver](https://github.com/multiarch/qemu-user-static#supported-host-architectures), you cannot cross-compile on macOS with Apple Silicon.

After you've installed the proper dependencies, use the `--arch` option of the `make.sh` script to specify the target:
```bash
# Compile the framework for x86_64 Intel/AMD processors
./make.sh instance --arch x86_64

# Compile branelet for M1 macs
./make.sh branelet --arch aarch64
```

If you omit the `--arch` option, the `make.sh` script will automatically choose the architecture of the machine you're running it on.


## Next
Next, you should define at least one infrastructure so Brane has at least one place to run jobs. This is discussed in the [next chapter](./infrastructures.md).
