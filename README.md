# Documentation for the Brane framework
Repository that contains the high-level documentation of the [Brane framework](https://github.com/epi-project/brane). Written for use with [mdBook](https://rust-lang.github.io/mdBook/index.html).

This repository contains two sets of the documentations: a User Guide for Brane (`./user-guide`) and a kind of Specification for Brane (`./specification`). The first documentation, the User Guide, is aimed at the end-users of Brane, and details how to use the framework for its intended use. The second documentation, the Specification, is aimed at developers of the framework, and discusses the inner workings of the framework.

To visit the generated / released version of the framework, see [https://wiki.enablingpersonalizedinterventions.nl/user-guide](https://wiki.enablingpersonalizedinterventions.nl/user-guide) for the User Guide and [https://wiki.enablingpersonalizedinterventions.nl/specification](https://wiki.enablingpersonalizedinterventions.nl/specification) for the Specification.


## Installation
Note that, to compile the documentation, you should have [mdbook](https://github.com/rust-lang/mdBook) installed. It's available as a [Cargo](https://crates.io/) crate, so if you have Cargo installed, you can simply run:
```bash
$ cargo install mdbook
```

Then, you can compile the desired book by running:
```bash
# Go into the correct directory first
$ cd <book_dir>

# Build using mdbook
$ mdbook build
```

Alternatively, you can use the `upload_book.sh` script to automatically build the book, and then use rsync to send it and relevant dependencies to a remote server:
```bash
$ ./upload_book.sh <book> <server_dir>

# For example
$ ./upload_book.sh ./user-guide foo@bar.com:/var/www/bar.com/brane
```
