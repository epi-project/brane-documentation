# Framework capabilities
In the [previous chapter](./requirements.md), we listed design requirements and goals that the Brane framework should implement. In this chapter, we will discuss some general capabilities that the framework should have to implement those requirements.

First, we will go more in-depth on what a workflow exactly is within the context of Brane. Once that is established, we will list the concrete functions the framework should have.


## Definition of a workflow
Fundementally, all that Brane does is executing a workflow. Thus, we have to consider what it means to run a workflow and how we can achieve that.

In Brane, we define a workflow to simply be a series of function calls that chain together to perform some particular calculation or algorithm. These workflows may be dynamic: they can include some control logic to dynamically determine which functions are run or not. However, where this workflow differs from any normal program is that the 'real work' should solely be done in the called functions, and not in the workflow logic. Additionally, where functions in regular programs may be interconnected or have side effects that interfere with other functions, the functions in Brane are treated as self-contained, closed-boxes. These kind of functions will be referred to as **external functions**.

The opportunity that this creates is two-fold. First, we can quite straightforwardly implement a separation of concerns: software engineers can build external functions that implement (part of) an algorithm, and then scientists can orchestrate them together in a workflow that executes their research. Secondly, by treating the external functions as self-contained boxes and by knowing that they will do the compute-heavy work, they can perfectly be offloaded to the compute sites to run on high-performance hardware while the much simpler control flow can stay closer to the user. Additionally, because they are so self-contained, we can also easily paralellize their execution without much worry for the classical challenges that arise during parallel programming.

<img alt="Image showing the abstracted anatomy of a workflow in Brane" id="fig1" src="../assets/img/workflow.svg"></img>
_Figure 1: The structure of offloading package calls to compute nodes. Because each package is self-contained, we can very easily implement parallelization by simply making the schedule of the call non-blocking._

This idea of a workflow is illustrated in figure 1. It shows that each package call should be offloaded to a compute node which runs the package, and that we can easily parallelize these calls by making the offloading non-blocking.


## Brane capabilities
We can now define a more concrete list of functions that the framework should handle. However, we will not talk about implementation left, so some of these definitions will still be very high-level.

First, we will implement building and using the external functions as **packages**. These packages are simply a bundle of external functions, implemented in any programming language (since they are opaque anyway), and can be uploaded to and downloaded from a central repository. This easy sharing of external functions should aid the separation of concerns, and additionally promote code-reuse between workflows and even between different Brane instances.

> Because packages and external functions are so related, we will sometimes also use 'packages' to refer to external functions when their distinction does not matter.

To support these packages, the framework should allow a user to build a package, upload a package to a remote repository, manage their packages in a remote repository, and use their packages in a workflow. Additionally, it would be very convenient if the packages can be tested locally first.

For workflows, we can define a similar list: the user should be able to define a workflow, submit it to a running Brane instance and inspect its results. Here too it would be very nice if we can test locally first.

To address the third separation of concerns (system engineers), we also have to provide some interface to infrastructure topologies and interfaces. To be able to better align with their usual method of working, Brane should provide configuration files to set this up.
