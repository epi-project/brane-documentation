# `branectl`
Your best friend for managing a Brane node is the Brane server command-line tool, or `branectl`.

This chapter concerns itself with installing `branectl` itself. Make sure that you have followed the [previous chapter](./dependencies.md) to install the necessary dependencies before you begin.


## Precompiled binary
In most cases, it's the easiest to download the precompiled binary from the [repository](https://github.com/epi-project/brane).

To download it, you can simply go to the repository (<https://github.com/epi-project/brane>) and navigate to 'tags'. From there, you can select your desired release (only 1.0.0 and up have `branectl`s) and choose it from among the list.

Once downloaded, it's highly recommended to move the executable to a location in your PATH (for example, `/usr/local/bin`).

Alternatively, you can also download it using `curl` from the command-line:
```bash
# For x86_64/Linux
sudo curl -Lo /usr/local/bin/branectl https://github.com/epi-project/brane/releases/latest/download/brane-linux-x86_64

# For macOS (intel)
sudo curl -Lo /usr/local/bin/branectl https://github.com/epi-project/brane/releases/latest/download/brane-darwin-x86_64

# For macOS (M1/M2)
sudo curl -Lo /usr/local/bin/branectl https://github.com/epi-project/brane/releases/latest/download/brane-darwin-aarch64
```

Don't forget to make the executable runnable:
```bash
sudo chmod +x /usr/local/bin/branectl
```

> <img src="../../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> If you already have a clone of the repository, you can also use the `make.py` script to download the CTL without using curl:
> ```bash
> ./make.py ctl --download
> ```
> This will download the version appropriately for your processor/OS. Note that you can also use the `--arch` flag to change this (consult `./make.py --help` for more information).


## Compile it yourself
Sometimes, though, the executable provided on the repository doesn't suit your needs. This is typically the case if you need a cutting-edge version that isn't released, or if you have an uncommon OS or processor architecture.

In that case, it's necessary to compile the `branectl` executable yourself.

To do so, first make sure that you have installed the [dependencies](./dependencies.md#branectl) for compiling `branectl`.

Then, you can download the [repository](https://github.com/epi-project/brane) to obtain the source code:
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

Note, however, the additional dependencies if you do so.
