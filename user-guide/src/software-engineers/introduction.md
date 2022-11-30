# Introduction
In these series of chapters, we will discuss how you can develop and then upload packages to the Brane instance for use by scientists and other software engineers.

First, in the next section, we will give a bit of background that will help you understand what you're doing. Then, in the [next chapter](./installation.md), we will help you preparing your local machine for Brane package development.


## Background & Terminology
In Brane, every kind of job that is executed is done so by submitting a _workflow_. This is simply a high-level specification of which _external functions_ will be called in what order, and how data is passed between them.

You may think of them as a program, except that it's meant to be more high-level and abstracted over the actual algorithms that are run part of the execution.

That means that the bulk of the work will be done in these external function calls. Because of this modularity present in these workflows, Brane collects these functions in _packages_, which may be used in zero or more workflows as independent compute steps.

Technically, these packages are implemented as containers, which means that they might be written in any language (as long as they adhere to the protocol Brane uses to communicate with packages) and will ship together with all required dependencies.

As a consequence, this means that Brane package calls are, in principle, always completely self-contained. After execution, the container is destroyed, removing any work that the package has done. The only way to retrieve results is by either sending them back to the workflow-space directly as a return value (which can contain limited data), or by returning so-called _datasets_ or _intermediate results_ (see the [scientist chapters](../scientists/data.md) for more background information, or the software engineer's [data chapter](./data.md) for practical usage).


## Next
Before we will go more in-depth on the functionality and process of developing Brane packages, we will first walk you through setting up your machine for development in the [next chapter](./installation.md).

Then, in the chapter after that, we will discuss the different types of packages supported by Brane and how to create them.
