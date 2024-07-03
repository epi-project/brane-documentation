# The data file
_<img src="../../assets/img/source.png" alt="source" width="16" style="margin-top: 3px; margin-bottom: -3px;"/> [`AssetInfo`](/docs/specifications/data/struct.AssetInfo.html) in [`specifications/data.rs`](/docs/src/specifications/data.rs.html)._

The data file, or more commonly referenced as the `data.yml` file, is a user-facing configuration file that describes the metadata of a BRANE dataset. Most notably, it defines how the dataset can be referenced in BraneScript (i.e., its identifier) and describes which files or other resources actually make up the dataset.

Examples where simple `data.yml`s are written can be found in the [chapters for scientists](../../scientists/introduction.md).


## Toplevel layout
The `container.yml` file is written in [YAML](https://yaml.org). It has the following toplevel fields:
- `name`: The name/identifier of the dataset. This will be used in the workflow language to refer to it, and must thus be unique within an instance.
- `access`: A map that describes how the package may be accessed. The map has multiple variants in principle, although currently only the `!file`-variant is supported:
  - `path`: A string that refers to a file or folder that has the actual dataset. Can be absolute or relative, where the latter case is interpreted as relative to the `data.yml` file itself (unless `brane data build --context` changes it; see `brane data build --help` for more information). The pointed file or folder will be attached to containers as-is.
- `owners` _\[optional\]_: A sequence of strings which defines the owners/writers of the dataset. Omitting this field will default to no owners.
- `description` _\[optional\]_: A string description the dataset in more detail. This is only used for the `brane data inspect`-subcommand. If omitted, will default to an empty string / no description.

For example, the following defines a `data.yml` file for a simple CSV file called `jedis.csv`:
```yaml
name: jedis
description: A simple CSV file listing Jedis that survived Order 66.
owners:
- Sheev Palpatine
access: !file
  path: ./jedis.csv
```
