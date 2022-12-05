# Datasets & Intermediate results
The you have followed the previous two tutorials ([here](./hello-world.md) and [here](./base64.md)), you should be a little familiar with how to package your code as one or more Brane functions, that can accept input and return output.

However, so far, your code will not be very usable to data scientists. That's because a key ingredient is missing: datasets, and especially large ones.

In this tutorial, we will cover exactly that: how you can define a (local) dataset and use it in your package. This is illustrated by creating a package that can compute the minimum or maximum of a given file. First, however, we will provide a little background on how datasets are represented, and what's the difference between Brane's concept of _data_ and Brane's concept of _intermediate results_. If you're eager and already know this stuff, you can skip ahead to the [section after the next one](#1-writing-code).

> <img src="../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> The code used in this tutorial can be found in `examples/doc/minmax` of the [repository](https://github.com/epi-project/brane).


## 0. Background: Variables & Data
In Brane, there is an explicit distinction between _variables_ and _data_.

Variables are probably familiar to you from other programming languages. There, they can be though of as (simple) values or data structures that live in memory only, and is something that typically the processor is able to directly[^note1] manipulate. This is almost exactly the same in Brane, except that they are emphesised to be _simple_, and mostly used for configuration or control flow decisions only.

Data, on the other hand, represents the complex, large data structures that typically live on disk or on remote servers. In Brane, this is typically the information that a package wants to work on, and is also the information that may be sensitive. It is thus subject to [policies](TODO).

Another useful advantage of being able to separate variables and data this way is that we can now leave the transfer of large datasets up to the framework to handle. This significantly reduces complexity when attempting to use data from different sources.

As a rule of thumb, something is a variable if it can be created, accessed and manipulated in BraneScript (or Bakery). In contrast, data can only be accessed by the code in packages, and only exist in BraneScript itself as a reference. It isn't possible to inspect any of the data in a dataset in BraneScript, unless a package is used.

[^note1]: From a programmer's perspective, anyway.


### Datasets & Intermediate Results
Data itself, however, knows a smaller but important distinction. Brane will call a certain piece of data either _datasets_ or _intermediate results_. Conceptually, they are both data (i.e., referencing some file on a disk or some other source), but the first one _can_ outlive a workflow whereas the other _can't_. This distinction is used for policies, where it's important that intermediate results can only be referenced by users in the framework participating within the same workflow and not by others.

For you, a software engineer, the important thing to know is that functions can take both as input, but return _only_ intermediate results as output. To get a dataset from a workflow, a scientist has to use builtin functions to _commit_ and intermediate result to a full dataset.


## 1. Creating a dataset
This time, before we will write code, we first have to create the dataset that we will be using.

Note, though, that creating datasets is typically the role of the [system administrator](../system-admins/data.md) of a given domain that offers the dataset. In other words, you will typically only use datasets already available on the domains in a Brane instance.

However, it can still be useful to create a dataset that is _locally_ available only - typically for testing purposes. That's what we will do here.

For the purpose of the tutorial, we will use a very simple dataset that is a single list of numbers where our code may find the min/max of. To do so, create a folder for the package (which we will call `minmax`) and a folder for the dataset (we will use `minmax/data`). Then, you can either download the dataset [from the repository](TODO) or generate it yourself by running:
```bash
echo "numbers" > numbers.csv && for i in $(awk 'BEGIN{srand(); for(i = 0; i < 100; i++) print int(rand()*100)}'); do echo "$i" >> numbers.csv; done
```
We will assume that after this step, you have a file called `minmax/data/numbers.csv`.

Next, similar to how we use a `container.yml` file to define a package, we will create a `data.yml` file to define a dataset. Create the file (`minmax/data/data.yml`) and write in it:
```yaml
# This determines the name, or more accurately, identifier, of the dataset.
name: numbers

# This determine how we access the data. In this example, we use a file, but check the wiki to find all possible kinds.
access:
  kind: file
  # Note that relative paths, per default, are relative to this file.
  path: ./numbers.csv
```
This will tell Brane out of which file(s) this dataset consists, and by which identifier it is known. The identifier is arbitrary, but should be unique across your local machine. We will assume `numbers`.

> <img src="../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> To package multiple files in a dataset, simply create a folder and refer to that in your `data.yml` file. Be aware, though, that this adds additional uniqueness to your dataset; see [below](#1-writing-code).

Then you can build the dataset by running:
```bash
brane data build ./data.yml
```
in the data folder.

You can confirm that this has worked by executing:
```bash
brane data list
```
which lists all locally available datasets. You should see something like this:

// TODO


## 2. Creating a `container.yml`
In this tutorial, we will break the format you've come to expect so far some more by first looking at a `container.yml` that we will use for our package.

This is almost exactly the same as in previous tutorials, so you should be able to write it yourself (use any of the previous tutorials as example, or check the [repository](TODO)). The only thing that differs is the input and output to the functions we define in our package:
```yaml
...

actions:
  # The max command, which should be mostly familiar by now
  max:
    command:
      args:
      - max
    input:
    - name: column
      type: string
    - name: file
      # This is new!
      type: Data
    output:
    - name: output
      # This is also new!
      type: IntermediateResult

  # Same here
  min:
    command:
      args:
      - min
    input:
    - name: column
      type: string
    - name: file
      type: Data
    output:
    - name: output
      type: IntermediateResult
```
We will focus on the two new parts in `max` only, since they are identical for `min`.

The first is that, instead of requiring an atomic variable such as a `string` or an `int` as input, we now require a _class_ named `Dataset`. Classes are a whole different story altogher (see the [BraneScript documentation](TODO) or the [container.yml documentation](TODO)), but because Data is a special builtin we can safely ignore it for now.

All that you have to know is that `Data` represents a dataset reference; it is not the data itself, but merely some way for the framework to known which dataset you are talking about. You can find more information about this in the [chapters for scientists](TODO), but as a teaser, this is how such a reference is created:
```branescript
let data_reference := new Data { name := "numbers" };
```
This creates a reference for a dataset called `numbers` (what a coincidence!). Thus, by specifying that our package takes a `Data` as input, Brane will know that it's actually some larger dataset that we're referencing.

In the output, we are using something extremely similar: a class named `IntermediateResult`. This is Brane's builtin class for intermediate results, and this is once again a reference to a dataset. The only concrete differences between these two (other than those specified in the [background section](#datasets--intermediate-results-1)) is that `Data` _cannot_ be the output of your function, only `IntermediateResult`. This should be obvious from the semantic difference between them.

This is all that is necessary for Brane to arrange that data is appropriate made available to our package. The rest is done in the package code itself.

> <img src="../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> Typically, it's better practise to take an `IntermediateResult` as an input instead of a `Data`. This is because `Data`-objects are trivially convertible to `IntermediateResult` objects, but the reverse isn't true. Thus, using `IntermediateResult` is more general and typically better practise.


## 3. Writing code
We can now finally start writing the code that runs in our package. Because we have already written the `container.yml` file, we can safely assume that we will have two inputs, `COLUMN` and `FILE`, and that our function should return an intermediate result called `output` somehow.

The code itself will be based on Python, like in the [previous tutorial](./base64.md), and then specifically the [Pandas](https://pandas.pydata.org/) library, since that is able to compute the minumum/maximum of a CSV file in just a few lines.

Like before, create a file `code.yml` that will contain our Python code in the package directory (remember, we use `minmax` as that directory):
```python
#!/usr/bin/env python3


# Imports
import json
import os
import pandas as pd
import sys


# The functions
def max(column: str, df: pd.DataFrame) -> int:
    """
        Finds the maximum number in the given column in the given pandas
        DataFrame.
    """

    # We use the magic of pandas
    return df.max(axis=column)


def min(column: str, data: pd.DataFrame) -> int:
    """
        Finds the minimum number in the given column in the given pandas
        DataFrame.
    """

    # We use the magic of pandas again
    return df.min(axis=column)


# The entrypoint of the script
if __name__ == "__main__":
    # This bit is identical to that in the previous tutorial, but with different keywords
    if len(sys.argv) != 2 or (sys.argv[1] != "max" and sys.argv[1] != "min"):
        print(f"Usage: {sys.argv[0]} max|min")
        exit(1)

    # Read the column from the Brane-specified arguments
    column = json.loads(os.environ["COLUMN"])

    # TODO 1

    # Use the loaded file to call the functions
    command = sys.argv[0]
    if command == "max":
        result = max(column, <TODO>)
    else:
        result = min(column, <TODO>)

    # TODO 2
```
(Don't forget the [shebang](https://en.wikipedia.org/wiki/Shebang_(Unix))!)

More than in the previous tutorial, we will leave understanding the Python code up to you. If you have trouble understanding what it does, we refer you to the [Pandas documentation](http://pandas.pydata.org/docs/reference/). The two `# TODO`s are the places where we will interact with the given dataset or result and return the resulting result, respectively.

First, we will examine how to access given datasets. We assume that two arguments are given to the package: `COLUMN` (which defines the name of the column to read) and `FILE` (which will somehow be our dataset). `COLUMN` will be a simple string, and `FILE` will be _some_ reference to the dataset that the scientist wants our package to work on (see the [`container.yml` section](#2-creating-a-containeryml)).

But what is passed exactly? This is a very case-specific answer, since Brane assumes that every dataset is completely unique - even up to the point of its representation (i.e., a file, a remote API, ...). This means that, as a package writer, it is very hard to write general packages, and instead you will have to make assumptions about a specific format of a dataset. Thus, if you want to support multiple types of datasets, it's instead recommended to create multiple functions, one per data type, and verbosely document the types of data required.

> <img src="../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> In the future, it is likely that BraneScript will be extended to have a concept of _Dataset types_ which exactly defines what kind of dataset is allowed to be passed to a function. However, until that time, the best you can do is simply error at runtime if the dataset is of invalid format.

For the tutorial, however, we can commit ourselves to the `numbers` dataset only. This is of kind `file` (see [above](#0-creating-a-dataset)), which means that Brane will do two things when it passes it to your package:
1. Before the container with your package is launched, the dataset's referenced file (or folder) will be available under _some_ path (in practise, this is typically a folder nested in the `/data` directory in the container).
2. It will pass the path of the dataset's file (or folder) to you as a _string_. This is the value passed in the `FILE` argument.

   > <img src="../assets/img/warning.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> You should always use the given path instead of using a hardcoded one. Not only is the generated path undefined (it may differ per implementation or even domain you're running on), it's also a different path each time a result is passed to your function. Relying on hardcoded values is very bad practise.

Concretely, the following Python snippet will use Pandas to load the dataset at the path given by the `FILE` argument:
```python
...

# TODO 1

# Load the path given in FILE (you can assume it's always absolute)
file = json.loads(os.environ["FILE"])
df = pd.read_csv(file)

...

if command == "max":
    # Note that we replaced '<TODO>' with the loaded dataset here
    result = max(column, df)
else:
    result = min(column, df)

...
```

Despite all the theoretical background, accessing the dataset is typically relatively easy; the only thing to keep in mind is that it is highly _specific_ to the dataset you are committing yourself to.

> <img src="../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> If you package a folder as a dataset, this procedure becomes slightly more complex. The path given by Brane is the path pointing to the folder itself in that case, meaning that you will manually have to append the target file in the folder to the path. For example, if the `numbers` dataset packaged a folder with the file `numbers.csv` in it, the following should be done instead:
> ```python
> file = json.loads(os.environ["FILE"])
> df = pd.read_csv(f"{file}/numbers.csv")
> ```
> However, in this tutorial things are kept simple, and a single file is packaged directly.

With the dataset loaded, we will now consider the second part, which is writing the result.

For educational purposes, we assume that we do not want to use the minimum / maximum number directly, but instead package it as a new dataset. This is actually very common, since this way the result is also subject to policies and cannot be send everywhere.

Recall from the [`container.yml` section](#2-creating-a-containeryml) that we have defined that our package returns an `IntermediateResult` with name `output`. By using that return type, Brane will do the following:
1. A folder `/result` becomes available that is writable (in contrast to the input files/folders). Everything that is written to that folder is, after your package call completes, automatically packages as a new piece of data (an `IntermediateResult`, to be precise).

This means that for our package, all that it has to do to write the result is simply write it to a file in the `/result` directory. This is exactly what we'll be doing:
```python
...

# TODO 2

# We will write the `result` variable to `/result/result.txt`
with open("/result/result.txt", "w") as h:
    h.write(f"{result}")
```

Perhaps a bit counter-intuitively, note that our statement that we will have to return the result as `output` somehow isn't actually true; because functions can have only a single output, and this output is now solely on disk under a defined folder, Brane packages shouldn't actually return anything on `stdout` when they return an intermediate result. Thus, the `output` name defined in the `container.yml` is actually unused in this case.

And with that, our package code is complete! The full code can be inspected in the [repository](TODO).

> <img src="../assets/img/warning.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> Be sure to document properly how the `/result` directory looks like once your package call is done with it. Other packages will get the same directory as-is, so will have to know which files to load and in what format they are written.


# 4. Building & Publishing the package
This will mostly be the same as in the [previous tutorial](./base64.md)(s), and because this tutorial is already getting pretty long already, we assume you are getting familiar to this now.

One key difference with before is that when testing your package, you should now be prompted to use a dataset as input:

// TODO

It will only show you the locally available datasets, which should include the `numbers` dataset. If not, go back to the [first section](#1-creating-a-dataset) and redo those steps.

Similarly, calling your package from the terminal will require you to explicitly reference the `numbers` dataset:

// TODO

You should also see that executing your package call will not be very exciting, since all it does is produce a new dataset. This is alright, since subsequent package calls in a workflows are still able to use it; however, for demonstration purposes, you can try to download the [cat package](https://github.com/epi-project/brane-std/cat) to inspect it:

// TODO

(Refer to the [pull chapter](TODO) for scientists to learn how to install it).


## Next
Congratulations! You have now mastered Brane's packaging system. This should allow you to create useful data science packages for the Brane ecosystem, that scientists may rely upon in their workflows.

As a follow-up to these chapters, you can continue with the [chapters for scientists](../scientists/introduction.md) to learn about the workflows for which you write packages. Alternatively, you can also check the documentation of [`container.yml`](TODO) or [`data.yml`](TODO) to see everything you can do with those files. Finally, you can also go to the [BraneScript documentation](../branescript/introduction.md) to find a complete overview of the language if you're interested.
