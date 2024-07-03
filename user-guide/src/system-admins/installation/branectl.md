# `branectl`
Your best friend for managing a Brane node is the Brane server Command-Line Tool, or `branectl` (do not confuse with the user tool, `brane` or the Brane CLI).

This chapter concerns itself with installing `branectl` itself. Make sure that you have followed the [previous chapter](./dependencies.md) to install the necessary dependencies before you begin.


## Precompiled binary
In most cases, it's the easiest to download the precompiled binary from the [GitHub repository](https://github.com/epi-project/brane).

To download it, you can simply go to the repository (<https://github.com/epi-project/brane>) and navigate to 'tags'. From there, you can select your desired release and choose it from among the list. Alternatively, you can also go to the latest release by clicking this link: <https://github.com/epi-project/brane/releases/latest>.

> <img src="../../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> Note that `branectl` was only introduced in version 1.0.0, so any version before that will not have a downloadable `branectl` executable (or any compatible one, for that matter).

Once downloaded, it's highly recommended to move the executable to a location in your PATH (for example, `/usr/local/bin`). You can do so by running:
```bash
sudo mv ./branectl /usr/local/bin/branectl
```
if you are in the folder where you downloaded the tool.

Alternatively, you can also download the latest version using `curl` from the command-line:
```bash
# For Linux (x86-64)
sudo curl -Lo /usr/local/bin/branectl https://github.com/epi-project/brane/releases/latest/download/branectl-linux-x86_64

# For macOS (Intel)
sudo curl -Lo /usr/local/bin/branectl https://github.com/epi-project/brane/releases/latest/download/branectl-darwin-x86_64

# For macOS (M1/M2)
sudo curl -Lo /usr/local/bin/branectl https://github.com/epi-project/brane/releases/latest/download/branectl-darwin-aarch64
```

Don't forget to make the executable runnable:
```bash
sudo chmod +x /usr/local/bin/branectl
```


## Compile it yourself
Sometimes, though, the executable provided on the repository doesn't suit your needs. This is typically the case if you need a cutting-edge version that isn't released, you have an uncommon OS or processor architecture or an incompatible GLIBC version.

To compile the binary, refer to the [compilation instructions](/specification/development/compilation.html) over at the [Brane: A Specification](/specification)-book for instructions.


## Next
If you can now run `branectl --help` without errors, congratulations! You have successfully installed the management tool for the Brane instance.

You can now choose what kind of node to install. To install a central node, go to the [next chapter](./control-node.md); go to the [chapter after that](./worker-node.md) to install a worker node; or go the the [final chapter](./proxy-node.md) to setup a proxy node.
