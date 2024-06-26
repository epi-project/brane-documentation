# Compiling binaries
This chapter explains how to compile the various Brane components.

First, start by installing the required [dependencies](#dependencies).

Then, **if you are coming from the scientist- or software engineer-chapters**, you are most likely interested in compiling the [`brane` CLI tool](#brane).

**If you are coming from the administrator-chapters**, you are most likely interested in compiling the [`branectl` CLI tool](#branectl) and the various [instance images](#services).

People who aim to either **run the Brane IDE** or automatically compile BraneScript in another fashion, should checkout the section on [`libbrane_cli`](#libbrane-cli) and [`branec`](#branec).


## Dependencies
If you want to compile the framework yourself, you have to install additional dependencies to do so.

Various parts of the framework are compiled differently. Most notably:
- Any binaries (`brane`, `branectl`, `branec` or `libbrane_cli.so`) are compiled using Rust's [`cargo`](https://github.com/rust-lang/cargo); and
- Any services (i.e., nodes) are compiled within a [Docker](https://docker.com) environment.

Depending on which to install, you may need to install the dependencies for both of them.

### Binaries - Rust and Cargo
To compile Rust code natively on your machine, you should install the language toolchain plus any other dependencies required for the project. An overview per supported OS can be found below:

**Windows** (`brane`, `branec` and `libbrane_cli.so` **only**)

1. Install Rust and its tools using [rustup](https://rustup.rs) (follow the instructions on the website).
2. Install the [Visual Studio Tools](https://visualstudio.microsoft.com/downloads/) to install the required Windows compilers. Installing the [Build Tools for Visual Studio](https://aka.ms/vs/17/release/vs_BuildTools.exe) should be sufficient.
3. Install [Perl](https://perl.org) ([Strawberry Perl](https://strawberryperl.com/) is fine) (follow the instructions on the website).

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
<!--
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
-->


> <img src="../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> The main compilation script, `make.py`, is tested for Python 3.7 and higher. If you have an older Python version, you may have to upgrade it first. We recommend using some virtualized environment such as [pyenv](https://github.com/pyenv/pyenv) to avoid breaking your OS or other projects.

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
       cmake
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
       cmake
   ```

### Services - `control`, `worker` and `proxy` nodes
The services are build in Docker. As such, install it on your machine, and it should take care of the rest.

Simply follow the instructions on <https://www.docker.com/get-started/> to get started.


## Compilation
With the dependencies install, you can then compile the parts of the framework of your choosing.

For all of them, first clone the [repository](https://github.com/epi-project/brane). Either download it from Github's interface (the green button in the top-right), or clone it using the command-line:
```bash
git clone https://github.com/epi-project/brane && cd brane
```

Then you can use the `make.py` script to install what you like:
- To build the `brane` CLI tool, run:
  ```bash
  python3 make.py cli
  ```
- To build the `branectl` CLI tool, run:
  ```bash
  python3 make.py ctl
  ```
- To build the `branec` BraneScript compiler, run:
  ```bash
  python3 make.py cc
  ```
- To build the `libbrane_cli.so` dynamic library, run:
  ```bash
  python3 make.py libbrane_cli
  ```
- To build the servives for a control node, run:
  ```bash
  python3 make.py instance
  ```
- To build the servives for a worker node, run:
  ```bash
  python3 make.py worker-instance
  ```
- To build the servives for a proxy node, run:
  ```bash
  python3 make.py proxy-instance
  ```

> <img src="../assets/img/warning.png" alt="drawing" width="16" style="margin-top: 2px; margin-bottom: -2px"/> Note that compiling **any of these** will result in quite large build caches (order of GB's). Be sure to have at least 10 GB available on your device before you start compiling to make sure your OS keeps functioning.

For any of the binaries (`brane`, `branectl` and `branec`), you may make them available in your PATH by copying them to some system location, e.g.,
```bash
sudo cp ./target/release/brane /usr/local/bin/brane
```
to make them available system-wide.


## Troubleshooting
This section lists some common issues that occur when compiling Brane.

1. **I'm running out of space on my machine. What to do?**  
   Both the build caches of Cargo and Docker tend to accumulate a lot of artefacts, most of which aren't used anymore. As such, it can save a lot of space to clear them.

   For Cargo, simply remove the `target`-directory:
   ```bash
   rm -rf ./target
   ```

   For Docker, you can clear the Buildx build cache:
   ```bash
   docker buildx prune -af
   ```
   > <img src="../assets/img/warning.png" alt="drawing" width="16" style="margin-top: 2px; margin-bottom: -2px"/> The above command clears _all_ Buildx build cache, not just Brane's. Use with care.

   It can also sometimes help to prune old images or containers if you're building new versions often.

   Do note that running either will re-trigger a new, clean build, and therefore may take some time.

2. **Errors like `ERROR: Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?` or `unix:///var/run/docker.sock not found` when building services**  
   This means that your Docker engine is most likely not running. On Windows and macOS, start it by starting the Docker Engine application. On Linux, run:
   ```bash
   sudo systemctl start docker
   ```

3. **`Permission denied` errors when building services (Linux)**  
   Running Docker containers may be a security risk because it can be used to edit any file on a system, permission or not. As such, you have to be added to the `docker`-group to run it without using `sudo`.

   If you are managing the machine you are running on, you can run:
   ```bash
   sudo usermod -aG docker "$USER"
   ```
   Don't forget to restart your terminal to apply the change, and then try again.


<!-- GRAVEYARD -->

<!--
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
-->


<!--
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
-->






<!--
To do so, you should first install a couple of additional dependencies that are required when building the framework:
- Install [Rust](https://www.rust-lang.org)'s compiler and the associated [Cargo](https://crates.io/) package manager (the easiest is to install using [rustup](https://rustup.rs) (cross-platform))
  - If you use rustup, don't forget to logout and in again to refresh the PATH.
- On Windows:
  - Install [Python](https://python.org)
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
-->

<!--
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
-->







<!--
In that case, it's necessary to compile the `branectl` executable yourself.

To do so, first make sure that you have installed the [compilation dependencies](./dependencies.md#branectl) of `branectl` as discussed in the previous chapter.

Then, you can clone the [repository](https://github.com/epi-project/brane) to obtain the source code:
```bash
# Will clone to './brane'
git clone https://github.com/epi-project/brane
```

Navigate to the source directory, and then use the `make.py` script to compile `branectl`:
```bash
# Replace './brane' with some other path if needed
cd ./brane
./make.py ctl
```

The `make.py` script will handle the rest.

You can also compile the `ctl` in development mode (i.e., with added debug statements and symbols) by appending the `--dev` flag:
```bash
./make.py ctl --dev
```

Finally, you can also compile the binary for another architecture:
```bash
# To compile for M1 macs on a Linux machine, for example
./make.py ctl --os macOS --arch aarch64
```

Note, however, the [additional dependencies](./dependencies.md#cross-compilation) if you do so.
-->





<!--
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
-->



<!--
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
-->


<!--
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
-->


