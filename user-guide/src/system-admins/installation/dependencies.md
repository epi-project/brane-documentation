# Dependencies
The first step to install any piece of software is to install its dependencies.

The next section will discuss the runtime dependencies. If you plan to compile the framework instead of downloading the prebuilt executables, also follow the second section.


## Runtime dependencies
In both Brane control nodes and worker nodes, the Brane services are implemented as containers, which means that the number of installable dependencies is relatively few.

However, the following dependencies are required:
1. You have to install [Docker](https://docker.com), obviously, to run the container services. To install, follow one of the following links: [Ubuntu](https://docs.docker.com/engine/install/ubuntu/), [Debian](https://docs.docker.com/engine/install/debian/), [Arch Linux](https://wiki.archlinux.org/title/docker) or [macOS](https://docs.docker.com/desktop/mac/install/).
   - If you are running Docker on Linux, make sure to set it up so that [no root is required](https://docs.docker.com/engine/install/linux-postinstall/) (first section).
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
   If these instructions don't work for you, you can also check the [plugin's repository](https://github.com/docker/ buildx) for more installation methods.
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

Aside from that, you have to make sure that your system can run executables compiled against GCC /* TODO */.


## Compilation dependencies
If you want to compile the framework yourself, you have to install additional dependencies to do so.

There are two part you may want to compile yourself: the first is `branectl`, and the second are the instance images.

For the latter, two modes available:
- In _release_ mode, you will compile the framework directly in the containers that will be using it. This is the recommended method in most cases.
- In _debug_ or _development_ mode, you will compile the framework with debug symbols, additional debug prints and in a method that optimizes repeated recompilation. This method should only be preferred if you are actively developing the framework.

We will describe the dependencies for compiling `branectl`, release mode and debug mode in the following subsections, respectively.


### `branectl`
To compile `branectl`, we will be depending on [Rust](https://rust-lang.org)'s compiler [rustc](https://github.com/rust-lang/rust). Additionally, some of Brane's dependencies require some additional packages to be installed too.


**Ubuntu / Debian**
1. Install Rust and its tools using [rustup](https://rustup.rs):
   ```bash
   # Same command as suggested by Rustup itself
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   ```
   ```bash
   # Or, if you want to go with the default installation:
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --profile default -y
   ```
2. Install the packages from `apt` required by Brane's dependencies
   ```bash
   sudo apt-get update && sudo apt-get install -y \
       curl \
       gcc g++ \
       cmake \
       pkg-config libssl-dev
   ```
   - Note that we install `curl` only to install Python and protobuf (see below).
3. Make sure you have [Python](https://python.org) 3.9 or higher
   - Check your Python version:
     ```bash
     python3 --version
     ```
   - To install the updated version, use `pyenv` to do so without breaking your local setup:
     ```bash
     # Install pyenv itself
     curl https://pyenv.run | bash

     # Add the relevant lines to your terminal profile (either '.bashrc', '.profile', '.zshrc', ...)
     cat <<EOF >> ~/.bashrc
     # pyenv
     export PYENV_ROOT="\$HOME/.pyenv"
     command -v pyenv >/dev/null || export PATH="\$PYENV_ROOT/bin:\$PATH"
     eval "\$(pyenv init -)"
     EOF
     source ~/.bashrc

     # Use Python 3.9
     pyenv install 3.9.16
     pyenv global 3.9.16
     ```
     > <img src="../../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> You can go back to your original Python version at any time:
     > ```bash
     > pyenv global system
     > ```
4. Install the [Protobuf](https://developers.google.com/protocol-buffers) compiler by manually compiling it (the version from `apt` is not recent enough)
   ```bash
   # Download the file & compile the project
   curl -L https://github.com/protocolbuffers/protobuf/archive/refs/tags/v3.21.10.tar.gz | tar -xvz
   cd ./protobuf-3.21.10
   cmake -Dprotobuf_BUILD_TESTS=off .
   cmake --build . -j $(nproc)

   # Don't forget to put it somewhere in your PATH
   sudo mv $(readlink protoc) /usr/local/bin/protoc
   ```


**Arch Linux**
1. Install Rust and its tools using [rustup](https://rustup.rs):
   ```bash
   # Same command as suggested by Rustup itself
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   ```
   ```bash
   # Or, if you want to go with the default installation:
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --profile default -y
   ```
2. Install the packages from `pacman` required by Brane's dependencies
   ```bash
   sudo pacman -Syu \
       curl \
       gcc g++ \
       cmake \
       pkg-config \
       protobuf
   ```
   - Note that the source for OpenSSL is already provided by `openssl` (which is a runtime dependency)
   - Note that we install `curl` only to install Python (see below).
3. Make sure you have [Python](https://python.org) 3.9 or higher
   - Check your Python version:
     ```bash
     python3 --version
     ```
   - To install the updated version, use `pyenv` to do so without breaking your local setup:
     ```bash
     # Install pyenv itself
     curl https://pyenv.run | bash

     # Add the relevant lines to your terminal profile (either '.bashrc', '.profile', '.zshrc', ...)
     cat <<EOF >> ~/.bashrc
     # pyenv
     export PYENV_ROOT="\$HOME/.pyenv"
     command -v pyenv >/dev/null || export PATH="\$PYENV_ROOT/bin:\$PATH"
     eval "\$(pyenv init -)"
     EOF
     source ~/.bashrc

     # Use Python 3.9
     pyenv install 3.9.16
     pyenv global 3.9.16
     ```
     > <img src="../../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> You can go back to your original Python version at any time:
     > ```bash
     > pyenv global system
     > ```


**macOS**
1. Install Rust and its tools using [rustup](https://rustup.rs):
   ```zsh
   # Same command as suggested by Rustup itself
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   ```
   ```zsh
   # Or, if you want to go with the default installation:
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --profile default -y
   ```
2. Install the Xcode Command-Line Tools, since that contains most of the compilers and other tools we need
   ```zsh
   # Follow the prompt after this to install it
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
         openssl \
         protobuf
     ```
4. Make sure you have [Python](https://python.org) 3.9 or higher
   - Check your Python version:
     ```zsh
     python3 --version
     ```
   - To install the updated version, use `pyenv` to do so without breaking your local setup:
     ```zsh
     # Install pyenv itself (we assume you already installed Homebrew)
     brew install pyenv

     # Use Python 3.9
     pyenv install 3.9.16
     pyenv global 3.9.16
     ```
     > <img src="../../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> You can go back to your original Python version at any time:
     > ```bash
     > pyenv global system
     > ```


### Release mode
In release mode, you only have to make sure that [Python](https://python.org) 3.9 or higher is installed to run the make script.

You can check which Python version you are running with:
```bash
python3 --version
```

To install the newer version, use the following commands:
- Ubuntu / Debian / Arch Linux:
  ```bash
  # Install pyenv itself
  curl https://pyenv.run | bash

  # Add the relevant lines to your terminal profile (either '.bashrc', '.profile', '.zshrc', ...)
  cat <<EOF >> ~/.bashrc
  # pyenv
  export PYENV_ROOT="\$HOME/.pyenv"
  command -v pyenv >/dev/null || export PATH="\$PYENV_ROOT/bin:\$PATH"
  eval "\$(pyenv init -)"
  EOF
  source ~/.bashrc

  # Use Python 3.9
  pyenv install 3.9.16
  pyenv global 3.9.16
  ```
- macOS:
  ```zsh
  # Install pyenv itself (we assume you already installed Homebrew)
  brew install pyenv

  # Use Python 3.9
  pyenv install 3.9.16
  pyenv global 3.9.16
  ```
> <img src="../../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> You can go back to your original Python version at any time:
> ```bash
> pyenv global system
> ```


### Debug mode
Debug mode is the most work to install, because it relies on cross-compilation using the [musl-toolchain](https://musl.libc.org/).

Note that most of these overlap with [`branectl`](#branectl), so you should first install all the dependencies there. Then, extend upon those by doing the following:

**Ubuntu / Debian**
1. Install the musl toolchain:
   ```bash
   sudo apt-get install -y musl-tools
   ```
2. Add shortcuts to GNU tools that emulate missing musl tools (well enough)
   ```bash
   # You can place these shortcut anywhere in your PATH
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
