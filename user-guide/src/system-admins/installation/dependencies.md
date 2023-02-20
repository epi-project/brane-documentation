# Dependencies
The first step to install any piece of software is to install its dependencies.

The next section will discuss the runtime dependencies. If you plan to compile the framework instead of downloading the prebuilt executables, you must install _both_ the dependencies in the [first](#runtime-dependencies)- and [second section](#compilation-dependencies).


## Runtime dependencies
In both Brane control nodes and worker nodes, the Brane services are implemented as containers, which means that the number of runtime dependencies is relatively few.

However, the following dependencies are required:
1. You have to install [Docker](https://docker.com) to run the container services. To install, follow one of the following links: [Ubuntu](https://docs.docker.com/engine/install/ubuntu/), [Debian](https://docs.docker.com/engine/install/debian/), [Arch Linux](https://wiki.archlinux.org/title/docker) or [macOS](https://docs.docker.com/desktop/mac/install/) (note the difference between Ubuntu and Debian; they use different keys and repositories).
   - If you are running Docker on Linux, make sure to set it up so that [no root is required](https://docs.docker.com/engine/install/linux-postinstall/):
     ```bash
     sudo usermod -aG docker "$USER"
     ```
     > <img src="../../assets/img/warning.png" alt="warning" width="16" style="margin-top: 3px; margin-bottom: -3px"/> Don't forget to log in and -out again after running the above command to make the new changes effective.
2. Install the [BuildKit plugin](https://docs.docker.com/buildx/working-with-buildx/) for Docker:
   ```bash
   # Clone the repo, CD into it and install the plugin
   # NOTE: You will need to install 'make'
   # (check https://github.com/docker/buildx for alternative methods if that fails)
   git clone https://github.com/docker/buildx.git && cd buildx
   make install

   # Set the plugin as the default builder
   docker buildx install
   
   # Switch to the buildx driver
   docker buildx create --use
   ```
   If these instructions don't work for you, you can also check the [plugin's repository README](https://github.com/docker/buildx#building) for more installation methods.
3. Install [OpenSSL](https://www.openssl.org/) for the `branectl` executable:
   - Ubuntu / Debian:
     ```bash
     sudo apt-get install openssl
     ```
   - Arch Linux:
     ```bash
     sudo pacman -Syu openssl
     ```
   - macOS:
     ```zsh
     # We assume you installed Homebrew (https://brew.sh/)
     brew install openssl
     ```

Aside from that, you have to make sure that your system can run executables compiled against GLIBC 2.27 or higher. You can verify this by running:
```bash
ldd --version
```

The top line of the rest will show you the GLIBC version installed on your machine:

<img src="../../assets/img/glibc-version.png" alt="The top line of the result of running 'ldd --version'" width="600" />

If you do not meet this requirement, you will have to compile `branectl` (and any other non-containerized binaries) yourself on a machine with that version of GLIBC installed or lower. In that case, also install the [compilation dependencies](#compilation-dependencies).


## Compilation dependencies
If you want to compile the framework yourself, you have to install additional dependencies to do so.

There are two parts you may want to compile yourself: `branectl`, the tool for managing a node, and the service images themselves.

For the latter, two modes are available:
- In _release_ mode, you will compile the framework directly in the containers that will be using it. This is the recommended method in most cases.
- In _debug_ or _development_ mode, you will compile the framework with debug symbols, additional debug prints and outside of a container which optimizes repeated recompilation. Additionally, it also statically links GLIBC so the resulting binaries are very portable. This method should only be preferred if you are actively developing the framework.

We will describe the dependencies for compiling `branectl`, compiling the services in release mode and compiling them in debug mode in the following subsections.


### `branectl`
To compile `branectl`, we will be depending on [Rust](https://rust-lang.org)'s compiler [rustc](https://github.com/rust-lang/rust). Additionally, some of Brane's dependencies require some additional packages to be installed too.


**Ubuntu / Debian**
1. Install Rust and its tools using [rustup](https://rustup.rs):
   ```bash
   # Same command as suggested by Rustup itself
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   ```
   Or, if you want a version that installs the default setup and that does not ask for confirmation:
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --profile default -y
   ```
2. Install the packages required by Brane's dependencies with `apt`:
   ```bash
   sudo apt-get update && sudo apt-get install -y \
       gcc g++ \
       cmake \
       pkg-config libssl-dev
   ```


**Arch Linux**
1. Install Rust and its tools using [rustup](https://rustup.rs):
   ```bash
   # Same command as suggested by Rustup itself
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   ```
   Or, if you want a version that installs the default setup and that does not ask for confirmation:
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --profile default -y
   ```
2. Install the packages from `pacman` required by Brane's dependencies
   ```bash
   sudo pacman -Syu \
       gcc g++ \
       cmake \
       pkg-config
   ```
   - Note that the source for OpenSSL is already provided by `openssl` (which is a runtime dependency)


**macOS**
1. Install Rust and its tools using [rustup](https://rustup.rs):
   ```zsh
   # Same command as suggested by Rustup itself
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   ```
   Or, if you want a version that installs the default setup and that does not ask for confirmation:
   ```zsh
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --profile default -y
   ```
2. Install the Xcode Command-Line Tools, since that contains most of the compilers and other tools we need
   ```zsh
   # Follow the prompt after this to install it (might take a while)
   xcode-select --install
   ```
3. Install other packages using [Homebrew](https://brew.sh/):
   - If you have not installed Homebrew yet:
     ```zsh
     # As suggested on their own website
     /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
     ```
   - Install the packages
     ```zsh
     brew install \
         pkg-config \
         openssl
     ```


> <img src="../../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> The main compilation script, `make.py`, is tested for Python 3.7 and higher. If you have an older Python version, you may have to upgrade it first. We recommend using some virtualized environment such as [pyenv](https://github.com/pyenv/pyenv) to avoid breaking your OS or other projects.


### The services (release mode)
No dependencies are required to build the services in release mode other than the [runtime dependencies](#runtime-dependencies). This is because the containers in which the services are built already contain all of the dependencies.


### The services (debug mode)
Debug mode is the most work to install, because it relies on statically linking GLIBC using the [musl-toolchain](https://musl.libc.org/).

> <img src="../../assets/img/warning.png" alt="warning" width="16" style="margin-top: 3px; margin-bottom: -3px"/> Before you consider installing in debug mode, be aware that the resulting images will be very large (due to the debug symbols and the statically linked GLIBC). Moreover, the build cache kept in between builds is also _huge_. Make sure you have enough space on your machine available (~10GB) before continuing, and regularly clean the cache yourself to avoid it growing boundlessly.

Note that most of these dependencies overlap with the dependencies for compiling [`branectl`](#branectl), so you should first install all the dependencies there. Then, extend upon those by doing the following:

**Ubuntu / Debian**
1. Install the musl toolchain:
   ```bash
   sudo apt-get install -y musl-tools
   ```
2. Add shortcuts to GNU tools that emulate missing musl tools (well enough)
   ```bash
   # You can place these shortcuts anywhere in your PATH
   sudo ln -s /bin/g++ /usr/local/bin/musl-g++
   sudo ln -s /usr/bin/ar /usr/local/bin/musl-ar
   ```
3. Add the `musl` target for Rust:
   ```bash
   rustup target add x86_64-unknown-linux-musl
   ```

**Arch Linux**
1. Install the musl toolchain:
   ```bash
   sudo pacman -Syu musl
   ```
2. Add shortcuts to GNU tools that emulate missing musl tools (well enough)
   ```bash
   # You can place these shortcuts anywhere in your PATH
   sudo ln -s /bin/g++ /usr/local/bin/musl-g++
   sudo ln -s /usr/bin/ar /usr/local/bin/musl-ar
   ```
3. Add the `musl` target for Rust:
   ```bash
   rustup target add x86_64-unknown-linux-musl
   ```

**macOS** (TODO untested)
1. Install the musl toolchain:
   ```bash
   brew install filosottile/musl-cross/musl-cross
   ```
2. Add shortcuts to GNU tools that emulate missing musl tools (well enough)
   ```bash
   # You can place these shortcuts anywhere in your PATH
   sudo ln -s /bin/g++ /usr/local/bin/musl-g++
   sudo ln -s /usr/bin/ar /usr/local/bin/musl-ar
   ```
3. Add the `musl` target for Rust:
   ```bash
   rustup target add x86_64-unknown-linux-musl
   ```


## Cross-compilation
If you intent to cross-compile any part of the framework (whether it be `branectl` or a node), you probably need some additional setup to make that happen.


### `branectl`
You have to download the appropriate Rust target. This will use `musl` again, so also be sure to add the depencenies required for [debug mode](#debug-mode).

// TODO

Then, you can download the target using:
```bash
rustup target add <arch>-unknown-linux-musl
```
where you should replace `<arch>` with the target processor architecture. For example:
```bash
rustup target add aarch64-unknown-linux-musl
```
adds the target for ARM processors (e.g., M1 macs).

> <img src="../../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> Note that, even though we are compiling for a Mac, you should still use `-unknown-linux-musl` as suffix. This is because our executable will be relying on the `musl` library anyway, and other than libraries macs and Linux are compatible (enough).


## Next
Congratulations, you have prepared your machine for running (or compiling) a Brane instance! In the [next chapter](./branectl.md), we will discuss installing the invaluable node management tool `branectl`. After that, depending on which node you want to setup, you can follow the guide for installing [control nodes](./control-node.md) or [worker nodes](./worker-node.md).
