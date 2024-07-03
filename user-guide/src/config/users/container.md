# The container file
_<img src="../../assets/img/source.png" alt="source" width="16" style="margin-top: 3px; margin-bottom: -3px;"/> [`ContainerInfo`](/docs/specifications/container/struct.ContainerInfo.html) in [`specifications/data.rs`](/docs/src/specifications/container.rs.html)._

The container file, or more commonly referenced as the `container.yml` file, is a user-facing configuration file that describes the metadata of a BRANE package. Most notably, it defines how the package's container may be built by stating which files to include, how to run the code, and which BRANE functions are contained within. Additionally, it can also carry data such as the owner of the package or any hardware requirements the package has.

Examples where simple `container.yml`s are written can be found in the [chapters for software engineers](../../software-engineers/introduction.md).


## Toplevel layout
The `container.yml` file is written in [YAML](https://yaml.org). It has quite a lot toplevel fields, so they are discussed separately in the following subsections.

First, we discuss all required fields in the first subsection. Then, in the subsequent sections, all optional fields are discussed.

### Required fields
- `name`: A string defining the package's identifier. Must be unique within a BRANE instance.
- `version`: A string defining the package's version number. Given as three non-negative numbers, separated by a dot (e.g., `0.1.0`), representing the major, minor and patch versions, respectively. Conventionally adheres to [semantic versioning](https://semver.org). Forms a unique identifier for this specific package together with the `name`.
- `kind`: A string defining the kind of the package. For a `container.yml`, this must always be `ecu` (which stands for `ExeCutable Unit`).
- `entrypoint`: A map that describes which file to run when any function in the package is executed. The following fields are supported:
  - `kind`: The kind of entrypoint. Currently, only `task` is supported.
  - `exec`: The path to the file to execute. Note that all paths are relative to the rootmost file or directory defined in the `files`-field.

An example of the required toplevel fields:
```yaml
# Shows an absolute bare minimum header for a `hello_world` package that contributes nothing

name: hello_world
version: 1.0.0
kind: ecu

entrypoint:
  kind: task
  # This won't do anything
  exec: ":"
```

### Extra metadata
- `owners` _\[optional\]_: A sequence of strings which defines the owners/writers of the package. Omitting this field will default to no owners.
- `description` _\[optional\]_: A string description the package in more detail. This is only used for the `brane inspect`-subcommand (see the [chapters for software engineers](../../software-engineers/introduction.md)). If omitted, will default to an empty string / no description.

An example of using these fields:
```yaml
...

owners:
- Amy
- Bob

description: |
  An example package with a lengthy description!

  We even have two lines, using YAML's bar-syntax.
```

### Functions & Classes
- `actions` _\[optional\]_: A map of strings to nested maps that specifies which functions are available to call in this package. Every key defines the name of the function, and every nested map defines what BRANE needs to know about it. The definition of this nested map is [given below](#function-layout). Omitting the field will default to no functions defined.
- `types` _\[optional\]_: A map of strings to nested maps that specifies any custom classes contributed by this package. Omitting this field will default to no such types defined. Every key defines the name of the class, and the map accepts the following possible fields:
  - `properties` _\[optional\]_: A map of string property names to string data types. The data types are listed in the [appropriate section](#data-types) below. Omitting the field will default to no properties defined.
  - `methods` _\[optional\]_: A map of string method names to nested maps that define what BRANE needs to know about a function body. The definition of this nested map is [given below](#function-layout), with the additional requirement imposed on it that there _must_ be at least one input argument called `self` that has the same type as the class of which is it part. Omitting the field will default to no methods defined.

An example of either of the two fields:
```yaml
# Shows an example function that returns a "Hello, world!"-string as discussed in the chapters for software engineers

...

entrypoint:
  kind: task
  exec: hello_world.sh

actions:
  hello_world:
    output:
    - name: output
      type: string
```
```yaml
# Shows an example function that return a "Hello, world!"-string using commands only

...

entrypoint:
  kind: task
  exec: /bin/bash

actions:
  hello_world:
    command:
      args:
      - "-c"
      - "echo 'output: Hello, world!'"
    output:
    - name: output
      type: string
```
```yaml
# Example that shows the definition of a HelloWorld-class that would say hello to a replacement of 'world'

...

types:
  HelloWorld:
    properties:
      world: string
    methods:
      hello_world:
        # Mandatory argument
        input:
        - name: self
          type: HelloWorld
        output:
        - name: output
          type: string
```

> <img src="../../assets/img/warning.png" alt="warning" width="16" style="margin-top: 3px; margin-bottom: -3px;"/> Older BRANE versions (<= 3.0.0) have more limited support for custom classes. First, the key is effectively ignored, and instead an additional `name`-field defines the string name. Second, the properties are not defined by map but instead more like arguments (i.e., as a sequence with a separate name field). Finally, the `methods`-field is not supported altogether. The closest alternative to the above example would thus be:
> ```yaml
> actions:
>   # Replaces the method, instead requiring a manual function call
>   hello_world_method:
>     input:
>     - name: self
>       type: HelloWorld
>     output:
>     - name: output
>       type: string
> 
> types:
>   HelloWorld:
>     name: HelloWorld
>     properties:
>     - name: world
>       type: string
> ```

### Container creation fields
- `base` _\[optional\]_: A string describing the name of the base image for the container. Note that currently, only Debian-based images are supported (due to dependencies being installed with [apt-get](https://manpages.ubuntu.com/manpages/xenial/man8/apt-get.8.html)). If omitted, will default to `ubuntu:20.04`.
- `environment` _\[optional\]_: A map of string environment variable names to their values to set in the container using the [`ENV`](https://docs.docker.com/engine/reference/builder/#env)-command. These occur first in the Dockerfile. Omitting this field means no custom environment variables will be set.
- `dependencies` _\[optional\]_: A sequence of strings describing additional packages to install in the image. They should be given as package names in the repository of the base image, since they will be installed using [apt-get](https://manpages.ubuntu.com/manpages/xenial/man8/apt-get.8.html). The installation of these occurs before any of the subsequent fields in the Dockerfile. If omitted, no custom dependencies will be installed.
- `install` _\[optional\]_: A sequence of strings that defines additional commands to run in the container. Every string will be one [`RUN`](https://docs.docker.com/engine/reference/builder/#run)-command. Since these are placed after the `dependencies`-step, but before the `files`-step in the Dockerfile, they are conventionally used to install non-apt dependencies. If omitted, none of such `RUN`-steps will be added.
- `files` _\[optional\]_: A sequence of strings that refer to files to copy into the container. Every entry is one file, which can either be an absolute path or a relative path. The latter will be interpreted as relative to the `container.yml` file itself, _unless_ the `brane build --context` flag is used (see `brane build --help` for more information). The copy of the files will occur after the `install`-steps, but before the `postinstall`-steps. If omitted, no files will be copied.
- `postinstall` _(or `unpack`)_ _\[optional\]_: A sequence of strings that defines additional commands to run in the container _after_ the files have been copied. Every string will be one [`RUN`](https://docs.docker.com/engine/reference/builder/#run)-command. Since these are placed after the `files`-step in the Dockerfile, they are conventionally used to post-process the source files, such as unpacking archives, downloading additional files or executing [Pipfile](https://github.com/pypa/pipfile)s. If omitted, none of such `RUN`-steps will be added.

A few examples of the above fields:
```yaml
# Shows a typical installation for a Hello-World python script

...

dependencies:
- python3
- python3-pip

install:
- pip3 install yaml

files:
- hello_world.py

...
```
```yaml
# Shows a more complex example where we use a new Ubuntu version and postinstall from a requirements.txt

...

base: ubuntu:22.04

dependencies:
- python3
- python3-pip

files:
- hello_world.py
- requirements.txt

postinstall:
- pip3 install -f requirements.txt

...
```

## Function layout

The following fields define a function layout:
- `requirements` _\[optional\]_: A sequence of strings that defines hardware capabilities that are required for this package. An overview of the possible capabilities can be found [here](../admins/backend.md#capabilities).
- `command` _\[optional\]_: A map that can modify the command to call the file defined in the `entrypoint` toplevel field. Omitting it implies that no additional arguments should be passed. It has the following two possible fields:
  - `args`: A sequence of strings that defines the arguments to pass to the file. Conventionally, this is used to distinguish between the various functions in the file (since there is only one entrypoint).
  - `capture` _\[optional\]_: A string that defines the possible modes of capturing the `entrypoint`'s output. The output should be a YAML file, but only that defined by the capture is identified as such. Possible options are: `complete` to capture the entire stdout; `marked` to capture everything in between a `--> START CAPTURE`-line and an `--> END CAPTURE`-line (not including those markers, and only once); or `prefixed` to capture every line that starts with `~~>` (which is stripped away). Omitting the `capture`-field, or omitting the `command`-field altogether, will default to the `complete` capture mode.
- `input` _\[optional\]_: A sequence of maps that defines the input arguments to the function. The order of the sequence determines the order of the arguments in the workflow language. Omitting the sequence defaults to an empty sequence, i.e., no input arguments taken. The following fields can be used in each nested map:
  - `name`: A string name of the argument. This will define the name of the environment variable that the `entrypoint` executable can read to obtain the given value for this argument. It is not a one-to-one mapping; instead, the environment variable has the same name but in UPPERCASE. In addition, this name will also be used in BraneScript error messages when relevant.
  - `type`: A string describing the BRANE data type of the input argument. The possible types are defined in the [relevant section](#data-types) below.
- `output` _\[optional\]_: A sequence of maps that defines the possible output values to a function. The nested maps are of the same as for the `input`-field (see above), except that the names of the values are used as fieldnames in the YAML outputted by the package code. The order or the sequence determines the order of the returned values in the workflow language. Omitting the sequence defaults to an empty sequence, i.e., returning a void-value.
  > <img src="../../assets/img/warning.png" alt="warning" width="16" style="margin-top: 3px; margin-bottom: -3px;"/> Older BRANE versions (<= 3.0.0) do not support more than one output value, even though they do require a YAML map to be passed. In other words, the sequence cannot be longer than one entry.
- `description` _\[optional\]_: An additional description for this specific function. This is only used for the `brane inspect`-subcommand (see the [chapters for software engineers](../../software-engineers/introduction.md)). If omitted, will default to an empty string / no description.

For examples, see the [Functions & Classes section](#functions--classes).


## Data types
_<img src="../../assets/img/source.png" alt="source" width="16" style="margin-top: 3px; margin-bottom: -3px;"/> [`DataType`](/docs/brane_ast/data_type/enum.DataType.html) in [`brane_ast/data_type.rs`](/docs/src/brane_ast/data_type.rs.html)._

BRANE abstracts the various workflow languages it accepts as input to a common representation. This representation is what is referred to in the `container.yml` file when we are talking about data types, and so these data types are language-agnostic.

The following identifiers can be used to refer to certain data types:
- `bool` or `boolean` refers to a boolean value.
- `int` or `integer` refers to a whole number (64-bit integer).
- `float` or `real` refers to a floating-point number (64-bit float).
- `string` refers to a string value.
- Any other alphanumerical identifier is interpreted to be a custom class name (see the toplevel `types`-field).
- Any of the above can be wrapped in square brackets (e.g., `[int]`) or suffixed by square brackets (e.g., `int[]`) to define an array of the wrapped/suffixed type.
  - Nested arrays are possible (e.g., `[[float]]` or `float[][]`).

For examples, see the [Functions & Classes section](#functions--classes).

## Full example
A full example of a `container.yml` file, taken from the [Hello, world!](../../software-engineers/hello-world.md)-tutorial:
```yaml
# Define the file metadata
# Note the 'kind', which defines that it is an Executable Code Unit (i.e., runs arbitrary code)
name: hello_world
version: 1.0.0
kind: ecu

# Specify the files that are part of the package. All entries will be resolved to relative to the container.yml file (by default)
files:
- hello_world.sh

# Define the entrypoint: i.e., which file to call when the package function(s) are run
entrypoint:
  kind: task
  exec: hello_world.sh

# Define the functions in this package
actions:
  # We only have one: the 'hello_world()' function
  'hello_world':
    # We define the output: a string string, which will be read from the return YAML under the 'output' key.
    output:
    - type: string
      name: output
```
