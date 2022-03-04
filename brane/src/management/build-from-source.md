# Building Brane from source
In this chapter, we will explain how to build Brane from source. We will list two methods; one that focusses on building for a release version, and one that optimizes re-building Brane in the future (for development).

Once built, the binaries can be used in either the [local installation](./local-install.md) or [distributed installation](./distributed-install.md) chapters.


## Preparation
Regardless of whether you're building for release or for development, first make sure you have installed the compile-time dependencies of the framework:
 - Install [Cargo](https://github.com/rust-lang/cargo) and the [Rust compiler](https://github.com/rust-lang/rust/) (the easiest to do so is by using [rustup](https://rustup.rs/))
 - Install [gcc](https://gcc.gnu.org/), [make](https://www.gnu.org/software/make/) and [cmake](https://cmake.org/), since some Rust packages have to compile C/C++ code. For Ubuntu and Debian, this can be done by running:
   ```bash
   sudo apt-get install gcc make cmake
   ```
 - Make sure that [Docker](https://www.docker.com/) is installed as well (for [Ubuntu](https://docs.docker.com/engine/install/ubuntu/), [Debian](https://docs.docker.com/engine/install/debian/) (has different repository & keys) or [macOS](https://docs.docker.com/desktop/mac/install/))
    - On Linux, make sure to setup Docker for use without `sudo` access ([tutorial](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user))
 - Makes sure the [Buildx plugin](https://github.com/docker/buildx) for Docker is installed (see their README):
    ```bash
    # Clone and install the buildx plugin 
    git clone https://github.com/docker/buildx.git && cd buildx
    make install

    # Don't forget to also set 'docker build' as an alias to 'docker buildx'
    docker buildx install
    ```


## Building for release
> Unfortunately, we don't have a git repository with pre-compiled binaries yet; for now, assume that you obtained the source code by magic

Building for release is the simplest, and results with the most optimized binaries.

Start by pulling the source code from [the repository]():
```bash
git clone https://<URL>/brane.git ./brane
cd brane
```

Next, build the Brane instance by running:
```bash
make instance
```

This will build directly to six Docker images: `brane-api`, `brane-clb`, `brane-drv`, `brane-job`, `brane-log` and `brane-plr`.

The advantage of this method is that they are optimized for and properly linked against the container in which they are build, and that the Makefile will automatically strip debug symbols and such. Additionally, this results in images that do not depend on any files outside of them. This method should almost always be preferred, except in the case for when you're actively working on the framework.


## Building for development
During development, however, we are less interested in optimized binaries and rather more in fast build times. The release methods has several disadvantages: the common dependencies between any of the six resulting binaries will have to be build multiple times, and any build cache is cleared once the images are generated; this means that if we want to build Brane again, we have to build everything from scratch.

To overcome this, two more commands are available to build Brane: one to cross-compile against the Docker container, and one to build the dependencies in a separate Docker container that is friendly to caches.

### Cross-compilation
To cross-compile for the Docker target, we first have to install additional dependencies:
 - Install the [musl]() compiler.
    - On Linux, 
    - On macOS, 
 - On macOS, make sure to have a `.cargo/config.toml` file in the root of the repository with:
   ```
   # Use the appropriate linker
   [target.x86_64-unknown-linux-musl]
   linker = "musl-gcc"
   rustflags = [ "-C", "link-arg=-Wl,-melf_x86_64" ]
   ```
   This file makes sure that the Rust compiler is able to find the musl compiler and sets the appropriate flags.

Then, make sure to have suitable OpenSSL binaries available to compile against (it needs to be under `contrib/deps/openssl`). Some Rust packages need this, and because we're cross-compiling it cannot find the default installed one (if that one would even work).

The compiled version we have provided should work, but if you need to compile your own for some reason, run:
```bash
# Clean the old one
make clean_openssl

# Generate a new one 
make openssl
```

The Makefile will also automatically compile a new version if it cannot find an existing one, so the last step is technically optional.

With the new dependencies and compiled OpenSSL installation in place, we can cross-compile the Brane instance with:
```bash
make instance-dev
```
